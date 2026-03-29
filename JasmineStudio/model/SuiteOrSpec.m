//
//  SuiteNode.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import "SuiteOrSpec.h"

@implementation SuiteOrSpec

- (instancetype)initWithType:(SuiteOrSpecType)type name:(NSString *)name {
    self = [super init];
    
    if (self) {
        _type = type;
        _name = name;
        _children = [NSMutableArray array];
        _status = SuiteOrSpecStatusNotStarted;
    }
    
    return self;
}

- (NSArray<NSString *> *)path {
    if (!self.parent) {
        return @[self.name];
    }
    
    return [[self.parent path] arrayByAddingObject:self.name];    
}

@end
