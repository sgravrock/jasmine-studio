//
//  SuiteNode.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import "TreeNode.h"

@implementation TreeNode

- (instancetype)initWithType:(TreeNodeType)type name:(NSString *)name {
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

- (void)updateFrom:(TreeNode *)other {
}

@end


@implementation TopSuite

- (instancetype)init {
    self = [super initWithType:TreeNodeTypeTopSuite name:@"Top suite"];
    
    if (self) {
        _status = TopSuiteStatusNotStarted;
    }
    
    return self;
}

- (void)updateFrom:(TreeNode *)other {
    if (![other isKindOfClass:[TopSuite class]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"argument to [TopSuite updateFrom:] was not a TopSuite" userInfo:nil];
    }
    
    // TODO copy other result properties
    self.status = ((TopSuite *)other).status;
}

@end


@implementation SuiteOrSpec

- (instancetype)initWithType:(TreeNodeType)type name:(NSString *)name {
    self = [super initWithType:type name:name];
    
    if (self) {
        _status = SuiteOrSpecStatusNotStarted;
    }
    
    return self;
}

- (void)updateFrom:(TreeNode *)other {
    if (![other isKindOfClass:[SuiteOrSpec class]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"argument to [SuiteOrSpec updateFrom:] was not a SuiteOrSpec" userInfo:nil];
    }
    
    // TODO copy other result properties
    self.status = ((SuiteOrSpec *)other).status;
}

@end
