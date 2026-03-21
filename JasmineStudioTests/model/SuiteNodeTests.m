//
//  SuiteNodeTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <XCTest/XCTest.h>
#import "SuiteNode.h"

@interface ModelsTests : XCTestCase

@end

@implementation ModelsTests

- (void)testPathForRootNode {
    SuiteNode *node = [[SuiteNode alloc] initWithType:SuiteNodeTypeSpec name:@"foo"];
    XCTAssertEqualObjects([node path], @[@"foo"]);
}

- (void)testPathForNonRootNode {
    SuiteNode *target = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite name:@"baz"];
    SuiteNode *parent = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite name:@"bar"];
    SuiteNode *root = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite name:@"foo"];
    target.parent = parent;
    parent.parent = root;
    NSArray *expectedPath = @[@"foo", @"bar", @"baz"];
    XCTAssertEqualObjects([target path], expectedPath);
}

@end
