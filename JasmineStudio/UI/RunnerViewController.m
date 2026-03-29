//
//  RunnerViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/26/25.
//

#import "RunnerViewController.h"
#import "OutputViewController.h"
#import "TreeReconciler.h"

@interface RunnerViewController ()
@property (nonatomic, weak) SuiteTreeViewController *treeViewController;
@property (nonatomic, weak) OutputViewController *outputViewController;
@property (nonatomic, strong) ReporterTreeBuilder *treeBuilder;
// Created after enumeration
@property (nonatomic, strong) TreeReconciler * _Nullable treeReconciler;
@end

@implementation RunnerViewController

- (void)setJasmineRunner:(JasmineRunner *)jasmine {
    jasmine.delegate = self;
    _jasmineRunner = jasmine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.treeViewController = (SuiteTreeViewController *)self.splitViewItems[0].viewController;
    self.treeViewController.delegate = self;
    self.outputViewController = (OutputViewController *)self.splitViewItems[1].viewController;
}

// Precondition: viewDidLoad has been called
- (void)loadSuite {
    __weak RunnerViewController *weakSelf = self;
    
    // TODO: show some kind of loading indicator
    [self.jasmineRunner enumerateWithCallback:^(NSArray<SuiteNode *> * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            // TODO
            NSLog(@"Enumeration failed: %@", [error localizedDescription]);
        } else {
            NSMutableArray *mutableResult = [NSMutableArray arrayWithArray:result];
            [weakSelf.treeViewController show:mutableResult];
            weakSelf.treeReconciler = [[TreeReconciler alloc] initWithRoots:mutableResult];
            weakSelf.treeReconciler.delegate = weakSelf.treeViewController;
        }
    }];
}

- (void)suiteTreeViewController:(nonnull SuiteTreeViewController *)sender
                        runNode:(nonnull SuiteNode *)node {
    // TODO: show some kind of loading indicator
    [self.outputViewController clearOutput];
    self.treeBuilder = [[ReporterTreeBuilder alloc] init];
    self.treeBuilder.delegate = self;
    [self.jasmineRunner runNode:node];
}

#pragma mark - JasmineRunnerDelegate methods

- (void)jasmineRunner:(nonnull JasmineRunner *)sender runDidOutputLine:(nonnull NSString *)line {
    // TODO: associate these with the node in question
    [self.outputViewController appendOutput:line];
}

- (void)jasmineRunner:(nonnull JasmineRunner *)sender emittedReporterEvent:(nonnull ReporterEvent *)event {
    NSError *error = nil;
    
    if (![self.treeBuilder handleEvent:event error:&error]) {
        // TODO: show errors to the user
        NSLog(@"Failed to handle event: %@", [error localizedDescription]);
        return;
    }
    
}


- (void)jasmineRunner:(nonnull JasmineRunner *)sender runFailedWithError:(nonnull NSError *)error {
    self.treeBuilder = nil;

    // TODO
    NSString *msg = [NSString stringWithFormat:@"Run errored: %@", [error localizedDescription]];
    [self.outputViewController appendOutput:msg];
}

- (void)jasmineRunner:(nonnull JasmineRunner *)sender runFinishedWithExitCode:(int)exitCode {
    [self.treeReconciler jasmineDone];
    self.treeBuilder = nil;

    // TODO: better overall result reporting
    if (exitCode == 0) {
        [self.outputViewController appendOutput:@"Run passed"];
    } else {
        [self.outputViewController appendOutput:@"Run failed"];
    }
}

#pragma mark - ReporterTreeBuilderDelegate methods

- (void)reporterTreeBuilder:(nonnull ReporterTreeBuilder *)sender didUpdateNode:(nonnull SuiteNode *)node {
    NSString *line = [NSString stringWithFormat:@"%@: %@\n",
                      [self statusAsString:node.status],
                      [node.path componentsJoinedByString:@" "]];
    [self.outputViewController appendOutput:line];
    [self.treeReconciler applyChange:node];
}

#pragma mark -

- (NSString *)statusAsString:(SuiteNodeStatus)status {
    switch (status) {
        case SuiteNodeStatusNotStarted:
            return @"not started";
        case SuiteNodeStatusRunning:
            return @"running";
        case SuiteNodeStatusPassed:
            return @"passed";
        case SuiteNodeStatusFailed:
            return @"failed";
        case SuiteNodeStatusPending:
            return @"pending";
        case SuiteNodeStatusExcluded:
            return @"excluded";
        default:
            return @"unknown status";
    }
}

@end
