//
//  TreeReconcilerTests.m
//  JasmineStudioTests
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <XCTest/XCTest.h>
#import "TreeReconciler.h"
#import "SuiteOrSpec.h"

@interface TreeReconcilerTests : XCTestCase<TreeReconcilerDelegate>
@property (nonatomic, strong) NSMutableArray<SuiteOrSpec *> *updatedNodes;
@property (nonatomic, assign) BOOL didAddOrRemoveRootsCalled;
@property (nonatomic, strong) NSMutableArray<SuiteOrSpec *> *roots;
@property (nonatomic, strong) TreeReconciler *subject;
@end

@implementation TreeReconcilerTests

- (void)setUp {
    self.updatedNodes = [NSMutableArray array];
    self.didAddOrRemoveRootsCalled = NO;
    self.roots = [NSMutableArray array];
    
    SuiteOrSpec *root0 = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
                                                      name:@"root 0"];
    [self.roots addObject:root0];
    SuiteOrSpec *root1 = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
                                                      name:@"root 1"];
    [self.roots addObject:root1];
    SuiteOrSpec *child0 = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
                                                       name:@"child 0"];
    [root0.children addObject:child0];
    child0.parent = root0;
    SuiteOrSpec *child1 = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
                                                       name:@"child 1"];
    [root0.children addObject:child1];
    child1.parent = root0;
    SuiteOrSpec *spec = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSpec
                                                     name:@"spec"];
    [child0.children addObject:spec];
    spec.parent = child0;
    
    self.subject = [[TreeReconciler alloc] initWithRoots:self.roots];
    self.subject.delegate = self;
}

- (void)testUpdatesNonRootNode {
    SuiteOrSpec *target = self.roots[0].children[1];
    XCTAssertEqualObjects(target.name, @"child 1");
    SuiteOrSpec *parentOfChanged = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
                                                                name:@"root 0"];
    SuiteOrSpec *changed = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
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
    SuiteOrSpec *target = self.roots[0];
    XCTAssertEqualObjects(target.name, @"root 0");
    SuiteOrSpec *parentOfChanged = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
                                                                name:@"root 0"];
    SuiteOrSpec *changed = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
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
    SuiteOrSpec *target = self.roots[0];
    XCTAssertEqualObjects(target.name, @"root 0");
    SuiteOrSpec *changed = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
                                                        name:@"root 0"];
    changed.status = SuiteOrSpecStatusExcluded;
    
    [self.subject applyChange:changed];
    
    XCTAssertEqual(self.updatedNodes.count, 1);
    XCTAssertEqual(self.updatedNodes[0], target);
    XCTAssertEqual(target.status, SuiteOrSpecStatusExcluded);

}

- (void)testHandlesRootAddition {
    SuiteOrSpec *changed = [[SuiteOrSpec alloc] initWithType:SuiteOrSpecTypeSuite
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

- (void)treeReconciler:(TreeReconciler *)sender didUpdateNode:(SuiteOrSpec *)node {
    [self.updatedNodes addObject:node];
}

- (void)treeReconcilerDidAddOrRemoveRoots:(TreeReconciler *)sender {
    self.didAddOrRemoveRootsCalled = YES;
}

@end
