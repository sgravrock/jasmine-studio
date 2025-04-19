//
//  AppDelegate.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import "AppDelegate.h"
#import "ProjectOpener.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [ProjectOpener promptAndOpenThen:^(NSWindow * _Nonnull window) {
        [window makeKeyAndOrderFront:self];
    } onCancel:^{
        exit(0);
    }];
}

@end
