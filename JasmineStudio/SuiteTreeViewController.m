//
//  SuiteTreeViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import "SuiteTreeViewController.h"
#import "Jasmine.h"

@interface SuiteTreeViewController ()
@property (weak) IBOutlet OutlineViewWithContextMenu *outlineView;
@property (nonatomic, strong) NSArray<SuiteNode *> *roots;
@end

@implementation SuiteTreeViewController

- (void)show:(NSArray<SuiteNode *> *)roots {
    self.roots = roots;
    [self.outlineView reloadData];
}

#pragma mark NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (!self.roots) {
        return 0;
    }

    if (item == nil) {
        return self.roots.count;
    } else {
        return ((SuiteNode *)item).children.count;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return self.roots[index];
    } else {
        return ((SuiteNode *)item).children[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return ((SuiteNode *)item).children.count > 0;
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
    SuiteNode *target = ((NSMenuItem *)sender).representedObject;
    NSLog(@"Would run %@", target.name);
}

@end
