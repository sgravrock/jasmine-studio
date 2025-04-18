//
//  RunnerWindowController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import "RunnerWindowController.h"

@interface RunnerWindowController ()

@property (nonatomic, strong) NSURL *baseDir;

- (void)initUIIfReady;

@end

@implementation RunnerWindowController

- (NSNibName)windowNibName {
    return @"RunnerWindowController";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self initUIIfReady];
}

- (void)initProjectWithBaseDir:(NSURL *)baseDir {
    self.baseDir = baseDir;
    [self initUIIfReady];
}

- (void)initUIIfReady {
    if (self.baseDir && self.windowLoaded) {
        self.window.title = [self.baseDir lastPathComponent];
    }
}

@end
