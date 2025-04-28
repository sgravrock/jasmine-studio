//
//  RunnerViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/26/25.
//

#import "RunnerViewController.h"
#import "SuiteTreeViewController.h"

@interface RunnerViewController ()
@property (nonatomic, weak) SuiteTreeViewController *treeViewController;
@end

@implementation RunnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.treeViewController = (SuiteTreeViewController *)self.splitViewItems[0].viewController;
}

- (void)loadSuite {
    // TODO: show some kind of loading indicator
    [self.jasmine enumerateWithCallback:^(NSArray<SuiteNode *> * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            // TODO
            NSLog(@"oh no");
        } else {
            // TODO: set self.treeViewController before this
            [self.treeViewController show:result];
        }
    }];
}

@end
