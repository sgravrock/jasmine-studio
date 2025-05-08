//
//  MockExternalCommandRunner.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/29/25.
//

#import "MockExternalCommandRunner.h"

@implementation MockExternalCommandRunner

- (void)run:(NSString *)executablePath
   withArgs:(NSArray<NSString *> *)args
       path:(NSString *)path
workingDirectory:(NSString *)cwd
completionHandler:(ExternalCommandCompletionHandler)completionHandler {
    self.lastExecutablePath = executablePath;
    self.lastArgs = args;
    self.lastCwd = cwd;
    self.lastCompletionHandler = completionHandler;
}

- (void)stream:(NSString *)executablePath
      withArgs:(NSArray<NSString *> *)args
          path:(NSString *)path
   workingDirectory:(NSString *)cwd
      delegate:(id<StreamingExecutionDelegate>)delegate {
    self.lastExecutablePath = executablePath;
    self.lastArgs = args;
    self.lastCwd = cwd;
    self.lastDelegate = delegate;
}
@end
