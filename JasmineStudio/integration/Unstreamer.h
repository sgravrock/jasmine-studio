//
//  Unstreamer.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 5/4/25.
//

#import <Foundation/Foundation.h>
#import "StreamingExecution.h"

NS_ASSUME_NONNULL_BEGIN

@interface Unstreamer : NSObject<StreamingExecutionDelegate>

@property (nonatomic, strong) void (^onComplete)(int exitCode,  NSData * _Nullable output, NSError * _Nullable error);

@end

NS_ASSUME_NONNULL_END
