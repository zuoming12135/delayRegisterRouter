//
//  MSRouterHelper.h
//  export
//
//  Created by Michael_Zuo on 2020/10/28.
//  Copyright © 2020 Michael_Zuo. All rights reserved.
//

#import <Foundation/Foundation.h>





NS_ASSUME_NONNULL_BEGIN
@protocol MSRouterProtocol <NSObject>

@required
+(void)regiserRouter;

@end
@interface MSRouterHelper : NSObject
+(instancetype)singleton;
- (void)loadAllRouterInfos;
@end

NS_ASSUME_NONNULL_END
