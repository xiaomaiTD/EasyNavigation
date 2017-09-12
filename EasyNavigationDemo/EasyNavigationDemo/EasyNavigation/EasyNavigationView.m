//
//  EasyNavigationView.m
//  EasyNavigationDemo
//
//  Created by nf on 2017/9/7.
//  Copyright © 2017年 chenliangloveyou. All rights reserved.
//

#import "EasyNavigationView.h"

#import "EasyUtils.h"
#import "UIView+EasyNavigationExt.h"

#import "EasyNavigationOptions.h"


#define kTitleViewEdge 100.0f //title左右边距

#define kViewMaxWidth 100.0f //左右两边按钮，视图，最大的的宽度
#define kViewMinWidth  44.0f //左右两边按钮，视图，最小的的宽度
#define kViewEdge   2.0f //按钮之间的间距


static int easynavigation_button_tag = 1 ; //视图放到数组中的唯一标示


/**
 * 创建视图的位置，放在左边还是右边
 */
typedef NS_ENUM(NSUInteger , buttonPlaceType) {
    buttonPlaceTypeLeft ,
    buttonPlaceTypeRight ,
};

@interface EasyNavigationView()
{
    CGFloat _alphaStartChange ;//alpha改变的开始位置
    CGFloat _alphaEndChange   ;//alpha停止改变的位置
    
    UIScrollView *_kvoScrollView ;//用于监听scrollview内容高度的改变
}
@property (nonatomic,strong)EasyNavigationOptions *options ;

@property (nonatomic,assign)CGFloat backGroundAlpha ;

@property (nonatomic,strong)UIView *backgroundView ;
@property (nonatomic,strong)UIImageView *backgroundImageView ;

@property (nonatomic,strong) UILabel *titleLabel ;

@property (nonatomic,strong)UIButton *leftButton ;

@property (nonatomic,strong)UIButton *rightButton ;

@property (nonatomic,strong)UIViewController *viewController ;//navigation所在的控制器

@property (nonatomic,strong)UIView *lineView ;//导航条最下面的一条线

@property (nonatomic,strong)NSMutableArray *leftViewArray ;//左边所有的视图
@property (nonatomic,strong)NSMutableArray *rightViewArray ;//右边所有的视图

@property (nonatomic,strong)NSMutableDictionary *callbackDictionary ;//回调的数组

@end

@implementation EasyNavigationView


#pragma mark - life cycle

- (void)dealloc
{
    [_kvoScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _backGroundAlpha = self.options.backGroundAlpha ;
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.backgroundImageView] ;
        
        [self addSubview:self.titleLabel] ;
        [self addSubview:self.lineView];
        
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    kWeakSelf(self)
    self.viewController.view.didAddsubView = ^(UIView *view) {
      
        if (![view isEqual:weakself]) {
            [weakself.viewController.view bringSubviewToFront:weakself];
        }
    };
    
    self.didAddsubView = ^(UIView *view) {
        
        [weakself bringSubviewToFront:weakself.titleLabel];
    };
}

- (void)layoutSubviews
{
    [self layoutSubviewsWithType:buttonPlaceTypeLeft];
    [self layoutSubviewsWithType:buttonPlaceTypeRight];
    
}

#pragma mark - titleview
- (void)setTitle:(NSString *)title 
{
    self.titleLabel.text = title;
}
- (void)addtitleView:(UIView *)titleView
{
    [self addSubview:titleView];
    titleView.center = CGPointMake(self.bounds.size.width/2 , NAV_STATE_HEIGHT+(self.bounds.size.height-NAV_STATE_HEIGHT)/2);
}

- (void)addSubview:(UIView *)view clickCallback:(clickCallback)callback
{
    
    view.tag = ++easynavigation_button_tag ;
    
    [view addTapCallBack:self sel:@selector(viewClick:)];
    [self addSubview:view];
    
    if (callback) {
        [self.callbackDictionary setObject:[callback copy] forKey:@(view.tag)];
    }
}


#pragma mark - 左边视图

