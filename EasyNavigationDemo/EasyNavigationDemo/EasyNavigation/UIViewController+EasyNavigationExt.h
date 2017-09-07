//
//  UIViewController+EasyNavigationExt.h
//  EasyNavigationDemo
//
//  Created by nf on 2017/9/7.
//  Copyright © 2017年 chenliangloveyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EasyNavigationViewController ;

@interface UIViewController (EasyNavigationExt)

//返回手势是否可用
@property (nonatomic,assign)BOOL backGestureEnabled ;

@property (nonatomic, weak) EasyNavigationViewController *easyNavigationController ;


@end