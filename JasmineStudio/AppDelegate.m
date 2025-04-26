//
//  AppDelegate.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import "AppDelegate.h"
#import "ProjectSetupViewController.h"
#import "SuiteTreeViewController.h"
#import "Jasmine.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *setupWindowController = [sb instantiateControllerWithIdentifier:@"projectSetup"];
    ProjectSetupViewController *setupViewController = (ProjectSetupViewController *)setupWindowController.window.contentViewController;
    
    setupViewController.onCancel = ^{
        exit(0);
    };
    
    setupViewController.onOk = ^(NSString * _Nonnull projectBaseDir, NSString * _Nonnull nodePath) {
        [setupWindowController.window close];
        NSWindowController *runnerWindowController = [sb instantiateControllerWithIdentifier:@"suiteTreeViewWindowController"];
        SuiteTreeViewController *runnerViewController = (SuiteTreeViewController *)runnerWindowController.window.contentViewController;
        runnerViewController.jasmine = [[Jasmine alloc] initWithBaseDir:projectBaseDir nodePath:nodePath];
        [runnerViewController loadTree];
        [runnerWindowController.window makeKeyAndOrderFront:self];
    };
    
    [setupWindowController.window makeKeyAndOrderFront:self];
}

@end
