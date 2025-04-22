//
//  SuiteTreeViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import "SuiteTreeViewController.h"
#import "Jasmine.h"

@interface SuiteTreeViewController ()
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) SuiteNodeList *models;
@end

@implementation SuiteTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self discoverNodes]; // TODO: Jasmine calls these "runables".
}

- (void)discoverNodes {
    // TODO: show some kind of loading indicator
    [self.jasmine enumerateWithCallback:^(SuiteNodeList * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            // TODO
            NSLog(@"oh no");
        } else {
            self.models = result;
            [self.outlineView reloadData];
        }
    }];
}

#pragma mark NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (!self.models) {
        return 0;
    }

    if (item == nil) {
        return self.models.count;
    } else if ([item isKindOfClass:[Suite class]]) {
        return ((Suite *)item).children.count;
    } else {
        return 0;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return self.models[index];
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


@end
