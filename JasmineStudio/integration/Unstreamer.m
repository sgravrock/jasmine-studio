//
//  Unstreamer.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 5/4/25.
//

#import "Unstreamer.h"

@interface Unstreamer()
@property (nonatomic, strong) NSMutableData *output;
@end

@implementation Unstreamer


- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.output = [NSMutableData data];
    }
    
    return self;
}

- (void)streamingExecution:(nonnull StreamingExecution *)sender
         finishedWithError:(nonnull NSError *)error {
    self.onComplete(-1, nil, error);
}

- (void)streamingExecution:(nonnull StreamingExecution *)sender
      finishedWithExitCode:(int)exitCode {
    self.onComplete(exitCode, self.output, nil);
}

- (void)streamingExecution:(nonnull StreamingExecution *)sender
            readOutputLine:(nonnull NSData *)line {
    [self.output appendData:line];
    [self.output appendBytes:"\n" length:1];
}

@end
