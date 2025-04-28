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
    NSArray<SuiteNode *> *result = suiteNodesFromJson(jsonData, &error);
    
    XCTAssertNil(error);
    XCTAssertEqual([result count], 1);
    
    SuiteNode *rootSuite = result[0];
    XCTAssertEqual(rootSuite.type, SuiteNodeTypeSuite);
    XCTAssertEqualObjects(rootSuite.name, @"root suite");
    XCTAssertNil(rootSuite.parent);
    XCTAssertEqual(rootSuite.children.count, 1);
    
    SuiteNode *nestedSuite = rootSuite.children[0];
    XCTAssertEqual(nestedSuite.type, SuiteNodeTypeSuite);
    XCTAssertEqualObjects(nestedSuite.name, @"nested suite");
    XCTAssertEqual(nestedSuite.parent, rootSuite); // reference equality
    XCTAssertEqual(nestedSuite.children.count, 1);
    
    SuiteNode *spec = nestedSuite.children[0];
    XCTAssertEqual(spec.type, SuiteNodeTypeSpec);
    XCTAssertEqualObjects(spec.name, @"spec name");
    XCTAssertEqual(nestedSuite, spec.parent); // reference equality
    XCTAssertEqual(spec.children.count, 0);
}

@end
