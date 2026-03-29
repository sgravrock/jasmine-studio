//
//  StubSuiteNode.h
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/29/25.
//

#import "SuiteOrSpec.h"

NS_ASSUME_NONNULL_BEGIN

@interface StubSuiteNode : SuiteOrSpec

@property (nonatomic, readonly, strong) NSArray<NSString *> *path;

- (instancetype)initWithType:(SuiteOrSpecType)type
                        path:(NSArray<NSString *> *)path;

@end

NS_ASSUME_NONNULL_END
