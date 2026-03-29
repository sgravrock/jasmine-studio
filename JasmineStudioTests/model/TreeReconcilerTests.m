//
//  TreeReconcilerTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <XCTest/XCTest.h>
#import "TreeReconciler.h"
#import "TreeNode.h"

@interface TreeReconcilerTests : XCTestCase<TreeReconcilerDelegate>
@property (nonatomic, strong) NSMutableArray<TreeNode *> *updatedNodes;
@property (nonatomic, strong) TopSuite *topSuite;
@property (nonatomic, strong) TreeReconciler *subject;
@end

@implementation TreeReconcilerTests

- (void)setUp {
    self.updatedNodes = [NSMutableArray array];
    self.topSuite = [[TopSuite alloc] init];
    
    SuiteOrSpec *root0 = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                      name:@"root 0"];
    [self.topSuite.children addObject:root0];
    SuiteOrSpec *root1 = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                      name:@"root 1"];
    [self.topSuite.children addObject:root1];
    SuiteOrSpec *child0 = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                       name:@"child 0"];
    [root0.children addObject:child0];
    child0.parent = root0;
    SuiteOrSpec *child1 = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                       name:@"child 1"];
    [root0.children addObject:child1];
    child1.parent = root0;
    SuiteOrSpec *spec = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSpec
                                                     name:@"spec"];
    [child0.children addObject:spec];
    spec.parent = child0;
    
    self.subject = [[TreeReconciler alloc] initWithRoot:self.topSuite];
    self.subject.delegate = self;
}

// TODO: the old root/non root distinction is no longer interesting now that we model the top suite

- (void)testUpdatesTopSuite {
    TopSuite *changed = [[TopSuite alloc] init];
    changed.status = TopSuiteStatusFailed;
    
    [self.subject applyChange:changed];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], self.topSuite);
    XCTAssertEqual(self.topSuite.status, TopSuiteStatusFailed);
}

- (void)testUpdatesNonRootNode {
    SuiteOrSpec *target = self.topSuite.children[0].children[1];
    XCTAssertEqualObjects(target.name, @"child 1");
    SuiteOrSpec *parentOfChanged = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                                name:@"root 0"];
    SuiteOrSpec *changed = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                        name:@"child 1"];
    changed.status = SuiteOrSpecStatusFailed;
    changed.parent = parentOfChanged;
    [parentOfChanged.children addObject:changed];
    
    [self.subject applyChange:changed];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], target);
    XCTAssertEqual(target.status, SuiteOrSpecStatusFailed);
}

- (void)testHandlesNonRootAddition {
    SuiteOrSpec *target = self.topSuite.children[0];
    XCTAssertEqualObjects(target.name, @"root 0");
    SuiteOrSpec *parentOfChanged = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                                name:@"root 0"];
    SuiteOrSpec *changed = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                        name:@"child 2"];
    changed.parent = parentOfChanged;
    [parentOfChanged.children addObject:changed];
    
    [self.subject applyChange:changed];

    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], target);
    XCTAssertEqual(target.children.count, 3);
    XCTAssertEqual(target.children[2], changed);
}

- (void)testHandlesRootChange {
    SuiteOrSpec *target = self.topSuite.children[0];
    XCTAssertEqualObjects(target.name, @"root 0");
    SuiteOrSpec *changed = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                        name:@"root 0"];
    changed.status = SuiteOrSpecStatusExcluded;
    
    [self.subject applyChange:changed];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], target);
    XCTAssertEqual(target.status, SuiteOrSpecStatusExcluded);

}

- (void)testHandlesRootAddition {
    SuiteOrSpec *changed = [[SuiteOrSpec alloc] initWithType:TreeNodeTypeSuite
                                                        name:@"new node"];
    
    [self.subject applyChange:changed];

    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], self.topSuite);
    XCTAssertEqual(self.topSuite.children.count, 3);
    XCTAssertEqual(self.topSuite.children[2], changed);
}

- (void)testHandlesLeafDeletion {
    // Passing in existing nodes is unrealistic but harmless, and avoids boilerplate
    // Update everything except the one spec
    [self.subject applyChange:self.topSuite.children[0]];
    [self.subject applyChange:self.topSuite.children[0].children[0]];
    [self.subject applyChange:self.topSuite.children[0].children[1]];
    [self.subject applyChange:self.topSuite.children[1]];
    [self.updatedNodes removeAllObjects];
    [self.subject jasmineDone];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], self.topSuite.children[0].children[0]);
    XCTAssertEqual(self.topSuite.children[0].children[0].children.count, 0);
}

- (void)testHandlesInteriorDeletion {
    // Passing in existing nodes is unrealistic but harmless, and avoids boilerplate
    // Update everything except the one spec and its parent.
    [self.subject applyChange:self.topSuite.children[0]];
    // Not updating .roots[0].children[0] and its child effectivlrey removes them.
    [self.subject applyChange:self.topSuite.children[0].children[1]];
    [self.subject applyChange:self.topSuite.children[1]];
    [self.updatedNodes removeAllObjects];
    [self.subject jasmineDone];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], self.topSuite.children[0]);
    XCTAssertEqual(self.topSuite.children[0].children.count, 1);
    XCTAssertEqualObjects(self.topSuite.children[0].children[0].name, @"child 1");
}

- (void)testHandlesRootDeletion {
    [self.subject applyChange:self.topSuite.children[1]];
    [self.updatedNodes removeAllObjects];
    [self.subject jasmineDone];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], self.topSuite);
    XCTAssertEqual(self.topSuite.children.count, 1);
    XCTAssertEqualObjects(self.topSuite.children[0].name, @"root 1");

}

- (void)treeReconciler:(TreeReconciler *)sender didUpdateNode:(TreeNode *)node {
    [self.updatedNodes addObject:node];
}

@end
