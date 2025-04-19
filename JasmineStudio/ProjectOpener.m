//
//  ProjectOpener.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import <Cocoa/Cocoa.h>
#import "ProjectOpener.h"
#import "SuiteTreeViewController.h"

@interface ProjectOpener()
+ (void)showError:(NSError *)error;
+ (BOOL)baseDirHasJasmineConfig:(NSString *)baseDir;
@end


@implementation ProjectOpener

+ (void)promptAndOpenThen:(void (^)(NSWindow *))onSuccess onCancel:(void (^)(void))onCancel {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.message = @"Select a Directory";
    openPanel.prompt = @"Select";
    
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSError *error;
            NSWindow *window = [self openProjectWithBaseDir:[openPanel.URL path] error:&error];
            
            if (window) {
                onSuccess(window);
            } else {
                [self showError:error];
                [self promptAndOpenThen:onSuccess onCancel:onCancel];
            }
        } else {
            onCancel();
        }
    }];
}

+ (NSWindow *)openProjectWithBaseDir:(NSString *)baseDir error:(NSError **)error {
    // TODO: Check whether there is a plausible Jasmine config
    NSWindow *window = [[NSWindow alloc] init];
    window.contentViewController = [[SuiteTreeViewController alloc] initWithNibName:@"SuiteTreeViewController" bundle:nil];
    
    NSString *jasmineExePath = [baseDir stringByAppendingPathComponent:@"node_modules/.bin/jasmine"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:jasmineExePath]) {
        *error = [NSError errorWithDomain:@"ProjectOpener"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: @"The spedified directory does not contain a Jasmine executable."}];
        return nil;
    }
    
    if (![self baseDirHasJasmineConfig:baseDir]) {
        *error = [NSError errorWithDomain:@"ProjectOpener"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: @"The spedified directory does not contain a Jasmine configuration file."}];
        return nil;
    }

    return window;
}

+ (void)showError:(NSError *)error {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Error opening project"];
    [alert setInformativeText:[error localizedDescription]];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert runModal]; // blocks
}

+ (BOOL)baseDirHasJasmineConfig:(NSString *)baseDir {
    // TODO: Can we just ask jasmine whether there is a config file?
    NSString *configDir = [baseDir stringByAppendingPathComponent:@"spec/support"];
    NSArray *names = @[@"jasmine.mjs", @"jasmine.js", @"jasmine.json"];

    for (NSString *n in names) {
        NSString *path = [configDir stringByAppendingPathComponent:n];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
    
    return NO;
}

@end
