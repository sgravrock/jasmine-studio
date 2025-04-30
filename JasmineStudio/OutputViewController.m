//
//  OutputViewController.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/30/25.
//

#import "OutputViewController.h"

@interface OutputViewController ()
@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@end

@implementation OutputViewController

- (void)showOutput:(NSString *)output {
    self.outputTextView.string = output;
}

@end
