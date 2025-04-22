//
//  ExternalCommand.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import "ExternalCommand.h"

@interface ExternalCommand()
// Configuration
@property (atomic, strong) NSURL *executable;
@property (atomic, strong) NSArray<NSString *> *args;
@property (atomic, strong) NSString *cwd;
@property (atomic, strong) ExternalCommandCompletionHandler completionHandler;

// State
@property (atomic, assign) BOOL exited;
@property (atomic, assign) BOOL doneReading;
@property (atomic, assign) int exitCode;
@property (atomic, strong) NSData *output; // nil until all output is read
@property (atomic, strong) NSError *readError;
@end

@implementation ExternalCommand

+ (void)run:(NSString *)executablePath
   withArgs:(NSArray<NSString *> *)args
inDirectory:(NSString *)cwd
completionHandler:(ExternalCommandCompletionHandler)completionHandler {
    ExternalCommand *cmd = [[ExternalCommand alloc]
                            initWithExecutable:[NSURL fileURLWithPath:executablePath]
                            args:args
                            workingDirectory:cwd
                            completionHandler:completionHandler];
    [cmd start];
}

- (instancetype)initWithExecutable:(NSURL *)executable
                              args:(NSArray<NSString *> *)args
                  workingDirectory:(NSString *)cwd
                 completionHandler:(ExternalCommandCompletionHandler)completionHandler {
    self = [[ExternalCommand alloc] init];
    self.executable = executable;
    self.args = args;
    self.cwd = cwd;
    self.completionHandler = completionHandler;
    self.doneReading = self.exited = NO;
    self.exitCode = INT_MAX;
    self.output = nil;
    self.readError = nil;
    return self;
}

- (void)start {
    NSTask *task = [[NSTask alloc] init];
    task.executableURL = self.executable;
    task.arguments = self.args;
    task.currentDirectoryPath = self.cwd;
    
    // Interleave stdout and stderr. That's much more useful for reading test suite output becuase the user will see console.error output in the context of adjacent console.log calls. This could be made configurable if there's ever a caller that needs to process stdout and stderr separately.
    NSPipe *stdoutAndStderr = [[NSPipe alloc] init];
    task.standardOutput = stdoutAndStderr;
    task.standardError = stdoutAndStderr;
    
    NSError *error = nil;
    BOOL launched = [task launchAndReturnError:&error];
    
    if (!launched) {
        self.completionHandler(INT_MAX, nil, error);
        return;
    }
    
    // Read output and wait for completion in parallel, to prevent both deadlock and early exit.
    [self performSelectorInBackground:@selector(readOutput:)
                           withObject:stdoutAndStderr];
    [self performSelectorInBackground:@selector(waitUntilExit:)
                           withObject:task];
}

// Should be called on a background thread
- (void)readOutput:(NSPipe *)pipe {
    @autoreleasepool {
        NSError *error = nil;
        NSData *output = [pipe.fileHandleForReading readDataToEndOfFileAndReturnError:&error];
        
        if (output == nil) {
            self.readError = error;
        } else {
            self.output = output;
        }
        
        self.doneReading = YES;
        [self checkCompletion];
    }
}

// Should be called on a background thread
- (void)waitUntilExit:(NSTask *)task {
    @autoreleasepool {
        [task waitUntilExit];
        self.exitCode = task.terminationStatus;
        self.exited = YES;
        [self checkCompletion];
    }
}

// Should be called on a background thread
- (void)checkCompletion {
    if (self.exited && self.doneReading) {
        [self performSelectorOnMainThread:@selector(reportCompletion) withObject:nil waitUntilDone:NO];
    }
}

// Should be called on the main thread
// Precondition: self.exited && self.doneReading
- (void)reportCompletion {
    if (self.readError) {
        self.completionHandler(self.exitCode, nil, self.readError);
    } else {
        self.completionHandler(self.exitCode, self.output, nil);
    }
}

@end
