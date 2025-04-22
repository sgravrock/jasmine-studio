//
//  ExternalCommand.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// ExternalCommand uns a command, reads its interleaved stdin and stdout, and reports the result. Does not block the main thread.


typedef void (^ExternalCommandCompletionHandler)(int exitCode,  NSData * _Nullable output, NSError * _Nullable error);

@interface ExternalCommand : NSObject

+ (void)run:(NSString *)executablePath withArgs:(NSArray<NSString *> *)args inDirectory:(NSString *)cwd completionHandler:(ExternalCommandCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
