//
//  ReadableExpectation.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 5/5/25.
//

#import "ReadableExpectation.h"

@implementation ReadableExpectation

- (instancetype)initWithDescription:(NSString *)expectationDescription {
    self = [super initWithDescription:expectationDescription];
    
    if (self) {
        _isFulfilled = NO;
    }
    
    return self;
}

- (void)fulfill {
    _isFulfilled = YES;
    [super fulfill];
}
@end
