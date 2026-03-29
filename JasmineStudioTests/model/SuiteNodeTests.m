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

- (void)testPathForRootNode {
    SuiteOrSpec *node = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSpec name:@"foo"];
    XCTAssertEqualObjects([node path], @[@"foo"]);
}

- (void)testPathForNonRootNode {
    SuiteOrSpec *target = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite name:@"baz"];
    SuiteOrSpec *parent = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite name:@"bar"];
    SuiteOrSpec *root = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite name:@"foo"];
    target.parent = parent;
    parent.parent = root;
    NSArray *expectedPath = @[@"foo", @"bar", @"baz"];
    XCTAssertEqualObjects([target path], expectedPath);
}

@end
