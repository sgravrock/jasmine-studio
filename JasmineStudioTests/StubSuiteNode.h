//
//  StubSuiteNode.h
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/29/25.
//

#import "SuiteNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface StubSuiteNode : SuiteNode

@property (nonatomic, readonly, strong) NSArray<NSString *> *path;

- (instancetype)initWithType:(SuiteNodeType)type
                        path:(NSArray<NSString *> *)path;

@end

NS_ASSUME_NONNULL_END
