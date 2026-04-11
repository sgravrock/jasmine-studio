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
    
    Suite *root0 = [[Suite alloc] initWithName:@"root 0"];
    [self addNode:root0 toParent:self.topSuite];
    Suite *root1 = [[Suite alloc] initWithName:@"root 1"];
    [self addNode:root1 toParent:self.topSuite];
    Suite *child0 = [[Suite alloc] initWithName:@"child 0"];
    [self addNode:child0 toParent:root0];
    Suite *child1 = [[Suite alloc] initWithName:@"child 1"];
    [self addNode:child1 toParent:root0];
    Spec *spec = [[Spec alloc] initWithName:@"spec"];
    [self addNode:spec toParent:child0];
    
    self.subject = [[TreeReconciler alloc] initWithRoot:self.topSuite];
    self.subject.delegate = self;
}

- (void)testUpdatesTopSuite {
    TopSuite *changed = [[TopSuite alloc] init];
    changed.status = TopSuiteStatusFailed;
    
    [self.subject applyChange:changed];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], self.topSuite);
    XCTAssertEqual(self.topSuite.status, TopSuiteStatusFailed);
}

- (void)testUpdatesNonTopSuiteNode {
    SuiteOrSpec *target = self.topSuite.children[0].children[1];
    XCTAssertEqualObjects(target.name, @"child 1");
    TopSuite *topSuite = [[TopSuite alloc] init];
    Suite *parentOfChanged = [[Suite alloc] initWithName:@"root 0"];
    [self addNode:parentOfChanged toParent:topSuite];
    Suite *changed = [[Suite alloc] initWithName:@"child 1"];
    [self addNode:changed toParent:parentOfChanged];
    changed.status = SuiteOrSpecStatusFailed;
    
    [self.subject applyChange:changed];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], target);
    XCTAssertEqual(target.status, SuiteOrSpecStatusFailed);
}

- (void)testHandlesAddition {
    SuiteOrSpec *target = self.topSuite.children[0];
    XCTAssertEqualObjects(target.name, @"root 0");
    TopSuite *topSuite = [[TopSuite alloc] init];
    Suite *parentOfChanged = [[Suite alloc] initWithName:@"root 0"];
    [self addNode:parentOfChanged toParent:topSuite];
    Suite *changed = [[Suite alloc] initWithName:@"child 2"];
    [self addNode:changed toParent:parentOfChanged];
    
    [self.subject applyChange:changed];

    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], target);
    XCTAssertEqual(target.children.count, 3);
    XCTAssertEqual(target.children[2], changed);
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

- (void)addNode:(SuiteOrSpec *)node toParent:(TreeNode *)parent {
    node.parent = parent;
    [parent.children addObject:node];
}

- (void)treeReconciler:(TreeReconciler *)sender didUpdateNode:(TreeNode *)node {
    [self.updatedNodes addObject:node];
}

@end
