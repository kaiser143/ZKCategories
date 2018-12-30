//
//  NSArray+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "NSArray+ZKAdd.h"

@implementation NSArray (ZKAdd)

- (NSArray *)filter:(BOOL(^)(id object))condition{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return condition(evaluatedObject);
    }]];
}

- (NSArray *)ignore:(id)value {
    return [self filter:^BOOL(id object) {
        return object != value && ![object isEqual:value];
    }];
}

- (NSArray *)map:(id(^)(id obj, NSUInteger idx))block {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id currentObject, NSUInteger index, BOOL *stop) {
        id mappedCurrentObject = block(currentObject, index);
        if (mappedCurrentObject) {
            [result addObject:mappedCurrentObject];
        }
    }];
    return result;
}

- (NSArray *)flattenMap:(id(^)(id obj, NSUInteger idx))block{
    NSMutableArray* results = [NSMutableArray new];
    [self each:^(NSArray* array) {
        [results addObject:[array map:^id(id obj, NSUInteger idx) {
            return block(obj,idx);
        }]];
    }];
    return results;
}

- (NSArray *)flattenMap:(NSString*)key block:(id(^)(id obj, NSUInteger idx))block{
    NSMutableArray* results = [NSMutableArray new];
    [self each:^(id object) {
        [results addObject:[[object valueForKey:key] map:^id(id obj, NSUInteger idx) {
            return block(obj,idx);
        }]];
    }];
    return results;
}

- (void)each:(void(^)(id object))operation{
    [self enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        operation(object);
    }];
}

- (id)objectPassingTest:(BOOL(^)(id))block {
    NSCParameterAssert(block != NULL);
    
    return [self filter:block].firstObject;
}

//==============================================
#pragma mark - Operators
//==============================================
- (NSNumber *)operator:(NSString *)operator keypath:(NSString *)keypath{
    NSString* finalKeyPath;
    if(keypath != nil)
        finalKeyPath = [NSString stringWithFormat:@"%@.@%@.self",keypath, operator];
    else
        finalKeyPath = [NSString stringWithFormat:@"@%@.self",operator];
    
    return [self valueForKeyPath:finalKeyPath];
}

- (NSNumber *)sum                    { return [self operator:@"sum" keypath:nil];    }
- (NSNumber *)sum:(NSString*)keypath { return [self operator:@"sum" keypath:keypath];}
- (NSNumber *)avg                    { return [self operator:@"avg" keypath:nil];    }
- (NSNumber *)avg:(NSString*)keypath { return [self operator:@"avg" keypath:keypath];}
- (NSNumber *)max                    { return [self operator:@"max" keypath:nil];    }
- (NSNumber *)max:(NSString*)keypath { return [self operator:@"max" keypath:keypath];}
- (NSNumber *)min                    { return [self operator:@"min" keypath:nil];    }
- (NSNumber *)min:(NSString*)keypath { return [self operator:@"min" keypath:keypath];}

- (NSUInteger)countKeyPath:(NSString*)keypath{
    return [self flatten:keypath].count;
}

- (NSArray*)flatten:(NSString*)keypath{
    NSMutableArray* results = [NSMutableArray new];
    [self each:^(id object) {
        [results addObjectsFromArray:[object valueForKeyPath:keypath]];
    }];
    return results;
}

@end
