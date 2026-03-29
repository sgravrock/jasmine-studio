//
//  SuiteTreeViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import <Cocoa/Cocoa.h>
#import "OutlineViewWithContextMenu.h"
#import "TreeReconciler.h"
@class TopSuite;
@class TreeNode;

NS_ASSUME_NONNULL_BEGIN

@class SuiteTreeViewController;

@protocol SuiteTreeViewControllerDelegate
- (void)suiteTreeViewController:(SuiteTreeViewController *)sender runNode:(TreeNode *)node;
@end

@interface SuiteTreeViewController : NSViewController<NSOutlineViewDataSource, NSOutlineViewDelegate, OutlineViewContextMenuDelegate, TreeReconcilerDelegate>
@property (nonatomic, weak) id<SuiteTreeViewControllerDelegate> delegate;
- (void)show:(TopSuite *)root;
@end

NS_ASSUME_NONNULL_END
