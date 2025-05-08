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

- (void)setJasmine:(Jasmine *)jasmine {
    jasmine.delegate = self;
    _jasmine = jasmine;
}

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
            NSLog(@"Enumeration failed: %@", [error localizedDescription]);
        } else {
            // TODO: set self.treeViewController before this
            [weakSelf.treeViewController show:result];
        }
    }];
}

- (void)suiteTreeViewController:(nonnull SuiteTreeViewController *)sender
                        runNode:(nonnull SuiteNode *)node {
    // TODO: show some kind of loading indicator
    [self.outputViewController clearOutput];
    [self.jasmine runNode:node];
}


- (void)jasmine:(nonnull Jasmine *)sender runDidOutputLine:(nonnull NSString *)line { 
    [self.outputViewController appendOutput:line];
}

- (void)jasmine:(nonnull Jasmine *)sender runFailedWithError:(nonnull NSError *)error {
    // TODO
    NSString *msg = [NSString stringWithFormat:@"Run errored: %@", [error localizedDescription]];
    [self.outputViewController appendOutput:msg];
}

- (void)jasmine:(nonnull Jasmine *)sender runFinishedWithExitCode:(int)exitCode { 
    // TODO: better overall result reporting
    if (exitCode == 0) {
        [self.outputViewController appendOutput:@"Run passed"];
    } else {
        [self.outputViewController appendOutput:@"Run failed"];
    }
}

@end
