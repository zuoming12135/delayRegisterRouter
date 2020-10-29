//
//  MSRouterHelper.m
//  export
//
//  Created by Michael_Zuo on 2020/10/28.
//  Copyright © 2020 Michael_Zuo. All rights reserved.
//
//#if DEBUG

#import <dlfcn.h>
#import <objc/runtime.h>

#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <mach-o/ldsyms.h>
#import "MSRouterHelper.h"

#ifdef __LP64__
typedef uint64_t RAMExportValue;
typedef struct section_64 RAMExportSection;
#define RAMGetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t RAMExportValue;
typedef struct section RAMExportSection;
#define RAMGetSectByNameFromHeader getsectbynamefromheader
#endif
NSString *RAMExtractClassName(NSString *methodName) {
    // Parse class and method
    
    NSArray *parts = [[methodName substringWithRange:NSMakeRange(2, methodName.length - 3)] componentsSeparatedByString:@" "];
    if (parts.count > 0)
        return parts[0];
    
    return nil;
}
NSArray *RAMExportedMethodsByModuleID(void) {
    static NSMutableArray *classes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!classes){
            classes = [NSMutableArray new];
        }
        
        Dl_info info;
        //这里可能要外部传进来，用来支持动态库导出router信息
         //dladdr获取某个地址的符号信息，动态链接程序有用
        dladdr(&RAMExportedMethodsByModuleID, &info);
        
#ifdef __LP64__
        typedef uint64_t MSExportValue;
        typedef struct section_64 MSExportSection;
#define RAMGetSectByNameFromHeader getsectbynamefromheader_64
#else
        typedef uint32_t MSExportValue;
        typedef struct section MSExportSection;
#define RAMGetSectByNameFromHeader getsectbynamefromheader
#endif
        // 共享对象基址
        const RAMExportValue mach_header = (RAMExportValue)info.dli_fbase;
        // 获取__DATA.MSExport输入段中的变量
        const RAMExportSection *section = RAMGetSectByNameFromHeader((void *)mach_header, "__DATA", "MSExport");
        
        if (section == NULL) {
            return;
        }
        //计算char* 指向指针的所占字节大小
        int addrOffset = sizeof(const char **);
        /**
         *  防止address sanitizer报global-buffer-overflow错误
         *  MStps://github.com/google/sanitizers/issues/355
         *  因为address sanitizer填充了符号地址，使用正确的地址偏移
         */
#if defined(__has_feature)
#  if __has_feature(address_sanitizer)
        addrOffset = 64;
#  endif
#endif
        // 获取__DATA.MSExport中section中注册的所有函数名
        for (RAMExportValue addr = section->offset;
             addr < section->offset + section->size;
             addr += addrOffset) {
            
            NSString *entry = @(*(const char **)(mach_header + addr));
            if (entry.length == 0) {
                continue;
            }
            
            NSString *className = RAMExtractClassName(entry);
            Class class = className ? NSClassFromString(className) : nil;
            if (class){
                [classes addObject:class];
            }
        }
    });
    
    return classes;
}
@interface MSRouterHelper()
@property (nonatomic, strong) NSMutableArray<Class> *routeControllerClasses;
@end
@implementation MSRouterHelper
+(instancetype)singleton{
    static MSRouterHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [MSRouterHelper new];
    });
    return  helper;
}

- (void)loadAllRouterInfos {
    NSArray *classes = RAMExportedMethodsByModuleID();
    if (classes)
        _routeControllerClasses = [NSMutableArray arrayWithArray:classes];
    else
        _routeControllerClasses = [NSMutableArray new];
    
    
    for (Class cls in _routeControllerClasses) {
        NSAssert([cls conformsToProtocol:@protocol(MSRouterProtocol)], @"MSRouterConfig class:%@ not conform to protocol:%@", cls, @protocol(MSRouterProtocol));
        [cls regiserRouter];
        
    }
}

@end
