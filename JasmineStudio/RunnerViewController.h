//
//  RunnerViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/26/25.
//

#import <Cocoa/Cocoa.h>
#import "Jasmine.h"
#import "SuiteTreeViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RunnerViewController : NSSplitViewController<SuiteTreeViewControllerDelegate>

@property (nonatomic, strong) Jasmine *jasmine;
- (void)loadSuite;

@end

NS_ASSUME_NONNULL_END
