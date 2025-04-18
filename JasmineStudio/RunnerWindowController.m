//
//  RunnerWindowController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import "RunnerWindowController.h"

// Model for table view cells
// To bind:
// * Select the text field inside the Table Cell View in Interface Builder
// * Select the chain-link tab in the inspector
// * Expand Value
// * Check Bind to
// * Make sure Table Cell View is selected in the dropdown
// * Set Model Key Path to objectValue.stringValue
// (Existing documentation for this is a little off due to changes in Xcode.)
@interface TempModel: NSObject<NSCopying>
@property (nonatomic, assign) NSInteger n;
- (NSString *)stringValue;
@end

@implementation TempModel
- (NSString *)stringValue {
    return [NSString stringWithFormat:@"%ld", (long)self.n];
}

- (id)copyWithZone:(NSZone *)zone {
    TempModel *copy = [[[self class] alloc] init];
    copy.n = self.n;
    return copy;
}
@end

@interface RunnerWindowController ()

@property (nonatomic, strong) NSURL *baseDir;

- (void)initUIIfReady;

@end

@implementation RunnerWindowController

#pragma mark Initialization

- (NSNibName)windowNibName {
    return @"RunnerWindowController";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self initUIIfReady];
}

- (void)initProjectWithBaseDir:(NSURL *)baseDir {
    self.baseDir = baseDir;
    [self initUIIfReady];
}

- (void)initUIIfReady {
    if (self.baseDir && self.windowLoaded) {
        self.window.title = [self.baseDir lastPathComponent];
    }
}


#pragma mark NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (item == nil) {
        NSLog(@"numberOfChildrenOfItem(%p): 3", item);
        return 3;
    }
    
    NSLog(@"numberOfChildrenOfItem(%p): 0", item);
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    TempModel *m = [[TempModel alloc] init];
    m.n = index;
    NSLog(@"outlineView:child:ofItem: returning %p for %p[%ld]", m, item, (long)index);
    return m;
}

- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
    return item;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    NSLog(@"isItemExpandable: %p => true", item);
    return false;
}
    
@end
