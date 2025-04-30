//
//  RunnerViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/26/25.
//

#import "RunnerViewController.h"
#import "OutputViewController.h"

@interface RunnerViewController ()
@property (nonatomic, weak) SuiteTreeViewController *treeViewController;
@property (nonatomic, weak) OutputViewController *outputViewController;
@end

@implementation RunnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.treeViewController = (SuiteTreeViewController *)self.splitViewItems[0].viewController;
    self.treeViewController.delegate = self;
    self.outputViewController = (OutputViewController *)self.splitViewItems[1].viewController;

}

- (void)loadSuite {
    // TODO: show some kind of loading indicator
    __weak RunnerViewController *weakSelf = self;
    [self.jasmine enumerateWithCallback:^(NSArray<SuiteNode *> * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            // TODO
            NSLog(@"oh no");
        } else {
            // TODO: set self.treeViewController before this
            [weakSelf.treeViewController show:result];
        }
    }];
}

- (void)suiteTreeViewController:(nonnull SuiteTreeViewController *)sender
                        runNode:(nonnull SuiteNode *)node {
    // TODO: show some kind of loading indicator
    __weak RunnerViewController *weakSelf = self;
    [self.jasmine runNode:node
             withCallback:^(BOOL passed, NSString * _Nullable output, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Run errored: %@", [error localizedDescription]);
        } else {
            if (passed) {
                NSLog(@"Run passsed");
            } else {
                NSLog(@"Run failed");
            }
            
            [weakSelf.outputViewController showOutput:output];
        }
    }];
}


@end
