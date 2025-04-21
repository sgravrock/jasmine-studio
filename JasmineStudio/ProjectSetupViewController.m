//
//  ProjectSetupViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import "ProjectSetupViewController.h"
#import "config.h"

@interface ProjectSetupViewController ()

@property (nonatomic, strong) NSString *projectBaseDir;
- (NSString *)nodePath;

// These are expensive enough that we don't want to recalculate them unless something has changed.
@property (nonatomic, assign) BOOL hasValidProjectBaseDir;
@property (nonatomic, assign) BOOL hasValidNodePath;

@property (nonatomic, weak) IBOutlet NSTextField *projectBaseDirLabel;
@property (nonatomic, weak) IBOutlet NSImageCell *projectBaseDirStateIndicator;
@property (weak) IBOutlet NSTextField *nodePathField;
@property (weak) IBOutlet NSImageView *nodePathStatusIndicator;
@property (weak) IBOutlet NSButton *okButton;
- (IBAction)selectProjectBaseDir:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@implementation ProjectSetupViewController

- (IBAction)cancel:(id)sender {
    self.onCancel();
}

- (IBAction)ok:(id)sender {
    self.onOk(self.projectBaseDir, self.nodePath);
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

- (NSString *)nodePath {
    return self.nodePathField.stringValue;
}

#pragma mark - NSTextFieldDelegate

// This looks like a notification observer, but it's a delegate method.
// The notification doesn't directly tell us which NSTextField originated it.
// Since we only have one, we can assum it came from there. (If we had to check,
// the way to do it would be to check which field is a superview of
// notification.userInfo[@"NSFieldEditor"].
- (void)controlTextDidChange:(NSNotification *)notification NS_SWIFT_UI_ACTOR {
    [self validateNodePath];
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
    self.okButton.enabled = self.hasValidProjectBaseDir && self.hasValidNodePath;
}


- (void)validateNodePath {
    self.hasValidNodePath = isValidNodePath(self.nodePath);
    NSImage *img;
    
    if (self.hasValidNodePath) {
        img = [NSImage imageWithSystemSymbolName:@"checkmark.circle.fill"
                        accessibilityDescription:@"Node path OK"];
    } else {
        // TODO: provide more specific help than this
        img = [NSImage imageNamed:NSImageNameCaution];
        img.accessibilityDescription = @"Invalid project base dir";
    }

    self.nodePathStatusIndicator.image = img;
    self.okButton.enabled = self.hasValidProjectBaseDir && self.hasValidNodePath;
}

@end
