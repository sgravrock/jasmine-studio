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


#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 3;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    TempModel *m = [[TempModel alloc] init];
    m.n = row;
    NSLog(@"Returning %p for %ld", m, (long)row);
    return m;
}

@end
