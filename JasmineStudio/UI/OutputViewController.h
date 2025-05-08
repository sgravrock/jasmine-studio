//
//  OutputViewController.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/30/25.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface OutputViewController : NSViewController

- (void)clearOutput;
- (void)appendOutput:(NSString *)output;

@end

NS_ASSUME_NONNULL_END
