//
//  SuiteNodeTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <XCTest/XCTest.h>
#import "SuiteOrSpec.h"

@interface ModelsTests : XCTestCase

@end

@implementation ModelsTests

- (void)testPathForRootNode {
    SuiteOrSpec *node = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSpec name:@"foo"];
    XCTAssertEqualObjects([node path], @[@"foo"]);
}

- (void)testPathForNonRootNode {
    SuiteOrSpec *target = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite name:@"baz"];
    SuiteOrSpec *parent = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite name:@"bar"];
    SuiteOrSpec *root = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite name:@"foo"];
    target.parent = parent;
    parent.parent = root;
    NSArray *expectedPath = @[@"foo", @"bar", @"baz"];
    XCTAssertEqualObjects([target path], expectedPath);
}

@end
