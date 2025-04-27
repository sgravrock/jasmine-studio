//
//  InMemoryUserDefaults.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/27/25.
//

#import "InMemoryUserDefaults.h"

@interface InMemoryUserDefaults()
@property (nonatomic, strong) NSMutableDictionary *storage;
@end

@implementation InMemoryUserDefaults

- (instancetype)init {
    self = [super init];
    self.storage = [[NSMutableDictionary alloc] init];
    return self;
}

- (id)objectForKey:(NSString *)key {
    return [self.storage objectForKey:key];
}

- (void)setObject:(id)value forKey:(NSString *)key {
    [self.storage setObject:value forKey:key];
}

// TODO: override other methods if needed

@end
