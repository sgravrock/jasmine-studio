//
//  ProjectSetupViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProjectSetupViewController : NSViewController<NSTextFieldDelegate>

@property (nonatomic, strong) void (^onCancel)(void);
@property (nonatomic, strong) void (^onOk)(NSString *projectBaseDir, NSString *nodePath);

@end

NS_ASSUME_NONNULL_END
