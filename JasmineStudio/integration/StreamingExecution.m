//
//  StreamingExecution.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 5/4/25.
//

#import "StreamingExecution.h"

@interface StreamingExecution()
@property (atomic, strong) NSTask *task;
@property (atomic, assign) BOOL exited;
@property (atomic, assign) int exitCode;
@end

@implementation StreamingExecution

- (instancetype)initWithConfiguredTask:(NSTask *)task {
    self = [super init];
    self.task = task;
    return self;
}

- (void)start {
    self.exited = NO;
    
    // Interleave stdout and stderr. That's much more useful for reading test suite output becuase the user will see console.error output in the context of adjacent console.log calls. This could be made configurable if there's ever a caller that needs to process stdout and stderr separately.
    NSPipe *stdoutAndStderr = [[NSPipe alloc] init];
    self.task.standardOutput = stdoutAndStderr;
    self.task.standardError = stdoutAndStderr;
    
    NSError *error = nil;
    BOOL launched = [self.task launchAndReturnError:&error];
    
    if (!launched) {
        [self.delegate streamingExecution:self finishedWithError:error];
        return;
    }
    
    // Read output and wait for completion in parallel, to prevent both deadlock and early exit.
    [self performSelectorInBackground:@selector(readOutput:)
                           withObject:stdoutAndStderr.fileHandleForReading];
    [self performSelectorInBackground:@selector(waitUntilExit)
                           withObject:nil];
}

// Should be called on a background thread
- (void)readOutput:(NSFileHandle *)fh {
    @autoreleasepool {
        NSError *error = nil;
        NSMutableData *pendingOutput = [NSMutableData data];
        
        while (!error && !self.exited) {
            [self readOutputChunkFrom:fh into:pendingOutput error:&error];
        }
        
        if (!error) {
            // Read and flush any remaining output
            while ([self readOutputChunkFrom:fh into:pendingOutput error:&error])
                ;;
            
            // If the last line didn't end with a newline, it'll still be buffered.
            if (pendingOutput.length > 0) {
                [self.delegate streamingExecution:self readOutputLine:pendingOutput];
            }
        }
                
        if (error) {
            [self.delegate streamingExecution:self finishedWithError:error];
        } else {
            [self.delegate streamingExecution:self finishedWithExitCode:self.exitCode];
        }
    }
}

// Should be called on a background thread
- (BOOL)readOutputChunkFrom:(NSFileHandle *)fh
                       into:(NSMutableData *)pendingOutput
                      error:(NSError **)error {
    // readDataUpToLength:error: is under-documented but it's likely that it
    // just issues read() calls in a loop until it either gets the requested
    // number of bytes or reaches EOF.
    // 40 bytes is an attempt to balance throughput (especially when reading
    // enumeration output) with latency (especially when reading run output).
    // If that doesn't prove good enough, alternatives might include switching
    // to readInBackgroundAndNotify or using raw system calls.
    NSData *chunk = [fh readDataUpToLength:40 error:error];

    if (*error) {
        return NO;
    }
    
    [pendingOutput appendData:chunk];
    [self tryFlushOutput:pendingOutput];
    return chunk.length > 0;
}

// Should be called on a background thread
- (void)tryFlushOutput:(NSMutableData *)pendingOutput {
    // Newlines (and everything else in the range 0x00..0x7F) are guaranteed
    // not to occur as part of any other Unicode code point, so this is safe
    // as long as the output is some flavor of Unicode.
    // Doing it this way rather than converting to a string first means we don't
    // need to worry about the case where we've only read half of a code point.
    char *nl;
    
    while ((nl = memchr(pendingOutput.mutableBytes, '\n', pendingOutput.length))) {
        if (nl == (char *)pendingOutput.mutableBytes + pendingOutput.length - 1) {
            // Line is the entire buffer
            NSData *chunk = [NSData dataWithData:pendingOutput];
            [self.delegate streamingExecution:self readOutputLine:chunk];
            pendingOutput.length = 0;
        } else {
            NSUInteger chunkLen = (nl + 1) - (char *)pendingOutput.mutableBytes;
            NSData *chunk = [NSData dataWithBytes:pendingOutput.mutableBytes
                                           length:chunkLen];
            [self.delegate streamingExecution:self readOutputLine:chunk];
            NSUInteger restLen = pendingOutput.length - chunkLen ;
            memmove(pendingOutput.mutableBytes, nl + 1, restLen);
            pendingOutput.length = restLen;
        }
    }
}

// Should be called on a background thread
- (void)waitUntilExit {
    @autoreleasepool {
        [self.task waitUntilExit];
        self.exitCode = self.task.terminationStatus;
        self.exited = YES;
    }
}


@end
