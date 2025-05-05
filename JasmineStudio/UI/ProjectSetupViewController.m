//
//  ProjectSetupViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import "ProjectSetupViewController.h"
#import "config.h"
#import "userDefaults.h"
#import "ExternalCommandRunner.h"
#import "ProjectConfig.h"

@interface ProjectSetupViewController ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@property (nonatomic, strong) NSString *projectBaseDir;
- (NSString *)path;

// These are expensive enough that we don't want to recalculate them unless something has changed.
@property (nonatomic, strong) NSString *nodePath;
@property (nonatomic, assign) BOOL hasValidProjectBaseDir;
@property (nonatomic, assign) BOOL hasValidPath;

@end

@implementation ProjectSetupViewController

- (void)configureWithUserDefaults:(NSUserDefaults *)userDefaults {
    self.userDefaults = userDefaults;
    [self restoreUserDefaults];
}

- (IBAction)cancel:(id)sender {
    self.onCancel();
}

- (IBAction)ok:(id)sender {
    [self saveUserDefaults];
    ProjectConfig *config = [[ProjectConfig alloc] initWithPath:self.path
                                                       nodePath:self.nodePath
                                                 projectBaseDir:self.projectBaseDir];
    self.onOk(config);
}

- (IBAction)selectProjectBaseDir:(id)sender {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.message = @"Select a Directory";
    openPanel.prompt = @"Select";
    
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            self.projectBaseDir = openPanel.URL.path;
            self.projectBaseDirLabel.stringValue = [self.projectBaseDir lastPathComponent];
            [self validateProjectBaseDir];
        }
    }];
}

- (NSString *)path {
    return self.pathField.stringValue;
}

#pragma mark - NSTextFieldDelegate

// This looks like a notification observer, but it's a delegate method.
// The notification doesn't directly tell us which NSTextField originated it.
// Since we only have one, we can assum it came from there. (If we had to check,
// the way to do it would be to check which field is a superview of
// notification.userInfo[@"NSFieldEditor"].
- (void)controlTextDidChange:(NSNotification *)notification NS_SWIFT_UI_ACTOR {
    [self validatePath];
}

#pragma mark - Validation

- (void)validateProjectBaseDir {
    self.hasValidProjectBaseDir = isValidProjectBaseDir(self.projectBaseDir);
    NSImage *img;
    
    if (self.hasValidProjectBaseDir) {
         img = [NSImage imageWithSystemSymbolName:@"checkmark.circle.fill"
                         accessibilityDescription:@"Project base dir OK"];
    } else {
        // TODO: provide more specific help than this
        img = [NSImage imageNamed:NSImageNameCaution];
        img.accessibilityDescription = @"Invalid project base dir";
    }

    self.projectBaseDirStateIndicator.image = img;
    [self updateOkButton];
}


- (void)validatePath {
    // TODO: allow empty? Pre-populate with existing PATH?
    NSLog(@"in validatePath: %@", self.path);
    if (self.path.length == 0) {
        self.hasValidPath = NO;
        self.nodePath = nil;
        [self pathValidityDidChange];
        return;
    }
    
    // The path is considered valid if we can find a Node executable in it
    ExternalCommandRunner *runner = [[ExternalCommandRunner alloc] init];
    __weak ProjectSetupViewController *weakSelf = self;
    [runner run:@"/usr/bin/which"
       withArgs:@[@"node"]
           path:self.path
workingDirectory:@"/"
completionHandler:^(int exitCode, NSData * _Nullable output, NSError * _Nullable error) {
        NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        NSLog(@"code: %d, output: %@", exitCode, outputString);
        NSLog(@"Error: %@", [error localizedDescription]);
        weakSelf.hasValidPath = exitCode == 0;
    
        if (weakSelf.hasValidPath) {
            NSString *s = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
            NSCharacterSet *newline = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
            weakSelf.nodePath = [s stringByTrimmingCharactersInSet:newline];
        }

        [weakSelf pathValidityDidChange];
    }];
}

- (void)pathValidityDidChange {
    NSImage *img;

    if (self.hasValidPath) {
        img = [NSImage imageWithSystemSymbolName:@"checkmark.circle.fill"
                        accessibilityDescription:@"Node path OK"];
    } else {
        img = [NSImage imageNamed:NSImageNameCaution];
        img.accessibilityDescription = @"Invalid PATH";
    }

    self.nodePathStatusIndicator.image = img;
    self.nodePathStatusMsg.hidden = self.hasValidPath;
    [self updateOkButton];
}

- (void)updateOkButton {
    self.okButton.enabled = self.hasValidProjectBaseDir && self.hasValidPath;
}

- (void)saveUserDefaults {
    [self.userDefaults setObject:self.projectBaseDir forKey:kProjectBaseDirKey];
    [self.userDefaults setObject:self.path forKey:kPathKey];
}

- (void)restoreUserDefaults {
    id projectBaseDir = [self.userDefaults objectForKey:kProjectBaseDirKey];
    id path = [self.userDefaults objectForKey:kPathKey];
    
    if ([projectBaseDir isKindOfClass:[NSString class]]) {
        self.projectBaseDir = projectBaseDir;
        self.projectBaseDirLabel.stringValue = projectBaseDir;
        [self validateProjectBaseDir];
    }
    
    if ([path isKindOfClass:[NSString class]]) {
        self.pathField.stringValue = path;
        [self validatePath];
    }
}

@end
