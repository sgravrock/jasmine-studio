//
//  MockTask.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 5/4/25.
//

#import "MockTask.h"

@interface MockTask()
@property (atomic, strong) NSError *launchError;
@end

@implementation MockTask

- (void)failLaunchWithError:(NSError *)error {
    self.launchError = error;
}

// NSTask methods
- (BOOL)launchAndReturnError:(out NSError **_Nullable)error {
    *error = self.launchError;
    return self.launchError == nil;
}

- (void)waitUntilExit {
    // TODO
}


@end
