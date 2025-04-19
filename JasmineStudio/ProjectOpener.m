//
//  ProjectOpener.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import <Cocoa/Cocoa.h>
#import "ProjectOpener.h"
#import "SuiteTreeViewController.h"

@implementation ProjectOpener

+ (void)promptAndOpenThen:(void (^)(NSWindow *window))onSuccess onFailure:(void (^)(void))onFailure {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.message = @"Select a Directory";
    openPanel.prompt = @"Select";
    
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSWindow * window = [self openProjectWithBaseDir:openPanel.URL];
            onSuccess(window);
        } else {
            onFailure();
        }
    }];
}

+ (NSWindow *)openProjectWithBaseDir:(NSURL *)baseDir {
    // TODO: Check whether there is a plausible Jasmine config
    NSWindow *window = [[NSWindow alloc] init];
    window.contentViewController = [[SuiteTreeViewController alloc] initWithNibName:@"SuiteTreeViewController" bundle:nil];
    return window;
}


@end
