//
//  ResultTest.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 5/18/25.
//

#import <XCTest/XCTest.h>
#import "results.h"

@interface ResultTest : XCTestCase<ResultDelegate>
@property (nonatomic, assign) BOOL didUpdate;
@property (nonatomic, strong) NodeResult *addedChild;;
@end

@implementation ResultTest

- (void)testAppendOutput {
    Result *subject = [[Result alloc] init];
    subject.delegate = self;
    
    [subject appendOutput:@"Hello"];
    XCTAssertEqualObjects(subject.output, @"Hello");
    XCTAssertTrue(self.didUpdate);
    
    self.didUpdate = false;
    [subject appendOutput:@", world"];
    XCTAssertEqualObjects(subject.output, @"Hello, world");
    XCTAssertTrue(self.didUpdate);
}

- (void)testAddChild {
    Result *subject = [[Result alloc] init];
    subject.delegate = self;
    NodeResult *child1 = [[NodeResult alloc] initWithStartedEvent:@{@"id": @"spec1"}];
    NodeResult *child2 = [[NodeResult alloc] initWithStartedEvent:@{@"id": @"spec2"}];
    
    [subject addChild:child1];
    self.addedChild = nil;
    [subject addChild:child2];
    
    XCTAssertEqual(subject.children.count, 2);
    XCTAssertEqualObjects(subject.children[0], child1);
    XCTAssertEqualObjects(subject.children[1], child2);
    XCTAssertEqualObjects(self.addedChild, child2);
}

#pragma mark - ResultDelegate

- (void)resultDidUpdate:(nonnull Result *)sender {
    self.didUpdate = YES;
}

- (void)result:(nonnull Result *)sender didAddChild:(nonnull NodeResult *)child {
    self.addedChild = child;
}



@end
