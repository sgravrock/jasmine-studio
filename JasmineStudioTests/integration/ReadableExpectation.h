//
//  ReadableExpectation.h
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 5/5/25.
//

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReadableExpectation : XCTestExpectation
@property (nonatomic, readonly, assign) BOOL isFulfilled;
@end

NS_ASSUME_NONNULL_END
