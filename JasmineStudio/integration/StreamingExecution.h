//
//  StreamingExecution.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 5/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class StreamingExecution;


@protocol StreamingExecutionDelegate

// Delegate methods may be called on a background thread.

// Either of these two methods will be called exactly once per execution,
// even if the child process fails to start.
- (void)streamingExecution:(StreamingExecution *)sender
      finishedWithExitCode:(int)exitCode;
- (void)streamingExecution:(StreamingExecution *)sender
      finishedWithError:(NSError *)error;

- (void)streamingExecution:(StreamingExecution *)sender
            readOutputLine:(NSData *)line;

@end


@interface StreamingExecution : NSObject

@property (nonatomic, weak) id<StreamingExecutionDelegate> delegate;

- (instancetype)initWithConfiguredTask:(NSTask *)task;
- (void)start;

@end

NS_ASSUME_NONNULL_END
