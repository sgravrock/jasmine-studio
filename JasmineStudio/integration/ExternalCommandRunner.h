//
//  ExternalCommandRunner.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import <Foundation/Foundation.h>
#import "StreamingExecution.h"

NS_ASSUME_NONNULL_BEGIN

// ExternalCommand uns a command, reads its interleaved stdin and stdout, and reports the result. Does not block the main thread.


typedef void (^ExternalCommandCompletionHandler)(int exitCode,  NSData * _Nullable output, NSError * _Nullable error);

@interface ExternalCommandRunner : NSObject

// TODO: Make this all delegate-based?
- (void)run:(NSString *)executablePath
   withArgs:(NSArray<NSString *> *)args
       path:(NSString *)path
workingDirectory:(NSString *)cwd
completionHandler:(ExternalCommandCompletionHandler)completionHandler;

- (void)stream:(NSString *)executablePath
      withArgs:(NSArray<NSString *> *)args
          path:(NSString *)path
   workingDirectory:(NSString *)cwd
      delegate:(id<StreamingExecutionDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
