//
//  ExternalCommandRunner.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import "ExternalCommandRunner.h"
#import "StreamingExecution.h"
#import "Unstreamer.h"

@implementation ExternalCommandRunner

- (void)run:(NSString *)executablePath
   withArgs:(NSArray<NSString *> *)args
       path:(NSString *)path
workingDirectory:(NSString *)cwd
completionHandler:(ExternalCommandCompletionHandler)completionHandler {
    StreamingExecution *execution = [self executionForExecutable:executablePath
                                                        withArgs:args
                                                            path:path
                                                workingDirectory:cwd];
    Unstreamer *consolidator = [[Unstreamer alloc] init];
    execution.delegate = consolidator;
    __block id retainedConsolidator = consolidator;
    consolidator.onComplete = ^(int exitCode, NSData * _Nullable output, NSError * _Nullable error) {
        // Referencing consolidator here keeps it from being deallocated early
        retainedConsolidator = nil;
        // TODO: have the caller do this, for consistency with streaming below
        dispatch_async(dispatch_get_main_queue(), ^(){
            completionHandler(exitCode, output, error);
        });
    };
    
    [execution start];
}

- (void)stream:(NSString *)executablePath
      withArgs:(NSArray<NSString *> *)args
          path:(NSString *)path
workingDirectory:(NSString *)cwd
      delegate:(id<StreamingExecutionDelegate>)delegate {
    StreamingExecution *execution = [self executionForExecutable:executablePath
                                                        withArgs:args
                                                            path:path
                                                workingDirectory:cwd];
    execution.delegate = delegate;
    [execution start];
}

- (StreamingExecution*)executionForExecutable:(NSString *)executablePath
                                     withArgs:(NSArray<NSString *> *)args
                                         path:(NSString *)path
                             workingDirectory:(NSString *)cwd {
    NSTask *task = [[NSTask alloc] init];
    task.executableURL = [NSURL fileURLWithPath:executablePath];
    task.arguments = args;
    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
    [env setObject:path forKey:@"PATH"];
    task.environment = env;
    task.currentDirectoryPath = cwd;
    
    // Interleave stdout and stderr. That's much more useful for reading test suite output becuase the user will see console.error output in the context of adjacent console.log calls. This could be made configurable if there's ever a caller that needs to process stdout and stderr separately.
    NSPipe *stdoutAndStderr = [[NSPipe alloc] init];
    task.standardOutput = stdoutAndStderr;
    task.standardError = stdoutAndStderr;

    return [[StreamingExecution alloc] initWithConfiguredTask:task];
}

@end
