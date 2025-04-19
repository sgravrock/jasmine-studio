//
//  SuiteTreeViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import "SuiteTreeViewController.h"

// Model for table view cells
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


@interface SuiteTreeViewController ()
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSButton *button;
@property (nonatomic, strong) NSMutableArray<TempModel *> *models;
@end

@implementation SuiteTreeViewController

- (IBAction)makeRocketGo:(id)sender {
    NSLog(@"Make rocket go");
    [self.outlineView reloadData];
    self.outlineView.needsDisplay = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self shenanigans];
    [self.button setTarget:self];
    [self.button setAction:@selector(makeRocketGo:)];
//    [self performSelectorOnMainThread:@selector(shenanigans) withObject:nil waitUntilDone:YES];
    
    dispatch_queue_t queue = dispatch_queue_create("shenanigans", DISPATCH_QUEUE_SERIAL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shenanigans];
        });
    });
  
    // THis works!
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self shenanigans];
//    });

    // This works!
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
//        [self performSelectorOnMainThread:@selector(shenanigans) withObject:nil waitUntilDone:YES];
//    });
        
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        [self initModels];
//        [self performSelectorOnMainThread:@selector(shenanigans) withObject:nil waitUntilDone:YES];
////        [self.outlineView reloadData];
//    });
}

- (void)shenanigans {
    NSLog(@"shenanigans");
//    [self.outlineView beginUpdates];
    [self initModels];
    [self.outlineView reloadData];
//    self.outlineView.needsDisplay = YES;
//        [self.outlineView setNeedsDisplay];
//    [self.outlineView endUpdates];
}

- (void)initModels {
    self.models = [NSMutableArray arrayWithCapacity:3];
    
    for (int i = 0; i < 3; i++) {
        TempModel *m = [[TempModel alloc] init];
        m.n = i;
        [self.models addObject:m];
    }
}

#pragma mark NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (!self.models) {
//        [self initModels];
        NSLog(@"numberOfChildrenOfItem bailing");
        return 0;
    }
//    if (!self.inited) {
//        NSLog(@"numberOfChildrenOfItem bailing");
//        return 0;
//    }

    NSInteger result;
    
    if (item == nil) {
        result = self.models.count;
    } else {
        result = 0;
    }

    NSLog(@"numberOfChildrenOfItem(%p): %ld", item, (long)result);
    return result;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    id result;
    
    if (item == nil) {
        result = self.models[index];
    } else {
        result = nil;
    }
    
    NSLog(@"outlineView:child:ofItem: returning %p for %p[%ld]", result, item, (long)index);
    return result;
}
//
//- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
//    return item;
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
//    NSLog(@"isItemExpandable: %p => true", item);
//    return false;
//}


@end
