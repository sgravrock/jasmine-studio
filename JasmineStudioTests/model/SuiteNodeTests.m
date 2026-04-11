//
//  SuiteNodeTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <XCTest/XCTest.h>
#import "TreeNode.h"

@interface ModelsTests : XCTestCase

@end

@implementation ModelsTests

- (void)testPathForTopSuite {
    TopSuite *topSuite = [[TopSuite alloc] init];
    XCTAssertEqualObjects([topSuite path], @[]);
}

- (void)testPath {
    Suite *target = [[Suite alloc] initWithName:@"baz"];
    Suite *parent = [[Suite alloc] initWithName:@"bar"];
    TopSuite *root = [[TopSuite alloc] init];
    target.parent = parent;
    parent.parent = root;
    NSArray *expectedPath = @[@"bar", @"baz"];
    XCTAssertEqualObjects([target path], expectedPath);
}

@end
