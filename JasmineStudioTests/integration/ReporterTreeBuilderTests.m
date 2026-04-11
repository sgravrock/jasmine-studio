//
//  ReporterTreeBuilderTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <XCTest/XCTest.h>
#import "ReporterTreeBuilder.h"
#import "ReporterEvent.h"
#import "TreeNode.h"

@interface ReporterTreeBuilderTests : XCTestCase<ReporterTreeBuilderDelegate>
@property (nonatomic, strong) NSMutableArray<SuiteOrSpec *> *emittedNodes;
@property (nonatomic, strong) ReporterTreeBuilder *subject;
@end

@implementation ReporterTreeBuilderTests

- (void)setUp {
    self.emittedNodes = [NSMutableArray array];
    self.subject = [[ReporterTreeBuilder alloc] init];
    self.subject.delegate = self;
}

- (void)testSpecStartedDoneSimple {
    // Start and done events for a spec that is a root node
    ReporterEvent *startedEvent = [[ReporterEvent alloc] initWithEventName:@"specStarted"
                                                                   payload:@{
        @"description": @"a spec"
    }];
    ReporterEvent *doneEvent = [[ReporterEvent alloc] initWithEventName:@"specDone"
                                                                payload:@{
        @"description": @"a spec",
        @"status": @"failed"
        // TODO other properties esp. failedExpectations
    }];
    
    NSError *error = nil;
    XCTAssertTrue([self.subject handleEvent:startedEvent error:&error]);
    XCTAssertNil(error);
    
    XCTAssertEqual(self.emittedNodes.count, 1);
    XCTAssertTrue([self.emittedNodes[0] isKindOfClass:[Spec class]]);

    XCTAssertEqualObjects(self.emittedNodes[0].name, @"a spec");
    XCTAssertTrue([self.emittedNodes[0].parent isKindOfClass:[TopSuite class]]);
    XCTAssertEqual(self.emittedNodes[0].status, SuiteOrSpecStatusRunning);
    
    XCTAssertTrue([self.subject handleEvent:doneEvent error:&error]);
    XCTAssertNil(error);
    
    XCTAssertEqual(self.emittedNodes.count, 2);
    XCTAssertEqual(self.emittedNodes[0], self.emittedNodes[1]); // same instance
    XCTAssertEqual(self.emittedNodes[0].status, SuiteOrSpecStatusFailed);
    // TODO also assert other result aspects
}

- (void)testSpecStartedDoneNested {
    // Start and done events for a spec that is a suite node
    ReporterEvent *suiteStartedEvent = [[ReporterEvent alloc] initWithEventName:@"suiteStarted"
                                                                       payload:@{
        @"description": @"a suite"
    }];
    ReporterEvent *specStartedEvent = [[ReporterEvent alloc] initWithEventName:@"specStarted"
                                                                       payload:@{
        @"description": @"a spec"
    }];
    ReporterEvent *specDoneEvent = [[ReporterEvent alloc] initWithEventName:@"specDone"
                                                                    payload:@{
        @"description": @"a spec",
        @"status": @"failed"
    }];
    
    NSError *error = nil;
    XCTAssertTrue([self.subject handleEvent:suiteStartedEvent error:&error]);
    XCTAssertNil(error);
    XCTAssertTrue([self.subject handleEvent:specStartedEvent error:&error]);
    XCTAssertNil(error);

    XCTAssertEqual(self.emittedNodes.count, 2);
    XCTAssertTrue([self.emittedNodes[1] isKindOfClass:[Spec class]]);
    XCTAssertEqualObjects(self.emittedNodes[1].name, @"a spec");
    XCTAssertEqual(self.emittedNodes[1].parent, self.emittedNodes[0]);
    
    XCTAssertTrue([self.subject handleEvent:specDoneEvent error:&error]);
    XCTAssertNil(error);

    XCTAssertEqual(self.emittedNodes.count, 3);
    XCTAssertEqual(self.emittedNodes[2], self.emittedNodes[1]); // same instance
}

