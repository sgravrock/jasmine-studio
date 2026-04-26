//
//  TreeUpdateIntegrationTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/12/26.
//

#import <XCTest/XCTest.h>
#import "RunnerViewController.h"
#import "TreeReconciler.h"
#import "JasmineRunner.h"
#import "ReporterEvent.h"

@interface StubJasmineRunner : JasmineRunner
@property (nonatomic, strong) EnumerationCallback enumerationCallback;
@end

@implementation StubJasmineRunner

- (void)enumerateWithCallback:(EnumerationCallback)callback {
    self.enumerationCallback = callback;
}

- (void)runNode:(TreeNode *)node {}

@end


@interface TreeUpdateIntegrationTests : XCTestCase
@property (nonatomic, strong) StubJasmineRunner *jasmineRunner;
@property (nonatomic, strong) RunnerViewController *runnerVC;
@property (nonatomic, strong) TopSuite *topSuite;
@property (nonatomic, strong) Suite *rootSuite1;
@property (nonatomic, strong) Suite *rootSuite2;
@property (nonatomic, strong) Suite *nestedSuite;
@property (nonatomic, strong) Spec *nestedSpec;
@property (nonatomic, strong) Spec *rootSpec;
@end

@implementation TreeUpdateIntegrationTests

- (void)setUp {
    self.jasmineRunner = [[StubJasmineRunner alloc] init];
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *wc = [sb instantiateControllerWithIdentifier:@"runnerWindowController"];
    self.runnerVC = (RunnerViewController *)wc.window.contentViewController;
    self.runnerVC.jasmineRunner = self.jasmineRunner;
    
    [self createSuite];
}

- (void)createSuite {
    self.topSuite = [[TopSuite alloc] init];
    
    self.rootSuite1 = [[Suite alloc] initWithName:@"rootSuite1"];
    [self addChild:self.rootSuite1 toParent:self.topSuite];
    self.nestedSuite = [[Suite alloc] initWithName:@"nestedSuite"];
    [self addChild:self.nestedSuite toParent:self.rootSuite1];
    self.nestedSpec = [[Spec alloc] initWithName:@"nestedSpec"];
    [self addChild:self.nestedSpec toParent:self.nestedSuite];
    
    self.rootSuite2 = [[Suite alloc] initWithName:@"rootSuite2"];
    [self addChild:self.rootSuite2 toParent:self.topSuite];
    
    self.rootSpec = [[Spec alloc] initWithName:@"rootSpec"];
    [self addChild:self.rootSpec toParent:self.topSuite];
}

- (NSArray<NSString *> *)allEventsWithMinimalPayloads {
    return @[
        @"##jasmineStudio:{\"eventName\":\"jasmineStarted\",\"payload\":{}}",
        @"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"description\":\"rootSuite1\"}}",
        @"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"description\":\"nestedSuite\"}}",
        @"##jasmineStudio:{\"eventName\":\"specStarted\",\"payload\":{\"description\":\"nestedSpec\"}}",
        @"##jasmineStudio:{\"eventName\":\"specDone\",\"payload\":{\"description\":\"nestedSpec\"}}",
        @"##jasmineStudio:{\"eventName\":\"suiteDone\",\"payload\":{\"description\":\"nestedSuite\"}}",
        @"##jasmineStudio:{\"eventName\":\"suiteDone\",\"payload\":{\"description\":\"rootSuite1\"}}",
        @"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"description\":\"rootSuite2\"}}",
        @"##jasmineStudio:{\"eventName\":\"suiteDone\",\"payload\":{\"description\":\"rootSuite2\"}}",
        @"##jasmineStudio:{\"eventName\":\"jasmineDone\",\"payload\":{}}",
        @"##jasmineStudio:{\"eventName\":\"specStarted\",\"payload\":{\"description\":\"rootSpec\"}}",
        @"##jasmineStudio:{\"eventName\":\"specDone\",\"payload\":{\"description\":\"rootSpec\"}}"
    ];
}

- (void)addChild:(SuiteOrSpec *)child toParent:(TreeNode *)parent {
    child.parent = parent;
    [parent.children addObject:child];
}

- (void)report:(NSString *)outputLine {
    NSError *error = nil;
    ReporterEvent *event = [ReporterEvent fromOutputLine:outputLine error:&error];
    XCTAssertNil(error);
    [self.jasmineRunner.delegate jasmineRunner:self.jasmineRunner emittedReporterEvent:event];
}

