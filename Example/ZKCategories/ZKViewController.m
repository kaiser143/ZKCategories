//
//  ZKViewController.m
//  ZKCategories
//
//  Created by Kaiser on 08/25/2017.
//  Copyright (c) 2017 Kaiser. All rights reserved.
//

#import "ZKViewController.h"
#import "ZKCategories.h"
#import "ZKKVOViewController.h"

@interface ZKViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) NSString *value;

@end

@implementation ZKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    NSNumber *number = @(13145678.1415926);
    NSLog(@"%@", [number stringWithFormat:@",###.00"]);
    NSLog(@"%@", [number stringWithFormat:@".00"]);
    NSLog(@"%@", [number stringWithFormat:@"0.00%"]);
    NSLog(@"%@", [number stringWithFormat:@"#.##%"]);
    
    static NSInteger i = 0;
    if (i == 0) {
        UIButton *next = [UIButton buttonWithType:UIButtonTypeCustom];
        next.top = 100;
        next.size = CGSizeMake(80, 50);
        next.centerX = self.view.centerX;
        kai_view_border_radius(next, 8.f, 1, [UIColor colorWithHexString:@"#eeeeee"]);
        [next setTitle:@"下一页" forState:UIControlStateNormal];
        [next setTitleColor:UIColor.blackColor];
        [self.view addSubview:next];
        
        @weakify(self, next);
        [next addBlockForControlEvents:UIControlEventTouchUpInside
                                 block:^(id  _Nonnull sender) {
                                     @strongify(self, next);
                                     [self kai_pushViewController:ZKViewController.new];
                                 }];
    } else {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.backgroundColor = UIColor.randomColor;
        scrollView.delegate = self;
        scrollView.contentSize = CGSizeMake(kScreenSize.width, 2*kScreenSize.height);
        [self.view addSubview:scrollView];
        
        @weakify(self);
        [self backButtonInjectBlock:^(UIViewController * _Nonnull controller) {
            @strongify(self);
            [self kai_popViewControllerAnimated];
        }];
        
//        [scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
    
    @weakify(self);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"KVO 测试"];
    [button setTitleColor:UIColor.blackColor];
    button.top = 200;
    button.size = CGSizeMake(80, 50);
    button.centerX = self.view.centerX;
    kai_view_border_radius(button, 8.f, 1, [UIColor colorWithHexString:@"#eeeeee"]);
    [self.view addSubview:button];
    [button addBlockForControlEvents:UIControlEventTouchUpInside
                               block:^(__kindof UIControl * _Nonnull sender) {
        @strongify(self);
        ZKKVOViewController *controller = [[ZKKVOViewController alloc] init];
        [self kai_pushViewController:controller];
    }];
    
    i++;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIScrollView *scrollView = (UIScrollView *)[self.view descendantOrSelfWithClass:UIScrollView.class];
//    if (scrollView) [self navigationColor:scrollView.contentOffsetY];
}

#pragma mark - :. UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self navigationColor:scrollView.contentOffsetY];
//}
//
//- (void)navigationColor:(CGFloat)offsetY {
//    CGFloat y = 88; //device_iPhoneX ? 88 : 64;
//    NSInteger navbarChangePoint = -(+y); //-(self.topBannerView.height + y);
//
//    if (offsetY > navbarChangePoint) {
//        CGFloat alpha = MIN(1, 1 - ((navbarChangePoint + y - offsetY) / y));
//        NSLog(@"%f", alpha);
//        [self.navigationController.navigationBar setNeedsNavigationBackground:alpha];
//        UIStatusBarStyle style = UIStatusBarStyleLightContent;
//        UIColor *color = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
//        BOOL isShadow = YES;
//        if (alpha == 1) {
//            style = UIStatusBarStyleDefault;
//            color = UIColorHex(F1F3F5);
//            isShadow = NO;
//        }
//
//        [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
////        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
////        kai_view_shadow(self.navigationController.navigationBar, UIColorHex(303943), CGSizeMake(0, -5), 0.5, 6);
//        //        !self.viewManagerInfosBlock ?: self.viewManagerInfosBlock(@"color", @{ @"color" : color,
//        //                                                                               @"isShadow" : @(isShadow) });
//    } else {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
//        [self.navigationController.navigationBar setNeedsNavigationBackground:0];
//        self.navigationController.navigationBar.layer.shadowColor = [UIColor clearColor].CGColor;
//
//
//        CGFloat statusHeight = 44; //device_iPhoneX ? 44 : 20;
//        if (offsetY < -(/*self.homeCollectionView.contentInsetTop*/0 + statusHeight)) {
//            //            self.navigationController.navigationBar.hidden = YES;
//            //            self.navImageView.hidden = YES;
//        } else if (offsetY >= -(statusHeight)) {
//            //            self.navigationController.navigationBar.hidden = NO;
//            //            self.navImageView.hidden = NO;
//        }
//    }
//}

@end
