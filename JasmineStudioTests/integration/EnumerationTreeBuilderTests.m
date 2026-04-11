//
//  EnumerationTreeBuilderTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <XCTest/XCTest.h>
#import "EnumerationTreeBuilder.h"
#import "TreeNode.h"

@interface EnumerationTreeBuilderTests : XCTestCase
@end

@implementation EnumerationTreeBuilderTests

- (void)testFromJson {
    NSString *json = @"["
    "  {"
    "    \"description\": \"root suite\","
    "    \"type\": \"suite\","
    "    \"children\": ["
    "      {"
    "        \"description\": \"nested suite\","
    "        \"type\": \"suite\","
    "        \"children\": ["
    "          {"
    "            \"description\": \"spec name\","
    "            \"type\": \"spec\""
    "          }"
    "        ]"
    "      }"
    "    ]"
    "  }"
    "]";
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    EnumerationTreeBuilder *subject = [[EnumerationTreeBuilder alloc] init];

    NSError *error = nil;
    TopSuite *result = [subject fromJsonData:jsonData error:&error];
    
    XCTAssertNil(error);
    XCTAssertEqual(result.children.count, 1);
    
    SuiteOrSpec *rootSuite = result.children[0];
    XCTAssertTrue([rootSuite isKindOfClass:[Suite class]]);
    XCTAssertEqualObjects(rootSuite.name, @"root suite");
    XCTAssertNil(rootSuite.parent);
    XCTAssertEqual(rootSuite.children.count, 1);
    
    SuiteOrSpec *nestedSuite = rootSuite.children[0];
    XCTAssertTrue([nestedSuite isKindOfClass:[Suite class]]);
    XCTAssertEqualObjects(nestedSuite.name, @"nested suite");
    XCTAssertEqual(nestedSuite.parent, rootSuite); // reference equality
    XCTAssertEqual(nestedSuite.children.count, 1);
    
    SuiteOrSpec *spec = nestedSuite.children[0];
    XCTAssertTrue([spec isKindOfClass:[Spec class]]);
    XCTAssertEqualObjects(spec.name, @"spec name");
    XCTAssertEqual(nestedSuite, spec.parent); // reference equality
    XCTAssertEqual(spec.children.count, 0);
}

@end
