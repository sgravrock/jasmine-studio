//
//  RunnerViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/26/25.
//

#import <Cocoa/Cocoa.h>
#import "JasmineRunner.h"
#import "ReporterTreeBuilder.h"
#import "SuiteTreeViewController.h"
#import "OutputViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RunnerViewController : NSSplitViewController<SuiteTreeViewControllerDelegate, JasmineRunnerDelegate, ReporterTreeBuilderDelegate>

@property (nonatomic, strong) JasmineRunner *jasmineRunner;
@property (nonatomic, weak) SuiteTreeViewController *treeViewController;
@property (nonatomic, weak) OutputViewController *outputViewController;
- (void)loadSuite;

@end

NS_ASSUME_NONNULL_END
