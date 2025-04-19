//
//  AppDelegate.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import "AppDelegate.h"
#import "SuiteTreeViewController.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.message = @"Select a Directory";
    openPanel.prompt = @"Select";
    
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            [self openProjectWithBaseDir:openPanel.URL windowOwner:self];
        } else {
            exit(0);
        }
    }];
}

- (void)openProjectWithBaseDir:(NSURL *)baseDir windowOwner:(id)windowOwner {
    // TODO: Check whether there is a plausible Jasmine config
    NSWindow *window = [[NSWindow alloc] init];
    window.contentViewController = [[SuiteTreeViewController alloc] initWithNibName:@"SuiteTreeViewController" bundle:nil];
    [window makeKeyAndOrderFront:self];
    self.window = window;
}

@end
