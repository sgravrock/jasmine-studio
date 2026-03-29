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
@class ReporterEvent;
@class JasmineRunner;


// This is not included in the delegate because enumeration is a separate
// operation from test running that has a different consumer. And it only yields
// a single completion event, making a completion callback a natural fit.
typedef void (^EnumerationCallback)(NSArray<SuiteNode *> * _Nullable result, NSError  * _Nullable error);

@protocol JasmineRunnerDelegate
- (void)jasmineRunner:(JasmineRunner *)sender runFailedWithError:(NSError *)error;
- (void)jasmineRunner:(JasmineRunner *)sender emittedReporterEvent:(ReporterEvent *)event;
// jasmineRunner:runDidOutputLine: is called when a line that *doesn't*
// reppresent a reporter event is written, e.g. a test or the code under test
// wrote to stdout.
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
