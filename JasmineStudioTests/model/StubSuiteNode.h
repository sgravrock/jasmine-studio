//
//  StubSuiteNode.h
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/29/25.
//

#import "TreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface StubSuiteNode : SuiteOrSpec

@property (nonatomic, readonly, strong) NSArray<NSString *> *path;

- (instancetype)initWithType:(TreeNodeType)type
                        path:(NSArray<NSString *> *)path;

@end

NS_ASSUME_NONNULL_END