- (void)testUpdatesExistingNodes {
    [self.runnerVC loadSuite];
    self.jasmineRunner.enumerationCallback(self.topSuite, nil);
    [self.runnerVC suiteTreeViewController:nil runNode:self.topSuite];
    
    [self report:@"##jasmineStudio:{\"eventName\":\"jasmineStarted\",\"payload\":{}}"];
    [self report:@"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"description\":\"rootSuite1\"}}"];
    [self report:@"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"description\":\"nestedSuite\"}}"];
    [self report:@"##jasmineStudio:{\"eventName\":\"specStarted\",\"payload\":{\"description\":\"nestedSpec\"}}"];
    [self report:@"##jasmineStudio:{\"eventName\":\"specDone\",\"payload\":{\"description\":\"nestedSpec\",\"status\":\"failed\"}}"];
    
    XCTAssertEqual(self.nestedSpec.status, SuiteOrSpecStatusFailed);
}

- (void)testMaintainsTreeStructureWhenUnchanged {
    [self.runnerVC loadSuite];
    self.jasmineRunner.enumerationCallback(self.topSuite, nil);
    [self.runnerVC suiteTreeViewController:nil runNode:self.topSuite];
    
    for (NSString *event in [self allEventsWithMinimalPayloads]) {
        [self report:event];
    }
    
//    [self report:@"##jasmineStudio:{\"eventName\":\"jasmineStarted\",\"payload\":{}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"description\":\"rootSuite1\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"description\":\"nestedSuite\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"specStarted\",\"payload\":{\"description\":\"nestedSpec\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"specDone\",\"payload\":{\"description\":\"nestedSpec\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"suiteDone\",\"payload\":{\"description\":\"nestedSuite\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"suiteDone\",\"payload\":{\"description\":\"rootSuite1\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"description\":\"rootSuite2\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"suiteDone\",\"payload\":{\"description\":\"rootSuite2\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"jasmineDone\",\"payload\":{}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"specStarted\",\"payload\":{\"description\":\"rootSpec\"}}"];
//    [self report:@"##jasmineStudio:{\"eventName\":\"specDone\",\"payload\":{\"description\":\"rootSpec\"}}"];
    [self.jasmineRunner.delegate jasmineRunner:self.jasmineRunner runFinishedWithExitCode:0];

    XCTAssertEqual(self.topSuite.children.count, 3);
    XCTAssertEqual(self.rootSuite1.children.count, 1);
    XCTAssertEqual(self.nestedSuite.children.count, 1);
    XCTAssertEqual(self.rootSuite2.children.count, 0);
    // Test pointer equality. We expect unchanged nodes to not be replaced.
    // Replacing them would cause loss of associated UI state.
    XCTAssertEqual(self.topSuite.children[0], self.rootSuite1);
    XCTAssertEqual(self.topSuite.children[1], self.rootSuite2);
    XCTAssertEqual(self.topSuite.children[2], self.rootSpec);
    XCTAssertEqual(self.rootSuite1.children[0], self.nestedSuite);
    XCTAssertEqual(self.nestedSuite.children[0], self.nestedSpec);
}

- (void)testHandlesRemovedSpec {
    [self.runnerVC loadSuite];
    self.jasmineRunner.enumerationCallback(self.topSuite, nil);
    [self.runnerVC suiteTreeViewController:nil runNode:self.topSuite];
    
    for (NSString *event in [self allEventsWithMinimalPayloads]) {
        if (![event containsString:@"nestedSpec"]) {
            [self report:event];
        }
    }
    
    [self.jasmineRunner.delegate jasmineRunner:self.jasmineRunner runFinishedWithExitCode:0];

    XCTAssertEqual(self.nestedSuite.children.count, 0);
}

- (void)testHandlesRemovedInteriorSuite {
    [self.runnerVC loadSuite];
    self.jasmineRunner.enumerationCallback(self.topSuite, nil);
    [self.runnerVC suiteTreeViewController:nil runNode:self.topSuite];
    
    for (NSString *event in [self allEventsWithMinimalPayloads]) {
        if (!([event containsString:@"nestedSpec"] || [event containsString:@"nestedSuite"])) {
            [self report:event];
        }
    }
    
    [self.jasmineRunner.delegate jasmineRunner:self.jasmineRunner runFinishedWithExitCode:0];

    XCTAssertEqual(self.rootSuite1.children.count, 0);
}

- (void)testHandlesRemovedRootSuite {
    [self.runnerVC loadSuite];
    self.jasmineRunner.enumerationCallback(self.topSuite, nil);
    [self.runnerVC suiteTreeViewController:nil runNode:self.topSuite];
    
    for (NSString *event in [self allEventsWithMinimalPayloads]) {
        if (![event containsString:@"rootSuite2"]) {
            [self report:event];
        }
    }
    
    [self.jasmineRunner.delegate jasmineRunner:self.jasmineRunner runFinishedWithExitCode:0];

    XCTAssertEqual(self.topSuite.children.count, 2);
    // Test pointer equality. We expect unchanged nodes to not be replaced.
    // Replacing them would cause loss of associated UI state.
    XCTAssertEqual(self.topSuite.children[0], self.rootSuite1);
    XCTAssertEqual(self.topSuite.children[1], self.rootSpec);

}

@end
