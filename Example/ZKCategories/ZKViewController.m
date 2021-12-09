//
//  ZKViewController.m
//  ZKCategories
//
//  Created by Kaiser on 08/25/2017.
//  Copyright (c) 2017 Kaiser. All rights reserved.
//

#import "ZKViewController.h"
#import <ZKCategories/ZKCategories.h>
#import "ZKKVOViewController.h"

@interface ZKViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) NSString *value;

@end

@implementation ZKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = UIColor.whiteColor;

    NSNumber *number = @(13145678.1415926);
    ZKLog(@"%@", [number stringWithFormat:@",###.00"]);
    ZKLog(@"%@", [number stringWithFormat:@".00"]);
    ZKLog(@"%@", [number stringWithFormat:@"0.00%"]);
    ZKLog(@"%@", [number stringWithFormat:@"#.##%"]);

    static NSInteger i = 0;
    if (i == 0) {
        UIButton *next = [UIButton buttonWithType:UIButtonTypeCustom];
        next.top       = 100;
        next.size      = CGSizeMake(80, 50);
        next.centerX   = self.view.centerX;
        kai_view_border_radius(next, 8.f, 1, [UIColor colorWithHexString:@"#eeeeee"]);
        [next setTitle:@"下一页" forState:UIControlStateNormal];
        [next setTitleColor:UIColor.blackColor];
        [self.view addSubview:next];

        @weakify(self);
        [next addBlockForControlEvents:UIControlEventTouchUpInside
                                 block:^(id _Nonnull sender) {
                                     @strongify(self);
                                     [self kai_pushViewController:ZKViewController.new];
                                 }];
    } else {
        UIScrollView *scrollView   = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.backgroundColor = UIColor.randomColor;
        scrollView.delegate        = self;
        scrollView.contentSize     = CGSizeMake(kScreenSize.width, 2 * kScreenSize.height);
        [self.view addSubview:scrollView];

        @weakify(self);
        self.kai_prefersPopViewControllerInjectBlock = ^(UIViewController *_Nonnull controller) {
            @strongify(self);
            [self kai_popViewControllerAnimated];
        };

        //        [scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }

    @weakify(self);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button kai_setTitle:@"KVO 测试"];
    [button setTitleColor:UIColor.blackColor];
    button.top     = 200;
    button.size    = CGSizeMake(80, 50);
    button.centerX = self.view.centerX;
    kai_view_border_radius(button, 8.f, 1, [UIColor colorWithHexString:@"#eeeeee"]);
    [self.view addSubview:button];
    [button addBlockForControlEvents:UIControlEventTouchUpInside
                               block:^(__kindof UIControl *_Nonnull sender) {
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


@end
