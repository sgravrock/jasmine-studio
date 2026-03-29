//
//  TreeReconciler.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import "TreeReconciler.h"
#import "SuiteNode.h"

@interface TreeReconciler()
@property (nonatomic, strong) NSMutableSet<SuiteNode *> *seen;
@end

@implementation TreeReconciler

- (instancetype)initWithRoots:(NSMutableArray<SuiteNode *> *)roots {
    self = [super init];
    
    if (self) {
        _roots = roots;
        _seen = [NSMutableSet set];
    }
    
    return self;
}

// TODO: Switching to a single tree (i.e. synthetic top suite) instead of an
// array of trees would make this a lot cleaner.

- (void)applyChange:(SuiteNode *)changedNode {
    if (changedNode.parent == nil) {
        [self applyRootChange:changedNode];
        return;
    }
    
    SuiteNode *parent = [self existingNodeMatching:changedNode.parent];
    SuiteNode *match = [self existingNodeMatching:changedNode in:parent.children];
    
    if (match == nil) {
        // A newly discovered node
        [self.seen addObject:changedNode];
        [parent.children addObject:changedNode];
        [self.delegate treeReconciler:self didUpdateNode:parent];
    } else {
        [self.seen addObject:match];
        [self updateExistingNode:match from:changedNode];
    }
}

- (void)applyRootChange:(SuiteNode *)changedNode {
    SuiteNode *match = [self existingNodeMatching:changedNode in:self.roots];
    
    if (match == nil) {
        // A newly discovered node
        [self.seen addObject:changedNode];
        [self.roots addObject:changedNode];
        [self.delegate treeReconcilerDidAddOrRemoveRoots:self];
    } else {
        [self.seen addObject:match];
        [self updateExistingNode:match from:changedNode];
    }
}

- (void)jasmineDone {
    NSArray *rootsToRemove = [self unseenNodesIn:self.roots];
    
    if (rootsToRemove.count > 0) {
        for (SuiteNode *n in rootsToRemove) {
            [self.roots removeObjectIdenticalTo:n];
        }
        
        [self.delegate treeReconcilerDidAddOrRemoveRoots:self];
    }
    
    // Scan the remaining roots and remove unseen nodes
    for (SuiteNode *n in self.roots) {
        [self removeUnseenDescendantsOf:n];
    }
    
    
    [self.seen removeAllObjects];
}

- (void)removeUnseenDescendantsOf:(SuiteNode *)ancestor {
    NSArray *childrenToRemove = [self unseenNodesIn:ancestor.children];
    
    if (childrenToRemove.count > 0) {
        for (SuiteNode *n in childrenToRemove) {
            [ancestor.children removeObjectIdenticalTo:n];
        }
        
        [self.delegate treeReconciler:self didUpdateNode:ancestor];
    }
    
    for (SuiteNode *child in ancestor.children) {
        [self removeUnseenDescendantsOf:child];
    }
}

- (NSArray<SuiteNode *> *)unseenNodesIn:(NSArray<SuiteNode *> *)arr {
    NSMutableArray<SuiteNode *> *result = [NSMutableArray array];
    
    for (SuiteNode *n in arr) {
        if (![self.seen containsObject:n]) {
            [result addObject:n];
        }
    }
    
    return result;
}

- (void)updateExistingNode:(SuiteNode *)target from:(SuiteNode *)changedNode {
    target.status = changedNode.status;
    // TODO copy other result properties
    [self.delegate treeReconciler:self didUpdateNode:target];
}

- (SuiteNode * _Nullable)existingNodeMatching:(SuiteNode *)changedNode  {
    NSMutableArray<SuiteNode *> *candidates;
    
    if (changedNode.parent == nil) {
        candidates = self.roots;
    } else {
        candidates = [self existingNodeMatching:changedNode.parent].children;
    }

    return [self existingNodeMatching:changedNode in:candidates];
}

- (SuiteNode * _Nullable)existingNodeMatching:(SuiteNode *)changedNode in:(NSArray<SuiteNode *> *)candidates {
    for (SuiteNode *c in candidates) {
        if ([c.name isEqualToString:changedNode.name]) {
            return c;
        }
    }
    
    return nil;
}

@end
