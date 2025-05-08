//
//  MockTask.h
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 5/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Implements enough of NSTask's interface
// Doesn't subclass NSTask to avoid accidentally doing child process things.
// Users should cast to NSTask *.
@interface MockTask : NSObject

// Types match NSTask; could be either an NSFileHandle or an NSPipe
@property (nullable, retain) id standardOutput;
@property (nullable, retain) id standardError;

@property (assign) int terminationStatus;

// Mock configuration methods
- (void)failLaunchWithError:(NSError *)error;

// NSTask methods
- (BOOL)launchAndReturnError:(out NSError **_Nullable)error;
- (void)waitUntilExit;


@end

NS_ASSUME_NONNULL_END
