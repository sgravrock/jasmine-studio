//
//  MockExternalCommandRunner.h
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/29/25.
//

#import "ExternalCommandRunner.h"

NS_ASSUME_NONNULL_BEGIN

@interface MockExternalCommandRunner : ExternalCommandRunner

@property (nonatomic, strong) NSString *lastExecutablePath;
@property (nonatomic, strong) NSArray<NSString *> *lastArgs;
@property (nonatomic, strong) NSString *lastCwd;
@property (nonatomic, strong) ExternalCommandCompletionHandler lastCompletionHandler;
@property (nonatomic, strong) id<StreamingExecutionDelegate> lastDelegate;

@end

NS_ASSUME_NONNULL_END
