//
//  SuiteNode.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import "SuiteNode.h"

@implementation SuiteNode

- (instancetype)initWithType:(SuiteNodeType)type name:(NSString *)name {
    self = [super init];
    
    if (self) {
        _type = type;
        _name = name;
        _children = [NSMutableArray array];
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
