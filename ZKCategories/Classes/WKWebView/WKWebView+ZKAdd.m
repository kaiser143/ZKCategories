//
//  WKWebView+ZKAdd.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/6/15.
//

#import "WKWebView+ZKAdd.h"
#import "UIView+ZKAdd.h"

@implementation WKWebView (ZKAdd)

// Simulate People Action, all the `fixed` element will be repeate
// SwContentCapture will capture all content without simulate people action, more perfect.
- (void)KAIContentScrollCaptureCompletionHandler:(void(^)(UIImage *_Nullable capturedImage))completionHandler {
    // Put a fake Cover of View
    UIView *snapShotView = [self snapshotViewAfterScreenUpdates:YES];
    snapShotView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, snapShotView.frame.size.width, snapShotView.frame.size.height);
    [self.superview addSubview:snapShotView];
    
    // Backup
    CGPoint bakOffset = self.scrollView.contentOffset;
    
    // Divide
    float page = floorf(self.scrollView.contentSize.height/self.bounds.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.scrollView.contentSize, NO, [UIScreen mainScreen].scale);
    
    [self KAIContentScrollPageDraw:0 maxIndex:(int)page drawCallback:^{
        UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Recover
        [self.scrollView setContentOffset:bakOffset animated:false];
        [snapShotView removeFromSuperview];
        
        completionHandler(capturedImage);
    }];
}

//滑动画了再截图
- (void)KAIContentScrollPageDraw:(int)index maxIndex:(int)maxIndex drawCallback:(void(^)(void))drawCallback{
    [self.scrollView setContentOffset:CGPointMake(0, (float)index * self.scrollView.frame.size.height)];
    
    CGRect splitFrame = CGRectMake(0, (float)index * self.scrollView.frame.size.height, self.bounds.size.width, self.bounds.size.height);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self drawViewHierarchyInRect:splitFrame afterScreenUpdates:YES];
        
        if(index<maxIndex){
            [self KAIContentScrollPageDraw:index + 1 maxIndex:maxIndex drawCallback:drawCallback];
        }else{
            drawCallback();
        }
    });
}

@end
