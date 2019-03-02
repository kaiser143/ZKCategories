//
//  ZKViewController.m
//  ZKCategories
//
//  Created by Kaiser on 08/25/2017.
//  Copyright (c) 2017 Kaiser. All rights reserved.
//

#import "ZKViewController.h"
#import "ZKCategories.h"

@interface ZKViewController ()

@end

@implementation ZKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = UIColor.randomColor;
    
    static NSInteger i = 0;
    if (i == 0) {
        UIButton *next = [UIButton buttonWithType:UIButtonTypeCustom];
        next.top = 100;
        next.centerX = self.view.centerX;
        next.size = CGSizeMake(50, 50);
        kai_view_border_radius(next, 8.f, 1, [UIColor colorWithHexString:@"#eeeeee"]);
        [next setTitle:@"下一页" forState:UIControlStateNormal];
        [self.view addSubview:next];
        
        @weakify(self, next);
        [next addBlockForControlEvents:UIControlEventTouchUpInside
                                 block:^(id  _Nonnull sender) {
                                     @strongify(self, next);
                                     [self.navigationController pushViewController:ZKViewController.new animated:YES];
                                 }];
    } else {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.contentSize = CGSizeMake(2*kScreenSize.width, 2*kScreenSize.height);
        [self.view addSubview:scrollView];
    }
    
    i++;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
