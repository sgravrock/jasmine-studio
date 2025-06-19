//
//  OverallResultTest.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 6/8/25.
//

#import <XCTest/XCTest.h>
#import "results.h"

@interface OverallResultTest : XCTestCase<ResultDelegate>
@property (nonatomic, assign) BOOL didUpdate;
@end

@implementation OverallResultTest

- (void)setUp {
    self.didUpdate = NO;
}

- (void)testInitWithStartedEvent {
    OverallResult *subject = [[OverallResult alloc] initWithStartedEvent:@{}];
    XCTAssertEqual(subject.status, rsRunning);
}

- (void)testUpdateWithEndedEvent_passed {
    OverallResult *subject = [[OverallResult alloc] initWithStartedEvent:@{}];
    subject.delegate = self;
    
    [subject updateWithEndedEvent:@{@"overallStatus": @"passed"}];
    
    XCTAssertEqual(subject.status, rsPassed);
    XCTAssertTrue(self.didUpdate);
}

- (void)testUpdateWithEndedEvent_failed {
    OverallResult *subject = [[OverallResult alloc] initWithStartedEvent:@{}];
    subject.delegate = self;
    
    [subject updateWithEndedEvent:@{@"overallStatus": @"failed"}];
    
    XCTAssertEqual(subject.status, rsFailed);
    XCTAssertTrue(self.didUpdate);
}

- (void)testUpdateWithEndedEvent_incomplete {
    OverallResult *subject = [[OverallResult alloc] initWithStartedEvent:@{}];
    subject.delegate = self;
    
    [subject updateWithEndedEvent:@{@"overallStatus": @"incomplete"}];
    
    XCTAssertEqual(subject.status, rsIncomplete);
    XCTAssertTrue(self.didUpdate);
}

#pragma mark - ResultDelegate

- (void)result:(nonnull Result *)sender didAddChild:(nonnull Result *)child {
}

- (void)resultDidUpdate:(nonnull Result *)sender {
    self.didUpdate = YES;
}


@end
