//
//  RunnerWindowController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunnerWindowController : NSWindowController

- (void)initProjectWithBaseDir:(NSURL *)baseDir;

@end

NS_ASSUME_NONNULL_END
