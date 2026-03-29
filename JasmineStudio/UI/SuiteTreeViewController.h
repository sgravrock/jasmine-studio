//
//  SuiteTreeViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import <Cocoa/Cocoa.h>
#import "OutlineViewWithContextMenu.h"
#import "SuiteOrSpec.h"
#import "TreeReconciler.h"

NS_ASSUME_NONNULL_BEGIN

@class SuiteTreeViewController;

@protocol SuiteTreeViewControllerDelegate
- (void)suiteTreeViewController:(SuiteTreeViewController *)sender runNode:(SuiteOrSpec *)node;
@end

@interface SuiteTreeViewController : NSViewController<NSOutlineViewDataSource, NSOutlineViewDelegate, OutlineViewContextMenuDelegate, TreeReconcilerDelegate>
@property (nonatomic, weak) id<SuiteTreeViewControllerDelegate> delegate;
- (void)show:(NSArray<SuiteOrSpec *> *)roots;
@end

NS_ASSUME_NONNULL_END
