//
//  ProjectSetupViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class ProjectConfig;

@interface ProjectSetupViewController : NSViewController<NSTextFieldDelegate>

@property (nonatomic, strong) void (^onCancel)(void);
@property (nonatomic, strong) void (^onOk)(ProjectConfig *config);

@property (nonatomic, weak) IBOutlet NSTextField *projectBaseDirLabel;
@property (nonatomic, weak) IBOutlet NSImageCell *projectBaseDirStateIndicator;
@property (weak) IBOutlet NSTextField *pathField;
@property (weak) IBOutlet NSImageView *nodePathStatusIndicator;
@property (weak) IBOutlet NSTextField *nodePathStatusMsg;
@property (weak) IBOutlet NSButton *okButton;
- (IBAction)selectProjectBaseDir:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

-(void)configureWithUserDefaults:(NSUserDefaults *)userDefaults;

@end

NS_ASSUME_NONNULL_END
