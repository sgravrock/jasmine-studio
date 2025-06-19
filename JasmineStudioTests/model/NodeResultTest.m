//
//  NodeResultTest.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 5/10/25.
//

#import <XCTest/XCTest.h>
#import "results.h"

@interface NodeResultTest : XCTestCase<ResultDelegate>
@property (nonatomic, assign) BOOL didUpdate;
@end

@implementation NodeResultTest

- (void)setUp {
    self.didUpdate = NO;
}

- (void)testInitWithStartedEvent_withParent {
    NSDictionary *event = @{
        @"id": @"spec85",
        @"description": @"spec name",
        @"parentSuiteId": @"suite30"
    };
    
    NodeResult *subject = [[NodeResult alloc] initWithStartedEvent:event];
    
    XCTAssertEqualObjects(subject.nodeId, @"spec85");
    XCTAssertEqualObjects(subject.parentSuiteId, @"suite30");
    XCTAssertEqualObjects(subject.name, @"spec name");
    XCTAssertEqual(subject.status, rsRunning);
}

- (void)testInitWithStartedEvent_withoutParent {
    NSDictionary *event = @{
        @"id": @"",
        @"description": @"",
    };
    
    NodeResult *subject = [[NodeResult alloc] initWithStartedEvent:event];
    
    XCTAssertNil(subject.parentSuiteId, @"suite30");
}

- (void)testUpdateWithEndedEvent_passed {
    NodeResult *subject = [[NodeResult alloc] initWithStartedEvent:@{}];
    subject.delegate = self;
    
    [subject updateWithEndedEvent:@{@"status": @"passed"}];
    
    XCTAssertEqual(subject.status, rsPassed);
    XCTAssertTrue(self.didUpdate);
}

- (void)testUpdateWithEndedEvent_failed {
    NodeResult *subject = [[NodeResult alloc] initWithStartedEvent:@{}];
    subject.delegate = self;
    
    [subject updateWithEndedEvent:@{@"status": @"failed"}];
    
    XCTAssertEqual(subject.status, rsFailed);
    XCTAssertTrue(self.didUpdate);
}

- (void)testUpdateWithEndedEvent_pending {
    NodeResult *subject = [[NodeResult alloc] initWithStartedEvent:@{}];
    subject.delegate = self;
    
    [subject updateWithEndedEvent:@{@"status": @"pending"}];
    
    XCTAssertEqual(subject.status, rsPending);
    XCTAssertTrue(self.didUpdate);
}

- (void)testUpdateWithEndedEvent_excluded {
    NodeResult *subject = [[NodeResult alloc] initWithStartedEvent:@{}];
    subject.delegate = self;
    
    [subject updateWithEndedEvent:@{@"status": @"excluded"}];
    
    XCTAssertEqual(subject.status, rsExcluded);
    XCTAssertTrue(self.didUpdate);
}

- (void)testUpdateWithEndedEvent_failedExpectations {
    NodeResult *subject = [[NodeResult alloc] initWithStartedEvent:@{}];
    subject.delegate = self;
    
    NSDictionary *event = @{
        @"status": @"failed",
        @"failedExpectations": @[
            @{
                @"matcherName": @"matcher 1",
                @"message": @"msg 1",
                @"stack": @"stack 1"
            },
            @{
                @"matcherName": @"matcher 2",
                @"message": @"msg 2",
                @"stack": @"stack 2"
            },
        ]
    };
    [subject updateWithEndedEvent:event];
    
    XCTAssertTrue(self.didUpdate);
    XCTAssertEqual(subject.failedExpectations.count, 2);
    XCTAssertEqualObjects(subject.failedExpectations[0].matcherName, @"matcher 1");
    XCTAssertEqualObjects(subject.failedExpectations[0].message, @"msg 1");
    XCTAssertEqualObjects(subject.failedExpectations[0].stack, @"stack 1");
}

#pragma mark - ResultDelegate

- (void)result:(nonnull Result *)sender didAddChild:(nonnull NodeResult *)child {
}

- (void)resultDidUpdate:(nonnull Result *)sender { 
    self.didUpdate = YES;
}

@end
