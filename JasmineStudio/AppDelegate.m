//
//  AppDelegate.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import "AppDelegate.h"
#import "ProjectSetupViewController.h"
#import "RunnerViewController.h"
#import "Jasmine.h"
#import "ExternalCommandRunner.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *setupWindowController = [sb instantiateControllerWithIdentifier:@"projectSetup"];
    ProjectSetupViewController *setupViewController = (ProjectSetupViewController *)setupWindowController.window.contentViewController;
    [setupViewController configureWithUserDefaults:[NSUserDefaults standardUserDefaults]];
    
    setupViewController.onCancel = ^{
        exit(0);
    };
    
    setupViewController.onOk = ^(ProjectConfig * _Nonnull config) {
        [setupWindowController.window close];
        NSWindowController *runnerWindowController = [sb instantiateControllerWithIdentifier:@"runnerWindowController"];
        RunnerViewController *runnerViewController = (RunnerViewController *)runnerWindowController.window.contentViewController;
        runnerViewController.jasmine = [[Jasmine alloc] initWithConfig:config commandRunner:[[ExternalCommandRunner alloc] init]];
        [runnerViewController loadSuite];
        [runnerWindowController.window makeKeyAndOrderFront:self];
    };
    
    [setupWindowController.window makeKeyAndOrderFront:self];
}

@end
