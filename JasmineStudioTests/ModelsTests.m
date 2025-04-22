//
//  ModelsTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <XCTest/XCTest.h>
#import "Models.h"

@interface ModelsTests : XCTestCase

@end

@implementation ModelsTests

- (void)testSuiteNodesFromJson {
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

    NSError *error = nil;
    NSArray<id<SuiteNode>> *result = suiteNodesFromJson(jsonData, &error);
    
    XCTAssertNil(error);
    XCTAssertEqual(1, [result count]);
    XCTAssertTrue([[result objectAtIndex:0] isKindOfClass:[Suite class]]);
    Suite *rootSuite = [result objectAtIndex:0];
    XCTAssertEqualObjects(@"root suite", rootSuite.name);
    XCTAssertEqual(1, rootSuite.children.count);
    XCTAssertTrue([rootSuite.children[0] isKindOfClass:[Suite class]]);
    Suite *nestedSuite = rootSuite.children[0];
    XCTAssertEqualObjects(@"nested suite", nestedSuite.name);
    XCTAssertEqual(1, nestedSuite.children.count);
    XCTAssertTrue([nestedSuite.children[0] isKindOfClass:[Spec class]]);
    Spec *spec = nestedSuite.children[0];
    XCTAssertEqualObjects(@"spec name", spec.name);
}

@end