- (void)testSuiteStartedDone {
    // Start and done events for a suite tree:
    // a
    //   -> b
    //     -> c
    //   -> d
    ReporterEvent *aStartedEvent = [[ReporterEvent alloc] initWithEventName:@"suiteStarted"
                                                                   payload:@{
        @"description": @"suite a"
    }];
    ReporterEvent *bStartedEvent = [[ReporterEvent alloc] initWithEventName:@"suiteStarted"
                                                                   payload:@{
        @"description": @"suite b"
    }];
    ReporterEvent *cStartedEvent = [[ReporterEvent alloc] initWithEventName:@"suiteStarted"
                                                                   payload:@{
        @"description": @"suite c"
    }];
    ReporterEvent *cDoneEvent = [[ReporterEvent alloc] initWithEventName:@"suiteDone"
                                                                payload:@{
        @"description": @"suite c",
        @"status": @"passed"
        // TODO other properties esp. failedExpectations
    }];
    ReporterEvent *bDoneEvent = [[ReporterEvent alloc] initWithEventName:@"suiteDone"
                                                                payload:@{
        @"description": @"suite b",
        @"status": @"passed"
    }];
    ReporterEvent *dStartedEvent = [[ReporterEvent alloc] initWithEventName:@"suiteStarted"
                                                                   payload:@{
        @"description": @"suite d"
    }];
    ReporterEvent *dDoneEvent = [[ReporterEvent alloc] initWithEventName:@"suiteDone"
                                                                payload:@{
        @"description": @"suite d",
        @"status": @"passed"
    }];
    ReporterEvent *aDoneEvent = [[ReporterEvent alloc] initWithEventName:@"suiteDone"
                                                                payload:@{
        @"description": @"suite a",
        @"status": @"passed"
    }];

    NSError *error;
    XCTAssertTrue([self.subject handleEvent:aStartedEvent error:&error]);
    XCTAssertNil(error);
    XCTAssertTrue([self.subject handleEvent:bStartedEvent error:&error]);
    XCTAssertNil(error);
    XCTAssertTrue([self.subject handleEvent:cStartedEvent error:&error]);
    XCTAssertNil(error);

    XCTAssertEqual(self.emittedNodes.count, 3);
    
    for (SuiteOrSpec *node in self.emittedNodes) {
        XCTAssertTrue([node isKindOfClass:[Suite class]]);
        XCTAssertEqual(node.status, SuiteOrSpecStatusRunning);
    }
        
    XCTAssertEqualObjects(self.emittedNodes[0].name, @"suite a");
    XCTAssertEqualObjects(self.emittedNodes[1].name, @"suite b");
    XCTAssertEqualObjects(self.emittedNodes[2].name, @"suite c");
    
    XCTAssertTrue([self.emittedNodes[0].parent isKindOfClass:[TopSuite class]]);
    XCTAssertEqual(self.emittedNodes[1].parent, self.emittedNodes[0]);
    XCTAssertEqual(self.emittedNodes[2].parent, self.emittedNodes[1]);

    XCTAssertTrue([self.subject handleEvent:cDoneEvent error:&error]);
    XCTAssertNil(error);
    XCTAssertTrue([self.subject handleEvent:bDoneEvent error:&error]);
    XCTAssertNil(error);
    
    XCTAssertEqual(self.emittedNodes.count, 5);
    XCTAssertEqual(self.emittedNodes[0].status, SuiteOrSpecStatusRunning);
    
    for (int i = 1; i < self.emittedNodes.count; i++) {
        XCTAssertEqual(self.emittedNodes[i].status, SuiteOrSpecStatusPassed);
    }
    
    // Same instances
    XCTAssertEqual(self.emittedNodes[4], self.emittedNodes[1]);
    XCTAssertEqual(self.emittedNodes[3], self.emittedNodes[2]);
    
    XCTAssertTrue([self.subject handleEvent:dStartedEvent error:&error]);
    XCTAssertNil(error);

    XCTAssertEqual(self.emittedNodes.count, 6);
    XCTAssertEqual(self.emittedNodes[5].status, SuiteOrSpecStatusRunning);
    XCTAssertEqualObjects(self.emittedNodes[5].name, @"suite d");

    XCTAssertTrue([self.subject handleEvent:dDoneEvent error:&error]);
    XCTAssertNil(error);
    
    XCTAssertEqual(self.emittedNodes.count, 7);
    XCTAssertEqual(self.emittedNodes[6].status, SuiteOrSpecStatusPassed);
    XCTAssertEqual(self.emittedNodes[6], self.emittedNodes[5]);


    XCTAssertTrue([self.subject handleEvent:aDoneEvent error:&error]);
    XCTAssertNil(error);
    
    XCTAssertEqual(self.emittedNodes.count, 8);
    XCTAssertEqual(self.emittedNodes[7].status, SuiteOrSpecStatusPassed);
    XCTAssertEqual(self.emittedNodes[7], self.emittedNodes[0]);
}

- (void)reporterTreeBuilder:(nonnull ReporterTreeBuilder *)sender didUpdateNode:(nonnull SuiteOrSpec *)node {
    [self.emittedNodes addObject:node];
}

@end
