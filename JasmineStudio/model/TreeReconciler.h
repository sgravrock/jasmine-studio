//
//  TreeReconciler.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TreeNode;
@class TopSuite;
@class TreeReconciler;

@protocol TreeReconcilerDelegate
// This interface is designed around the needs of an NSOutlineViewDataSource.
// When a node has changed, it's passed to treeReconciler:didUpdateNode:.
// When a node is added or removed, its parent is passed to that same method.
- (void)treeReconciler:(TreeReconciler *)sender didUpdateNode:(TreeNode *)node;
@end


@interface TreeReconciler : NSObject

@property (nonatomic, weak) id<TreeReconcilerDelegate> delegate;
@property (nonatomic, readonly, strong) TopSuite *root;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRoot:(TopSuite *)root NS_DESIGNATED_INITIALIZER;

- (void)applyChange:(TreeNode *)changedNode;

// Should be called at the end of a Jasmine run. Removes any root nodes that
// were not seen during the run.
- (void)jasmineDone;

@end

NS_ASSUME_NONNULL_END
