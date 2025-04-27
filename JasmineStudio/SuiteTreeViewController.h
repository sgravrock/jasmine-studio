//
//  SuiteTreeViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import <Cocoa/Cocoa.h>
#import "Models.h"

NS_ASSUME_NONNULL_BEGIN

@interface SuiteTreeViewController : NSViewController<NSOutlineViewDataSource, NSOutlineViewDelegate>
- (void)show:(SuiteNodeList *)roots;
@end

NS_ASSUME_NONNULL_END
