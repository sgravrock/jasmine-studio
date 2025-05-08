//
//  JasmineTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/29/25.
//

#import <XCTest/XCTest.h>
#import "Jasmine.h"
#import "MockExternalCommandRunner.h"
#import "StubSuiteNode.h"
#import "ProjectConfig.h"
#import "ReadableExpectation.h"

@interface JasmineTests : XCTestCase<JasmineDelegate>
@property (nonatomic, strong) ReadableExpectation *finishedWithExitCodeExpectation;
@property (nonatomic, strong) NSError *receivedError;
@property (nonatomic, assign) int receivedExitCode;
@property (nonatomic, strong) NSMutableArray *receivedLines;
@end

@implementation JasmineTests

- (void)setUp {
    self.finishedWithExitCodeExpectation = [[ReadableExpectation alloc] initWithDescription:@"finishedWithExitCode called"];
    self.receivedError = nil;
    self.receivedExitCode = 0;
    self.receivedLines = [NSMutableArray array];
}

- (void)testEnumerateWithCallback {
    MockExternalCommandRunner *cmdRunner = [[MockExternalCommandRunner alloc] init];
    ProjectConfig *config = [[ProjectConfig alloc] initWithPath:@"myPath"
                                                       nodePath:@"myNodePath"
                                                 projectBaseDir:@"myBaseDir"];
    Jasmine *subject = [[Jasmine alloc] initWithConfig:config
                                         commandRunner:cmdRunner];
    __block BOOL callbackCalled = NO;
    __block NSArray<SuiteNode *> *receivedResult = nil;
    __block NSError *receivedError = nil;
    [subject enumerateWithCallback:^(NSArray<SuiteNode *> * _Nullable result, NSError * _Nullable error) {
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
    XCTAssertEqual(receivedResult[0].type, SuiteNodeTypeSpec);
    XCTAssertEqualObjects(receivedResult[0].name, @"foo");
}

- (void)testRunNode {
    MockExternalCommandRunner *cmdRunner = [[MockExternalCommandRunner alloc] init];
    ProjectConfig *config = [[ProjectConfig alloc] initWithPath:@"myPath"
                                                       nodePath:@"myNodePath"
                                                 projectBaseDir:@"myBaseDir"];
    Jasmine *subject = [[Jasmine alloc] initWithConfig:config
                                         commandRunner:cmdRunner];
    subject.delegate = self;
    SuiteNode *node = [[StubSuiteNode alloc] initWithType:SuiteNodeTypeSpec
                                                     path:@[@"foo", @"bar", @"baz"]];

    [subject runNode:node];
    
    XCTAssertFalse(self.finishedWithExitCodeExpectation.isFulfilled);
    XCTAssertEqualObjects(cmdRunner.lastExecutablePath, @"myNodePath");
    XCTAssertEqualObjects(cmdRunner.lastCwd, @"myBaseDir");
    XCTAssertNotNil(cmdRunner.lastDelegate);
    
    // For now, output is just passed through
    [cmdRunner.lastDelegate streamingExecution:nil
                                readOutputLine:[@"hello\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [cmdRunner.lastDelegate streamingExecution:nil
                                readOutputLine:[@"world\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [cmdRunner.lastDelegate streamingExecution:nil finishedWithExitCode:0];
    
    [self waitForExpectations:@[self.finishedWithExitCodeExpectation] timeout:1];
    XCTAssertEqual(self.receivedExitCode, 0);
    XCTAssertNil(self.receivedError);
    NSArray *expectedLines = @[@"hello\n", @"world\n"];
    XCTAssertEqualObjects(self.receivedLines, expectedLines);
}

#pragma mark - JasmineDelegate

- (void)jasmine:(nonnull Jasmine *)sender runDidOutputLine:(nonnull NSString *)line { 
    [self.receivedLines addObject:line];
}

- (void)jasmine:(nonnull Jasmine *)sender runFailedWithError:(nonnull NSError *)error { 
    self.receivedError = error;
}

- (void)jasmine:(nonnull Jasmine *)sender runFinishedWithExitCode:(int)exitCode { 
    self.receivedExitCode = exitCode;
    [self.finishedWithExitCodeExpectation fulfill];
}

@end
