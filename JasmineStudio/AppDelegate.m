//
//  AppDelegate.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import "AppDelegate.h"
#import "ProjectSetupViewController.h"
#import "SuiteTreeViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ProjectSetupViewController *setupController = [[ProjectSetupViewController alloc] initWithNibName:@"ProjectSetupViewController" bundle:nil];
    NSWindow *setupWindow = [[NSWindow alloc] init];
    setupWindow.contentViewController = setupController;
    
    setupController.onCancel = ^{
        exit(0);
    };
    
    setupController.onOk = ^(NSString * _Nonnull projectBaseDir, NSString * _Nonnull nodePath) {
        [setupWindow close];
        NSWindow *runnerWindow = [[NSWindow alloc] init];
        runnerWindow.contentViewController = [[SuiteTreeViewController alloc] initWithNibName:@"SuiteTreeViewController" bundle:nil];
        [runnerWindow makeKeyAndOrderFront:self];

    };
    
    [setupWindow makeKeyAndOrderFront:self];
}

@end
