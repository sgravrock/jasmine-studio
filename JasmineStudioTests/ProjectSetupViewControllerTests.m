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
@property (nonatomic, strong) NSTextField *pathField;
@property (nonatomic, strong) InMemoryUserDefaults *userDefaults;
@end

@implementation ProjectSetupViewControllerTests

- (void)setUp {
    self.subject = [[ProjectSetupViewController alloc] init];
    self.pathField = [[NSTextField alloc] init];
    self.projectBaseDirLabel = [[NSTextField alloc] init];
    self.subject.pathField = self.pathField;
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


- (void)testRestoresPath {
    [self.userDefaults setObject:@"test path" forKey:kPathKey];
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.pathField.stringValue, @"test path");
}

- (void)testHandlesMissingPathKey {
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.pathField.stringValue, @"");
}

- (void)testIgnoresNonStringPathKey {
    [self.userDefaults setObject:[NSArray array] forKey:kPathKey];
    [self.subject configureWithUserDefaults:self.userDefaults];
    XCTAssertEqualObjects(self.pathField.stringValue, @"");
}

@end
