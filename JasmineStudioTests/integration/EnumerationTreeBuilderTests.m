//
//  EnumerationTreeBuilderTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <XCTest/XCTest.h>
#import "EnumerationTreeBuilder.h"
#import "SuiteOrSpec.h"

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
    NSArray<SuiteOrSpec *> *result = [subject fromJsonData:jsonData error:&error];
    
    XCTAssertNil(error);
    XCTAssertEqual([result count], 1);
    
    SuiteOrSpec *rootSuite = result[0];
    XCTAssertEqual(rootSuite.type, SuiteOrSpecTypeSuite);
    XCTAssertEqualObjects(rootSuite.name, @"root suite");
    XCTAssertNil(rootSuite.parent);
    XCTAssertEqual(rootSuite.children.count, 1);
    
    SuiteOrSpec *nestedSuite = rootSuite.children[0];
    XCTAssertEqual(nestedSuite.type, SuiteOrSpecTypeSuite);
    XCTAssertEqualObjects(nestedSuite.name, @"nested suite");
    XCTAssertEqual(nestedSuite.parent, rootSuite); // reference equality
    XCTAssertEqual(nestedSuite.children.count, 1);
    
    SuiteOrSpec *spec = nestedSuite.children[0];
    XCTAssertEqual(spec.type, SuiteOrSpecTypeSpec);
    XCTAssertEqualObjects(spec.name, @"spec name");
    XCTAssertEqual(nestedSuite, spec.parent); // reference equality
    XCTAssertEqual(spec.children.count, 0);
}

@end
