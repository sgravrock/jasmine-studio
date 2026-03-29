//
//  JasmineRunnerTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/29/25.
//

#import <XCTest/XCTest.h>
#import "JasmineRunner.h"
#import "ReporterEvent.h"
#import "MockExternalCommandRunner.h"
#import "TreeNode.h"
#import "ProjectConfig.h"
#import "ReadableExpectation.h"

@interface JasmineRunnerTests : XCTestCase<JasmineRunnerDelegate>
@property (nonatomic, strong) ReadableExpectation *finishedWithExitCodeExpectation;
@property (nonatomic, strong) NSError *receivedError;
@property (nonatomic, assign) int receivedExitCode;
@property (nonatomic, strong) NSMutableArray *receivedOutputs;
@end

@implementation JasmineRunnerTests

- (void)setUp {
    self.finishedWithExitCodeExpectation = [[ReadableExpectation alloc] initWithDescription:@"finishedWithExitCode called"];
    self.receivedError = nil;
    self.receivedExitCode = 0;
    self.receivedOutputs = [NSMutableArray array];
}

- (void)testEnumerateWithCallback {
    MockExternalCommandRunner *cmdRunner = [[MockExternalCommandRunner alloc] init];
    ProjectConfig *config = [[ProjectConfig alloc] initWithPath:@"myPath"
                                                       nodePath:@"myNodePath"
                                                 projectBaseDir:@"myBaseDir"];
    JasmineRunner *subject = [[JasmineRunner alloc] initWithConfig:config
                                         commandRunner:cmdRunner];
    __block BOOL callbackCalled = NO;
    __block TopSuite *receivedTopSuite = nil;
    __block NSError *receivedError = nil;
    [subject enumerateWithCallback:^(TopSuite * _Nullable topSuite, NSError * _Nullable error) {
        callbackCalled = YES;
        receivedTopSuite = topSuite;
        receivedError = error;
    }];
    
    XCTAssertEqualObjects(cmdRunner.lastExecutablePath, @"myNodePath");
    XCTAssertEqualObjects(cmdRunner.lastCwd, @"myBaseDir");
    NSArray *expectedArgs = @[@"myBaseDir/node_modules/.bin/jasmine", @"enumerate"];
    XCTAssertEqualObjects(cmdRunner.lastArgs, expectedArgs);
    NSString *output = @"[{\"type\":\"spec\",\"description\":\"foo\"}]";
    cmdRunner.lastCompletionHandler(0, [output dataUsingEncoding:NSUTF8StringEncoding], nil);
    
    XCTAssertTrue(callbackCalled);
    XCTAssertNil(receivedError);
    XCTAssertEqual(receivedTopSuite.children.count, 1);
    XCTAssertEqual(receivedTopSuite.children[0].type, TreeNodeTypeSpec);
    XCTAssertEqualObjects(receivedTopSuite.children[0].name, @"foo");
}

- (void)testRunNode {
    MockExternalCommandRunner *cmdRunner = [[MockExternalCommandRunner alloc] init];
    ProjectConfig *config = [[ProjectConfig alloc] initWithPath:@"myPath"
                                                       nodePath:@"myNodePath"
                                                 projectBaseDir:@"myBaseDir"];
    JasmineRunner *subject = [[JasmineRunner alloc] initWithConfig:config
                                                     commandRunner:cmdRunner];
    subject.delegate = self;
    SuiteOrSpec *grandparent = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite name:@"foo"];
    SuiteOrSpec *parent = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite name:@"bar"];
    parent.parent = grandparent;
    SuiteOrSpec *node = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSpec name:@"baz"];
    node.parent = parent;
    
    [subject runNode:node];
    
    XCTAssertFalse(self.finishedWithExitCodeExpectation.isFulfilled);
    XCTAssertEqualObjects(cmdRunner.lastExecutablePath, @"myNodePath");
    XCTAssertEqualObjects(cmdRunner.lastCwd, @"myBaseDir");
    XCTAssertNotNil(cmdRunner.lastDelegate);
    
    NSArray<NSString *> *outputLines = @[
        @"##jasmineStudio:{\"eventName\":\"jasmineStarted\",\"payload\":{\"totalSpecsDefined\":145,\"numExcludedSpecs\":131,\"order\":{\"random\":true,\"seed\":\"31947\"},\"parallel\":false}}",
        @"##jasmineStudio:{\"eventName\":\"suiteStarted\",\"payload\":{\"id\":\"suite3\",\"description\":\"a suite\",\"fullName\":\"a suite \",\"parentSuiteId\":null}}",
        @"hello",
        @"##jasmineStudio:{\"eventName\":\"specStarted\",\"payload\":{\"id\":\"spec3\",\"description\":\"a spec\",\"fullName\":\"a suite a spec\",\"parentSuiteId\":\"suite3\"}}",
        @"world"
    ];
    
    for (NSString *line in outputLines) {
        [cmdRunner.lastDelegate streamingExecution:nil
                                    readOutputLine:[line dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [cmdRunner.lastDelegate streamingExecution:nil finishedWithExitCode:0];
    
    [self waitForExpectations:@[self.finishedWithExitCodeExpectation] timeout:1];
    XCTAssertEqual(self.receivedExitCode, 0);
    XCTAssertNil(self.receivedError);
    
    

    XCTAssertEqual(self.receivedOutputs.count, outputLines.count);
    XCTAssertEqualObjects([(id)self.receivedOutputs[0] eventName], @"jasmineStarted");
    XCTAssertEqualObjects([(id)self.receivedOutputs[1] eventName], @"suiteStarted");
    XCTAssertEqualObjects(self.receivedOutputs[2], @"hello");
    XCTAssertEqualObjects([(id)self.receivedOutputs[3] eventName], @"specStarted");
    XCTAssertEqualObjects(self.receivedOutputs[4], @"world");
}

- (void)testRunNodeTopSuite {
    MockExternalCommandRunner *cmdRunner = [[MockExternalCommandRunner alloc] init];
    ProjectConfig *config = [[ProjectConfig alloc] initWithPath:@"myPath"
                                                       nodePath:@"myNodePath"
                                                 projectBaseDir:@"myBaseDir"];
    JasmineRunner *subject = [[JasmineRunner alloc] initWithConfig:config
                                                     commandRunner:cmdRunner];
    subject.delegate = self;
    [subject runNode:[[TopSuite alloc] init]];
    
    for (NSString *arg in cmdRunner.lastArgs) {
        XCTAssertFalse([arg containsString:@"--filter-path"]);
    }
}

#pragma mark - JasmineDelegate

- (void)jasmineRunner:(nonnull JasmineRunner *)sender runDidOutputLine:(nonnull NSString *)line { 
    [self.receivedOutputs addObject:line];
}

- (void)jasmineRunner:(JasmineRunner *)sender emittedReporterEvent:(ReporterEvent *)event {
    [self.receivedOutputs addObject:event];
}

- (void)jasmineRunner:(nonnull JasmineRunner *)sender runFailedWithError:(nonnull NSError *)error { 
    self.receivedError = error;
}

- (void)jasmineRunner:(nonnull JasmineRunner *)sender runFinishedWithExitCode:(int)exitCode { 
    self.receivedExitCode = exitCode;
    [self.finishedWithExitCodeExpectation fulfill];
}

@end
