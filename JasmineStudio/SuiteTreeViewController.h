//
//  SuiteTreeViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class Jasmine;

@interface SuiteTreeViewController : NSViewController<NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (nonatomic, strong) Jasmine *jasmine;
@end

NS_ASSUME_NONNULL_END
