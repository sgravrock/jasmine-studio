//
//  RunnerWindowController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import "RunnerWindowController.h"
#import "SuiteTreeViewController.h"
#import "JasmineStudio-Swift.h"

//// Model for table view cells
//@interface TempModel: NSObject<NSCopying>
//@property (nonatomic, assign) NSInteger n;
//- (NSString *)stringValue;
//@end
//
//@implementation TempModel
//- (NSString *)stringValue {
//    return [NSString stringWithFormat:@"%ld", (long)self.n];
//}
//
//- (id)copyWithZone:(NSZone *)zone {
//    TempModel *copy = [[[self class] alloc] init];
//    copy.n = self.n;
//    return copy;
//}
//@end

@interface RunnerWindowController ()

//@property (weak) IBOutlet NSOutlineView *suiteOutlineView;
@property (nonatomic, strong) NSURL *baseDir;
//@property (nonatomic, assign) BOOL inited;
//@property (nonatomic, strong) NSArray<TempModel *> *models;
//@property (nonatomic, strong) ViewController *viewController;

@property (weak) IBOutlet NSView *rootView;
@property (nonatomic, strong) SuiteTreeViewController *tvc;
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
        self.tvc = [[SuiteTreeViewController alloc] initWithNibName:@"SuiteTreeViewController" bundle:nil];
        [self.rootView addSubview:self.tvc.view];
    }
    
//    if (self.baseDir && self.windowLoaded && self.suiteOutlineView) {
//        self.window.title = [self.baseDir lastPathComponent];
////        self.models = [NSArray arrayWithObjects:[[TempModel alloc] init], [[TempModel alloc] init], [[TempModel alloc] init], nil];
//        
////        for (int i = 0; i < self.models.count; i++) {
////            self.models[i].n = i;
////        }
//        
//        self.inited = YES;
//        self.viewController = [[ViewController alloc] init];
//        [self.viewController shenanigansWithOutlineView:self.suiteOutlineView];
//    
//        // Causes numberOfChildrenOfItem:nil to be called, and blanks the table
////        [self.suiteOutlineView reloadData];
//        // Has no effect
////        [self.suiteOutlineView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
//    }
}
//
//
///*
//#pragma mark NSOutlineViewDataSource
//
//- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
//    if (!self.inited) {
//        NSLog(@"numberOfChildrenOfItem bailing");
//        return 0;
//    }
//    
//    if (item == nil) {
//        NSLog(@"numberOfChildrenOfItem(%p): 3", item);
//        return 3;
//    }
//    
//    NSLog(@"numberOfChildrenOfItem(%p): 0", item);
//    return 0;
//}
//
//- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
////    TempModel *m = [[TempModel alloc] init];
////    m.n = index;
//    TempModel *m = self.models[index];
//    NSLog(@"outlineView:child:ofItem: returning %p for %p[%ld]", m, item, (long)index);
//    return m;
//}
//
//- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
//    return item;
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
//    NSLog(@"isItemExpandable: %p => true", item);
//    return false;
//}
//
//#pragma mark NSOutlineViewDelegate
//
//- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
//    NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"THE_CELL" owner:self];
//    cell.textField.stringValue = [item stringValue];
//    return cell;
//}
//*/

@end
