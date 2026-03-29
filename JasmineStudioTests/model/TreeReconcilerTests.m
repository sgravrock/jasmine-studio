//
//  TreeReconcilerTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <XCTest/XCTest.h>
#import "TreeReconciler.h"
#import "SuiteNode.h"

@interface TreeReconcilerTests : XCTestCase<TreeReconcilerDelegate>
@property (nonatomic, strong) NSMutableArray<SuiteNode *> *updatedNodes;
@property (nonatomic, assign) BOOL didAddOrRemoveRootsCalled;
@property (nonatomic, strong) NSMutableArray<SuiteNode *> *roots;
@property (nonatomic, strong) TreeReconciler *subject;
@end

@implementation TreeReconcilerTests

- (void)setUp {
    self.updatedNodes = [NSMutableArray array];
    self.didAddOrRemoveRootsCalled = NO;
    self.roots = [NSMutableArray array];
    
    SuiteNode *root0 = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                  name:@"root 0"];
    [self.roots addObject:root0];
    SuiteNode *root1 = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                  name:@"root 1"];
    [self.roots addObject:root1];
    SuiteNode *child0 = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                   name:@"child 0"];
    [root0.children addObject:child0];
    child0.parent = root0;
    SuiteNode *child1 = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                   name:@"child 1"];
    [root0.children addObject:child1];
    child1.parent = root0;
    SuiteNode *spec = [[SuiteNode alloc] initWithType:SuiteNodeTypeSpec
                                                 name:@"spec"];
    [child0.children addObject:spec];
    spec.parent = child0;
    
    self.subject = [[TreeReconciler alloc] initWithRoots:self.roots];
    self.subject.delegate = self;
}

- (void)testUpdatesNonRootNode {
    SuiteNode *target = self.roots[0].children[1];
    XCTAssertEqualObjects(target.name, @"child 1");
    SuiteNode *parentOfChanged = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                            name:@"root 0"];
    SuiteNode *changed = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                    name:@"child 1"];
    changed.status = SuiteNodeStatusFailed;
    changed.parent = parentOfChanged;
    [parentOfChanged.children addObject:changed];
    
    [self.subject applyChange:changed];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], target);
    XCTAssertEqual(target.status, SuiteNodeStatusFailed);
}

- (void)testHandlesNonRootAddition {
    SuiteNode *target = self.roots[0];
    XCTAssertEqualObjects(target.name, @"root 0");
    SuiteNode *parentOfChanged = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                            name:@"root 0"];
    SuiteNode *changed = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
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
    SuiteNode *target = self.roots[0];
    XCTAssertEqualObjects(target.name, @"root 0");
    SuiteNode *changed = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                    name:@"root 0"];
    changed.status = SuiteNodeStatusExcluded;
    
    [self.subject applyChange:changed];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], target);
    XCTAssertEqual(target.status, SuiteNodeStatusExcluded);

}

- (void)testHandlesRootAddition {
    SuiteNode *changed = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                    name:@"new node"];
    
    [self.subject applyChange:changed];

    XCTAssertEqual(self.updatedNodes.count, 0);
    XCTAssertTrue(self.didAddOrRemoveRootsCalled);
    XCTAssertEqual(self.roots.count, 3);
    XCTAssertEqual(self.roots[2], changed);
}

- (void)testHandlesLeafDeletion {
    // Passing in existing nodes is unrealistic but harmless, and avoids boilerplate
    // Update everything except the one spec
    [self.subject applyChange:self.roots[0]];
    [self.subject applyChange:self.roots[0].children[0]];
    [self.subject applyChange:self.roots[0].children[1]];
    [self.subject applyChange:self.roots[1]];
    [self.updatedNodes removeAllObjects];
    [self.subject jasmineDone];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], self.roots[0].children[0]);
    XCTAssertEqual(self.roots[0].children[0].children.count, 0);
}

- (void)testHandlesInteriorDeletion {
    // Passing in existing nodes is unrealistic but harmless, and avoids boilerplate
    // Update everything except the one spec and its parent.
    [self.subject applyChange:self.roots[0]];
    // Not updating .roots[0].children[0] and its child effectivlrey removes them.
    [self.subject applyChange:self.roots[0].children[1]];
    [self.subject applyChange:self.roots[1]];
    [self.updatedNodes removeAllObjects];
    [self.subject jasmineDone];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], self.roots[0]);
    XCTAssertEqual(self.roots[0].children.count, 1);
    XCTAssertEqualObjects(self.roots[0].children[0].name, @"child 1");
}

- (void)testHandlesRootDeletion {
    [self.subject applyChange:self.roots[1]];
    [self.updatedNodes removeAllObjects];
    self.didAddOrRemoveRootsCalled = NO;
    [self.subject jasmineDone];
    
    XCTAssertEqual(self.updatedNodes.count, 0);
    XCTAssertTrue(self.didAddOrRemoveRootsCalled);
    XCTAssertEqual(self.roots.count, 1);
    XCTAssertEqualObjects(self.roots[0].name, @"root 1");

}

- (void)treeReconciler:(TreeReconciler *)sender didUpdateNode:(SuiteNode *)node {
    [self.updatedNodes addObject:node];
}

- (void)treeReconcilerDidAddOrRemoveRoots:(TreeReconciler *)sender {
    self.didAddOrRemoveRootsCalled = YES;
}

@end
