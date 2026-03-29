//
//  SuiteTreeViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import "SuiteTreeViewController.h"
#import "JasmineRunner.h"

@interface SuiteTreeViewController ()
@property (weak) IBOutlet OutlineViewWithContextMenu *outlineView;
@property (nonatomic, strong) TreeNode *root;
@end

@implementation SuiteTreeViewController

- (void)show:(TopSuite *)root {
    self.root = root;
    [self.outlineView reloadData];
    [self.outlineView expandItem:root];
}

#pragma mark NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (!self.root) {
        return 0;
    }
    
    if (item == nil) {
        return 1;
    }
    
    return ((TreeNode *)item).children.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return self.root;
    } else {
        return ((TreeNode *)item).children[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return ((TreeNode *)item).children.count > 0;
}

// Needed for data binding
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
    return item;
}


#pragma mark - OutlineViewContextMenuDelegate

- (NSMenu * _Nullable)menuForOutlineView:(nonnull OutlineViewWithContextMenu *)sender row:(NSInteger)row {
    NSMenu *contextMenu = [[NSMenu alloc] initWithTitle:@""];
    NSMenuItem *runItem = [[NSMenuItem alloc] initWithTitle:@"Run" action:@selector(handleRunMenuItem:) keyEquivalent:@""];
    runItem.representedObject = [self.outlineView itemAtRow:row];
    [contextMenu addItem:runItem];

    return contextMenu;
}

- (void)handleRunMenuItem:(id)sender {
    TreeNode *target = ((NSMenuItem *)sender).representedObject;
    [self.delegate suiteTreeViewController:self runNode:target];
}

#pragma mark TeeReconcilerDelegate

- (void)treeReconciler:(nonnull TreeReconciler *)sender didUpdateNode:(nonnull SuiteOrSpec *)node {
    // TODO: only reload children if child nodes were added/removed
    [self.outlineView reloadItem:node reloadChildren:YES];
}

@end
