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
@property (nonatomic, strong) SuiteNodeList *roots;
@end

@implementation SuiteTreeViewController

- (void)show:(SuiteNodeList *)roots {
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
    } else if ([item isKindOfClass:[Suite class]]) {
        return ((Suite *)item).children.count;
    } else {
        return 0;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return self.roots[index];
    } else if ([item isKindOfClass:[Suite class]]) {
        return ((Suite *)item).children[index];
    } else {
        return nil;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[Suite class]]) {
        return ((Suite *)item).children.count > 0;
    } else {
        return NO;
    }
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
    id<SuiteNode> target = ((NSMenuItem *)sender).representedObject;
    NSLog(@"Would run %@", target.name);
}

@end
