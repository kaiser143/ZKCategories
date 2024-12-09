//
//  ZKHelper.m
//  Pods
//
//  Created by zhangkai on 2024/9/9.
//  
//

#import "ZKHelper.h"
#import "ZKCategoriesMacro.h"

@interface ZKHelper ()

@end

@implementation ZKHelper

+ (void)load {
    [self manager];
}

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static ZKHelper *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    
    
    return self;
}

static NSMutableSet<NSString *> *executedIdentifiers;
+ (BOOL)executeBlock:(void (NS_NOESCAPE ^)(void))block oncePerIdentifier:(NSString *)identifier {
    if (!block || identifier.length <= 0) return NO;
    @synchronized (self) {
        if (!executedIdentifiers) {
            executedIdentifiers = NSMutableSet.new;
        }
        if (![executedIdentifiers containsObject:identifier]) {
            [executedIdentifiers addObject:identifier];
            block();
            return YES;
        }
        return NO;
    }
}

@end

@implementation ZKHelper (UIGraphic)

+ (BOOL)inspectContextIfInvalidated:(CGContextRef)context {
    if (!context) {
        ZKAssertNil(NO, @"ZKHelper (UIGraphic)", @"ZKCategories CGPostError, %@:%d %s, 非法的context：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, context, [NSThread callStackSymbols]);
        
        return NO;
    }
    return YES;
}

@end
