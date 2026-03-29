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
#import "StubSuiteNode.h"
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
    __block NSArray<SuiteOrSpec *> *receivedResult = nil;
    __block NSError *receivedError = nil;
    [subject enumerateWithCallback:^(NSArray<SuiteOrSpec *> * _Nullable result, NSError * _Nullable error) {
        callbackCalled = YES;
        receivedResult = result;
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
    XCTAssertEqual(receivedResult.count, 1);
    XCTAssertEqual(receivedResult[0].type, SuiteOrSpecTypeSpec);
    XCTAssertEqualObjects(receivedResult[0].name, @"foo");
}

- (void)testRunNode {
    MockExternalCommandRunner *cmdRunner = [[MockExternalCommandRunner alloc] init];
    ProjectConfig *config = [[ProjectConfig alloc] initWithPath:@"myPath"
                                                       nodePath:@"myNodePath"
                                                 projectBaseDir:@"myBaseDir"];
    JasmineRunner *subject = [[JasmineRunner alloc] initWithConfig:config
                                                     commandRunner:cmdRunner];
    subject.delegate = self;
    SuiteOrSpec *node = [[StubSuiteNode alloc] initWithType:SuiteOrSpecTypeSpec
                                                     path:@[@"foo", @"bar", @"baz"]];
    
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
    //    XCTAssertEqualObjects(self.receivedReporterEvents[1].eventName, @"suiteStarted");
    //    XCTAssertEqualObjects(self.receivedReporterEvents[2].eventName, @"specStarted");
//    NSArray *expectedClasses = @[
//        @"ReporterEvent",
//        @"ReporterEvent",
//        @"__NSCFString",
//        @"ReporterEvent",
//        @"__NSCFString",
//    ];
//    for (int i = 0; i < self.receivedOutputs.count; i++) {
//        // Can't embed NSStringFromClass in an invocation of XCTAssert* macros
//        NSString *actualClass = NSStringFromClass(self.receivedOutputs[i].class);
//        XCTAssertEqualObjects(actualClass, expectedClasses[i]);
//    }

    
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
