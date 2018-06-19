//
//  NSDictionary+ZKAdd.h
//  Pods
//
//  Created by Kaiser on 2017/1/11.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ZKAdd)

- (NSString *)URLEncodedStringValue;

/// Merges the keys and values from the given dictionary into the receiver. If
/// both the receiver and `dictionary` have a given key, the value from
/// `dictionary` is used.
///
/// Returns a new dictionary containing the entries of the receiver combined with
/// those of `dictionary`.
- (NSDictionary *)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary;

/// Creates a new dictionary with all the entries for the given keys removed from
/// the receiver.
- (NSDictionary *)dictionaryByRemovingValuesForKeys:(NSArray *)keys;

@end
