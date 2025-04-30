//
//  StubSuiteNode.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/29/25.
//

#import "StubSuiteNode.h"

@implementation StubSuiteNode

- (instancetype)initWithType:(SuiteNodeType)type
                        path:(NSArray<NSString *> *)path {
    self = [super initWithType:type name:[path lastObject]];
    
    if (self) {
        _path = path;
    }
    
    return self;
}

@end
