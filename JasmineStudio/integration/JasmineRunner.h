//
//  Jasmine.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>
#import "SuiteNode.h"
#import "StreamingExecution.h"

NS_ASSUME_NONNULL_BEGIN

@class ProjectConfig;
@class ExternalCommandRunner;
@class JasmineRunner;


// TODO: fold into delegate?
typedef void (^EnumerationCallback)(NSArray<SuiteNode *> * _Nullable result, NSError  * _Nullable error);

@protocol JasmineRunnerDelegate
- (void)jasmineRunner:(JasmineRunner *)sender runFailedWithError:(NSError *)error;
// TODO: richer output than just raw text
- (void)jasmineRunner:(JasmineRunner *)sender runDidOutputLine:(NSString *)line;
- (void)jasmineRunner:(JasmineRunner *)sender runFinishedWithExitCode:(int)exitCode;
@end


@interface JasmineRunner : NSObject<StreamingExecutionDelegate>

@property (nonatomic, readonly, strong) ProjectConfig *config;
@property (nonatomic, weak) id<JasmineRunnerDelegate> delegate;

- (instancetype)initWithConfig:(ProjectConfig *)config
                 commandRunner:(ExternalCommandRunner *)commandRunner;
- (void)enumerateWithCallback:(EnumerationCallback)callback;
- (void)runNode:(SuiteNode *)node;

@end

NS_ASSUME_NONNULL_END
