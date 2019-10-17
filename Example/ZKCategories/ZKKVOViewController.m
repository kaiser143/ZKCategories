//
//  ZKKVOViewController.m
//  ZKCategories_Example
//
//  Created by Kaiser on 2019/10/17.
//  Copyright © 2019 Kaiser. All rights reserved.
//

#import "ZKKVOViewController.h"

@interface KVOObserver :NSObject @end

@implementation KVOObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"KVOObserver:value %@", change[NSKeyValueChangeNewKey]);
}

- (void)dealloc{
    NSLog(@"dealloc");
}

@end

@interface KVODemo : NSObject
@property (nonatomic, copy) NSString *demoString;
@end

@implementation KVODemo @end


@interface ZKKVOViewController ()

@property (nonatomic, strong) KVOObserver *KVOObserver;
@property (nonatomic, strong) KVODemo *KVODemo;
@property (nonatomic, copy) NSString *test;
@property (nonatomic, copy) NSString *test1;
@property (nonatomic, copy) NSString *test2;

@end

@implementation ZKKVOViewController

- (void)dealloc {
    NSLog(@"ZKKVOViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"KVO Safe";
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.KVOObserver = KVOObserver.new;
    self.KVODemo = KVODemo.new;
    
    [self testKVO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.test = @"tmp";
    self.KVOObserver = nil;
    self.test = @"test";
    
    self.KVODemo.demoString = @"1";
}

- (void)testKVO{
    [self addObserver:self forKeyPath:@"test" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"test" options:NSKeyValueObservingOptionNew context:nil];
    
    [self removeObserver:self forKeyPath:@"test1" context:nil];
    
    [self addObserver:self forKeyPath:@"test2" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.KVODemo addObserver:self forKeyPath:@"demoString" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addObserver:self.KVOObserver forKeyPath:@"test" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"ZKKVOViewController:value %@", change[NSKeyValueChangeNewKey]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