- (void)addLeftView:(UIView *)view clickCallback:(clickCallback)callback
{
    [self addView:view clickCallback:callback type:buttonPlaceTypeLeft];
}

- (UIButton *)addLeftButtonWithTitle:(NSString *)title clickCallBack:(clickCallback)callback
{
   return [self createButtonWithTitle:title
                      backgroundImage:nil
                                image:nil
                           hightImage:nil
                             callback:callback
                                 type:buttonPlaceTypeLeft];
}

- (UIButton *)addLeftButtonWithTitle:(NSString *)title backgroundImage:(UIImage *)backgroundImage clickCallBack:(clickCallback)callback
{
    return [self createButtonWithTitle:title
                       backgroundImage:backgroundImage
                                 image:nil
                            hightImage:nil
                              callback:callback
                                  type:buttonPlaceTypeLeft];
}

- (UIButton *)addLeftButtonWithImage:(UIImage *)image clickCallBack:(clickCallback)callback
{
    return [self createButtonWithTitle:nil
                       backgroundImage:nil
                                 image:image
                            hightImage:nil
                              callback:callback
                                  type:buttonPlaceTypeLeft];
}

- (UIButton *)addLeftButtonWithImage:(UIImage *)image hightImage:(UIImage *)hightImage clickCallBack:(clickCallback)callback
{
    return [self createButtonWithTitle:nil
                       backgroundImage:nil
                                 image:image
                            hightImage:hightImage
                              callback:callback
                                  type:buttonPlaceTypeLeft];
}


- (void)removeLeftView:(UIView *)view
{
    for (UIView *tempView in self.leftViewArray) {
        if ([tempView isEqual:view]) {
            [view removeFromSuperview];
        }
    }
    [self.leftViewArray removeObject:view];
}

- (void)removeAllLeftButton
{
    for (UIView *tempView in self.leftViewArray) {
        [tempView removeFromSuperview];
    }
    [self.leftViewArray removeAllObjects];
}


#pragma mark - 右边视图

- (void)addRightView:(UIView *)view clickCallback:(clickCallback)callback
{
    [self addView:view clickCallback:callback type:buttonPlaceTypeRight];
}

- (UIButton *)addRightButtonWithTitle:(NSString *)title clickCallBack:(clickCallback)callback
{
    return [self createButtonWithTitle:title
                       backgroundImage:nil
                                 image:nil
                            hightImage:nil
                              callback:callback
                                  type:buttonPlaceTypeRight];
}

- (UIButton *)addRightButtonWithTitle:(NSString *)title backgroundImage:(UIImage *)backgroundImage clickCallBack:(clickCallback)callback
{
    return [self createButtonWithTitle:title
                       backgroundImage:backgroundImage
                                 image:nil
                            hightImage:nil
                              callback:callback
                                  type:buttonPlaceTypeRight];
}

- (UIButton *)addRightButtonWithImage:(UIImage *)image clickCallBack:(clickCallback)callback
{
    return [self createButtonWithTitle:nil
                       backgroundImage:nil
                                 image:image
                            hightImage:nil
                              callback:callback
                                  type:buttonPlaceTypeRight];
}

- (UIButton *)addRightButtonWithImage:(UIImage *)image hightImage:(UIImage *)hightImage clickCallBack:(clickCallback)callback
{
    return [self createButtonWithTitle:nil
                       backgroundImage:nil
                                 image:image
                            hightImage:hightImage
                              callback:callback
                                  type:buttonPlaceTypeRight];
}


- (void)removeRightView:(UIView *)view
{
    for (UIView *tempView in self.rightViewArray) {
        if ([tempView isEqual:view]) {
            [view removeFromSuperview];
        }
    }
    [self.rightViewArray removeObject:view];
}

- (void)removeAllRightButton
{
    for (UIView *tempView in self.rightViewArray) {
        [tempView removeFromSuperview];
    }
    [self.rightViewArray removeAllObjects];
}



#pragma mark - 视图滚动，导航条跟着变化

/**
 * 根据scrollview的滚动，导航条慢慢渐变
 */
