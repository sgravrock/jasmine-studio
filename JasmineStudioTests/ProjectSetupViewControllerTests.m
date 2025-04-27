//
//  ProjectSetupViewControllerTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/27/25.
//

#import <XCTest/XCTest.h>
#import "ProjectSetupViewController.h"
#import "userDefaults.h"
#import "InMemoryUserDefaults.h"

@interface ProjectSetupViewControllerTests : XCTestCase
@property (nonatomic, strong) ProjectSetupViewController *subject;
@property (nonatomic, strong) NSTextField *projectBaseDirLabel;
@property (nonatomic, strong) NSTextField *nodePathField;
@property (nonatomic, strong) InMemoryUserDefaults *userDefaults;
@end

@implementation ProjectSetupViewControllerTests

- (void)setUp {
    self.subject = [[ProjectSetupViewController alloc] init];
    self.nodePathField = [[NSTextField alloc] init];
    self.projectBaseDirLabel = [[NSTextField alloc] init];
    self.subject.nodePathField = self.nodePathField;
    self.subject.projectBaseDirLabel = self.projectBaseDirLabel;
    self.userDefaults = [[InMemoryUserDefaults alloc] init];
}

- (void)testRestoresProjectBaseDir {
    [self.userDefaults setObject:@"base dir" forKey:kProjectBaseDirKey];
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.projectBaseDirLabel.stringValue, @"base dir");
}

- (void)testHandlesMissingProjectBaseDirKey {
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.projectBaseDirLabel.stringValue, @"");
}

- (void)testIgnoresNonStringProjectBaseDirKey {
    [self.userDefaults setObject:[NSArray array] forKey:kProjectBaseDirKey];
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.projectBaseDirLabel.stringValue, @"");
}


- (void)testRestoresNodePath {
    [self.userDefaults setObject:@"test node path" forKey:kNodePathKey];
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.nodePathField.stringValue, @"test node path");
}

- (void)testHandlesMissingNodePathKey {
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.nodePathField.stringValue, @"");
}

- (void)testIgnoresNonStringNodePathKey {
    [self.userDefaults setObject:[NSArray array] forKey:kNodePathKey];
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.nodePathField.stringValue, @"");
}

@end
