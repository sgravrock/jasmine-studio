//
//  StreamingExecutionTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 5/4/25.
//

#import <XCTest/XCTest.h>
#import "StreamingExecution.h"
#import "MockTask.h"
#import "ReadableExpectation.h"

@interface StreamingExecutionTests : XCTestCase<StreamingExecutionDelegate>
@property (nonatomic, strong) MockTask *task;
@property (nonatomic, strong) StreamingExecution *subject;

// Delegate call tracking
@property (nonatomic, strong) ReadableExpectation *finishedWithExitCodeExpectation;
@property (nonatomic, strong) ReadableExpectation *finishedWithErrorExpectation;
@property (nonatomic, strong) NSError *finishedWithError;
@property (nonatomic, assign) int exitCode;
@property (nonatomic, strong) NSMutableArray<NSData *> *outputLines;
@end

@implementation StreamingExecutionTests

- (void)setUp {
    self.finishedWithError = nil;
    self.finishedWithExitCodeExpectation = [[ReadableExpectation alloc] initWithDescription:@"finishedWithExitCode called"];
    self.finishedWithErrorExpectation = [[ReadableExpectation alloc] initWithDescription:@"finishedWithError called"];
    self.exitCode = INT_MIN;
    self.outputLines = [NSMutableArray array];
    self.task = [[MockTask alloc] init];
    self.subject = [[StreamingExecution alloc] initWithConfiguredTask:(NSTask *)self.task];
    self.subject.delegate = self;
}

- (void)testLaunchFailure {
    NSError *error = [[NSError alloc] initWithDomain:@"test" code:-1 userInfo:nil];
    [self.task failLaunchWithError:error];
    
    [self.subject start];
    
    [self waitForExpectations:@[self.finishedWithErrorExpectation] timeout:1];
    XCTAssertEqualObjects(self.finishedWithError, error);
    XCTAssertFalse(self.finishedWithExitCodeExpectation.isFulfilled);
    XCTAssertEqual(self.outputLines.count, 0);
}

- (void)testReportsExitCode {
    [self.subject start];
    self.task.terminationStatus = 42;
    [[(NSPipe *)self.task.standardOutput fileHandleForWriting] closeFile];
    [self waitForExpectations:@[self.finishedWithExitCodeExpectation] timeout:1];
    XCTAssertEqual(self.exitCode, 42);
}

- (void)testReadsOutput {
    [self.subject start];
    NSFileHandle *fh = [(NSPipe *)self.task.standardOutput fileHandleForWriting];
    
    [fh writeData:[@"line 1\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[@"line 2\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // Do a quick sleep between these next two to increse the chance that reads won't be exactly aligned with lines
    [fh writeData:[@"line 3\nli" dataUsingEncoding:NSUTF8StringEncoding]];
    [NSThread sleepForTimeInterval:0.25];
    [fh writeData:[@"ne 4\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // Last line shoudld be reported even if it doesn't end with a newline
    [fh writeData:[@"line 5" dataUsingEncoding:NSUTF8StringEncoding]];
    [[(NSPipe *)self.task.standardOutput fileHandleForWriting] closeFile];
    self.task.terminationStatus = 0;
    
    [self waitForExpectations:@[self.finishedWithExitCodeExpectation] timeout:1];
    XCTAssertEqual(self.outputLines.count, 5);
    XCTAssertEqualObjects(
                          [[NSString alloc] initWithData:self.outputLines[0] encoding:NSUTF8StringEncoding],
                          @"line 1\n");
    XCTAssertEqualObjects(
                          [[NSString alloc] initWithData:self.outputLines[1] encoding:NSUTF8StringEncoding],
                          @"line 2\n");
    XCTAssertEqualObjects(
                          [[NSString alloc] initWithData:self.outputLines[2] encoding:NSUTF8StringEncoding],
                          @"line 3\n");
    XCTAssertEqualObjects(
                          [[NSString alloc] initWithData:self.outputLines[3] encoding:NSUTF8StringEncoding],
                          @"line 4\n");
    XCTAssertEqualObjects(
                          [[NSString alloc] initWithData:self.outputLines[4] encoding:NSUTF8StringEncoding],
                          @"line 5");
}

- (void)streamingExecution:(nonnull StreamingExecution *)sender
         finishedWithError:(nonnull NSError *)error {
    self.finishedWithError = error;
    [self.finishedWithErrorExpectation fulfill];
}

- (void)streamingExecution:(nonnull StreamingExecution *)sender
      finishedWithExitCode:(int)exitCode {
    self.exitCode = exitCode;
    [self.finishedWithExitCodeExpectation fulfill];
}

- (void)streamingExecution:(nonnull StreamingExecution *)sender
            readOutputLine:(nonnull NSData *)line {
    [self.outputLines addObject:line];
}

@end
