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
@property (nonatomic, strong) NSMutableArray<TempModel *> *models;
@property (nonatomic, strong) TempModel *childModel;
@end

@implementation SuiteTreeViewController

- (IBAction)makeRocketGo:(id)sender {
    NSLog(@"Make rocket go");
    [self.outlineView reloadData];
    self.outlineView.needsDisplay = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_queue_t queue = dispatch_queue_create("shenanigans", DISPATCH_QUEUE_SERIAL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initModels];
            [self.outlineView reloadData];
        });
    });
}

- (void)initModels {
    self.models = [NSMutableArray arrayWithCapacity:3];
    
    for (int i = 0; i < 3; i++) {
        TempModel *m = [[TempModel alloc] init];
        m.n = i;
        [self.models addObject:m];
    }
    
    self.childModel = [[TempModel alloc] init];
    self.childModel. n = 10;
}

#pragma mark NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (!self.models) {
        NSLog(@"numberOfChildrenOfItem bailing");
        return 0;
    }

    NSInteger result;
    
    if (item == nil) {
        result = self.models.count;
    } else if (item == self.models[0]) {
        return 1;
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
    } else if (item == self.models[0] && index == 0) {
        result = self.childModel;
    } else {
        result = nil;
    }
    
    NSLog(@"outlineView:child:ofItem: returning %p for %p[%ld]", result, item, (long)index);
    return result;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return item == self.models[0];
}

// Needed for data binding
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
    return item;
}


@end
