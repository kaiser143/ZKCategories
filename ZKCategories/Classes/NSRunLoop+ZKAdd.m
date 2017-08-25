//
//  NSRunLoop+ZKAdd.m
//  Pods
//
//  Created by Kaiser on 2017/3/6.
//
//

#import "NSRunLoop+ZKAdd.h"

NSString *const NSRunloopTimeoutException = @"NSRunloopTimeoutException";

@implementation NSRunLoop (ZKAdd)

- (void)performBlockAndWait:(void (^)(BOOL *))block timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (!block || timeoutInterval < 0.0) {
        [NSException raise:NSInvalidArgumentException format:@"%lf is invalid for timeout interval", timeoutInterval];
    }
    
    NSDate *startedDate = [NSDate date];
    BOOL finish = NO;
    
    block(&finish);
    
    while (!finish && [[NSDate date] timeIntervalSinceDate:startedDate] < timeoutInterval) {
        @autoreleasepool {
            [self runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
    }
    
    if (!finish) {
        [NSException raise:NSRunloopTimeoutException format:@"execution of block timed out in performBlockAndWait:."];
    }
}

@end
