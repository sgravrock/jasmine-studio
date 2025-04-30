//
//  SuiteTreeViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import <Cocoa/Cocoa.h>
#import "OutlineViewWithContextMenu.h"
#import "Models.h"

NS_ASSUME_NONNULL_BEGIN

@class SuiteTreeViewController;

@protocol SuiteTreeViewControllerDelegate
- (void)suiteTreeViewController:(SuiteTreeViewController *)sender runNode:(SuiteNode *)node;
@end

@interface SuiteTreeViewController : NSViewController<NSOutlineViewDataSource, NSOutlineViewDelegate, OutlineViewContextMenuDelegate>
@property (nonatomic, weak) id<SuiteTreeViewControllerDelegate> delegate;
- (void)show:(NSArray<SuiteNode *> *)roots;
@end

NS_ASSUME_NONNULL_END