- (void)navigationAlphaSlowChangeWithScrollow:(UIScrollView *)scrollow
{
    _alphaStartChange = 0 ;
    _alphaEndChange = NAV_HEIGHT*2.0 ;
    _kvoScrollView = scrollow ;
    
    [scrollow addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)navigationAlphaSlowChangeWithScrollow:(UIScrollView *)scrollow start:(CGFloat)startPoint end:(CGFloat)endPoint
{
    _alphaStartChange = startPoint ;
    _alphaEndChange = endPoint ;
    _kvoScrollView = scrollow ;
    [scrollow addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

/**
 * 根据scrollview滚动，导航条隐藏或者展示.
 */
- (void)navigationScrollStopStateBarWithScrollow:(UIScrollView *)scrollow
{
    _kvoScrollView = scrollow ;
    
    [scrollow addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

/**
 * scorllow滚动，导航栏跟着滚动，最终停在状态栏下
 */
- (void)navigationScrollWithScrollow:(UIScrollView *)scrollow
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    CGFloat contentInsetY =_kvoScrollView.contentInset.top ;
    CGFloat contentOffsetY = _kvoScrollView.contentOffset.y;
    NSLog(@"offsetY %f contentInsetY %f",contentOffsetY,contentInsetY);
    if (contentOffsetY + contentInsetY> _alphaStartChange){
        CGFloat alpha = (contentOffsetY + contentInsetY) / _alphaEndChange ;
        
        NSLog(@"  alpha %f ",alpha);
        //        self.alpha = alpha ;
        [self setBackgroundAlpha:alpha];
    }
    else{
        [self setBackgroundAlpha:0];
    }
}

#pragma mark - private

- (UIButton *)createButtonWithTitle:(NSString *)title backgroundImage:(UIImage *)backgroundImage image:(UIImage *)image hightImage:(UIImage *)hieghtImage callback:(clickCallback)callback type:(buttonPlaceType)type
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (title.length) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    
    if (backgroundImage) {
        [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    }
    
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    
    if (hieghtImage) {
        [button setImage:hieghtImage forState:UIControlStateHighlighted];
    }
    
    [button setTitleColor:self.options.buttonTitleColor forState:UIControlStateNormal];
    [button setTitleColor:self.options.buttonTitleColorHieght forState:UIControlStateHighlighted];
    [button setBackgroundColor:self.options.buttonBackgroundColor];
    button.titleLabel.font = self.options.buttonTitleFont ;
    [button setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    
    button.tag = ++easynavigation_button_tag ;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
    
    if (type == buttonPlaceTypeLeft) {
        [self.leftViewArray addObject:button];
    }
    else{
        [self.rightViewArray addObject:button];
    }
    
    if (callback) {
        [self.callbackDictionary setObject:[callback copy] forKey:@(button.tag)];
    }
    
    return button ;
}

- (void)addView:(UIView *)view clickCallback:(clickCallback)callback type:(buttonPlaceType)type
{
    
    view.tag = ++easynavigation_button_tag ;
    [view addTapCallBack:self sel:@selector(viewClick:)];
    
    [self addSubview:view];
    
    if (type == buttonPlaceTypeLeft) {
        [self.leftViewArray addObject:view];
    }
    else{
        [self.rightViewArray addObject:view];
    }
    
    if (callback) {
        [self.callbackDictionary setObject:[callback copy] forKey:@(view.tag)];
    }
}

- (void)buttonClick:(UIButton *)button
{
    clickCallback callback = [self.callbackDictionary objectForKey:@(button.tag)];
    if (callback) {
        callback(button);
    }
}
- (void)viewClick:(UITapGestureRecognizer *)tapgesture
{
    clickCallback callback = [self.callbackDictionary objectForKey:@(tapgesture.view.tag)];
    if (callback) {
        callback(tapgesture.view);
    }
}

- (void)layoutSubviewsWithType:(buttonPlaceType)type
{
    NSMutableArray *tempArray = nil ;
    if (type == buttonPlaceTypeLeft) {
        tempArray = self.leftViewArray ;
    }
    else{
        tempArray = self.rightViewArray ;
    }
    
    CGFloat leftEdge = 10 ;
    for (int i = 0 ; i < tempArray.count; i++) {
        UIView *tempView = tempArray[i];
        
        if (i == 0) {
            if (type == buttonPlaceTypeLeft) {
                self.leftButton = (UIButton *)tempView ;
            }
            else{
                self.rightButton = (UIButton *)tempView ;
            }
        }
        
        CGFloat viewWidth = 0 ;
        if ([tempView isKindOfClass:[UIButton class]]) {
            
            UIButton *tempButton = (UIButton *)tempView ;

            viewWidth = [tempButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:tempButton.titleLabel.font.fontName size:tempButton.titleLabel.font.pointSize]}].width + 5 ;
        }
        else{
            viewWidth = tempView.width ;
        }
        
        if (viewWidth < kViewMinWidth) {
            viewWidth = kViewMinWidth ;
        }
        if (viewWidth > kViewMaxWidth) {//36 - 20
            viewWidth = kViewMaxWidth ;
        }
        
        CGFloat tempViewX = type==buttonPlaceTypeLeft ? leftEdge : self.width-leftEdge-viewWidth ;
        tempView.frame = CGRectMake(tempViewX, NAV_STATE_HEIGHT, viewWidth , self.height-NAV_STATE_HEIGHT-self.lineView.height);
        
        leftEdge += viewWidth+kViewEdge  ;
        
    }
    
}


#pragma mark - getter / setter

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundImageView.image = backgroundImage ;
}
- (void)setBackgroundAlpha:(CGFloat)alpha
{
    _backGroundAlpha = alpha ;
    self.backgroundImageView.alpha = alpha ;
    self.backgroundView.alpha = alpha ;
    self.lineView.alpha = alpha;
}


- (void)setLineHidden:(BOOL)lineHidden
{
    _lineHidden = lineHidden ;
    self.lineView.hidden = lineHidden ;
}


- (CGFloat)navHeigth
{
    return self.bounds.size.height ;
}

- (UILabel *)titleLabel
{
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kTitleViewEdge, NAV_STATE_HEIGHT, SCREEN_WIDTH-kTitleViewEdge*2 , self.bounds.size.height - NAV_STATE_HEIGHT)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = self.options.titleFont ;
        _titleLabel.textColor = self.options.titleColor ;
        _titleLabel.textAlignment = NSTextAlignmentCenter ;
    }
    return _titleLabel ;
}
- (UIView *)backgroundView
{
    if (nil == _backgroundView) {
        _backgroundView = [[UIView alloc]initWithFrame:self.bounds];
        _backgroundView.backgroundColor = self.options.navBackGroundColor ;
        _backgroundView.alpha = _backGroundAlpha ;
    }
    return _backgroundView ;
}
- (UIImageView *)backgroundImageView
{
    if (nil == _backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.alpha = _backGroundAlpha ;
    }
    return _backgroundImageView ;
}

- (UIViewController *)viewController
{
    if (nil == _viewController) {
        _viewController = [self currentViewController] ;
    }
    return _viewController ;
}

- (UIView *)lineView
{
    if (nil == _lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5)];
        _lineView.backgroundColor = self.options.navLineColor;
    }
    return _lineView ;
}

- (NSMutableDictionary *)callbackDictionary
{
    if (nil == _callbackDictionary) {
        _callbackDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return _callbackDictionary ;
}
- (NSMutableArray *)leftViewArray
{
    if (nil == _leftViewArray) {
        _leftViewArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _leftViewArray ;
}
- (NSMutableArray *)rightViewArray
{
    if (nil == _rightViewArray) {
        _rightViewArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _rightViewArray ;
}

- (EasyNavigationOptions *)options
{
    if (nil == _options) {
        _options  = [EasyNavigationOptions shareInstance];
    }
    return _options ;
}

//- (void)drawRect:(CGRect)rect
//{
//    [[EasyUtils createImageWithColor:[UIColor redColor]] drawInRect:rect];
//}
//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    if (self.statusView) {
//        self.statusView.frame = CGRectMake(0, 0 - kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), kSpaceToCoverStatusBars);
//    }
//}
@end