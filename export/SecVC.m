//
//  SecVC.m
//  export
//
//  Created by Michael_Zuo on 2020/10/28.
//  Copyright © 2020 Michael_Zuo. All rights reserved.
//

#import "SecVC.h"


@interface SecVC ()<MSRouterProtocol>

@end

@implementation SecVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
+ (void)regiserRouter {
    MS_EXPORT();
    NSLog(@"sec regiserRouter");
}
@end
