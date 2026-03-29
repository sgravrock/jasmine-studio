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

NS_ASSUME_NONNULL_BEGIN

@interface RunnerViewController : NSSplitViewController<SuiteTreeViewControllerDelegate, JasmineRunnerDelegate, ReporterTreeBuilderDelegate>

@property (nonatomic, strong) JasmineRunner *jasmineRunner;
- (void)loadSuite;

@end

NS_ASSUME_NONNULL_END
