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

@interface JasmineTests : XCTestCase
@end

@implementation JasmineTests

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
    
    XCTAssertFalse(callbackCalled);
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

- (void)testRunNodeWithCallback {
    MockExternalCommandRunner *cmdRunner = [[MockExternalCommandRunner alloc] init];
    ProjectConfig *config = [[ProjectConfig alloc] initWithPath:@"myPath"
                                                       nodePath:@"myNodePath"
                                                 projectBaseDir:@"myBaseDir"];
    Jasmine *subject = [[Jasmine alloc] initWithConfig:config
                                         commandRunner:cmdRunner];
    SuiteNode *node = [[StubSuiteNode alloc] initWithType:SuiteNodeTypeSpec
                                                     path:@[@"foo", @"bar", @"baz"]];
    __block BOOL callbackCalled = NO;
    __block BOOL receivedPassed = NO;
    __block NSString * receivedOutput = nil;
    __block NSError *receivedError = nil;
    [subject runNode:node withCallback:^(BOOL passed, NSString * _Nullable output, NSError * _Nullable error) {
        callbackCalled = YES;
        receivedPassed = passed;
        receivedOutput = output;
        receivedError = error;
    }];
    
    XCTAssertFalse(callbackCalled);
    XCTAssertEqualObjects(cmdRunner.lastExecutablePath, @"myNodePath");
    XCTAssertEqualObjects(cmdRunner.lastCwd, @"myBaseDir");
    NSArray *expectedArgs = @[
        @"myBaseDir/node_modules/.bin/jasmine",
        @"--filter-path=[\"foo\",\"bar\",\"baz\"]"
    ];
    XCTAssertEqualObjects(cmdRunner.lastArgs, expectedArgs);

    // For now, output is just passed through
    cmdRunner.lastCompletionHandler(0, [@"hello" dataUsingEncoding:NSUTF8StringEncoding], nil);
    
    XCTAssertTrue(callbackCalled);
    XCTAssertTrue(receivedPassed);
    XCTAssertNil(receivedError);
    XCTAssertEqualObjects(receivedOutput, @"hello");
}

@end
