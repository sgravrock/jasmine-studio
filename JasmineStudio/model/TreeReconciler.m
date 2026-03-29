//
//  TreeReconciler.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import "TreeReconciler.h"
#import "SuiteOrSpec.h"

@interface TreeReconciler()
@property (nonatomic, strong) NSMutableSet<SuiteOrSpec *> *seen;
@end

@implementation TreeReconciler

- (instancetype)initWithRoots:(NSMutableArray<SuiteOrSpec *> *)roots {
    self = [super init];
    
    if (self) {
        _roots = roots;
        _seen = [NSMutableSet set];
    }
    
    return self;
}

// TODO: Switching to a single tree (i.e. synthetic top suite) instead of an
// array of trees would make this a lot cleaner.

- (void)applyChange:(SuiteOrSpec *)changedNode {
    if (changedNode.parent == nil) {
        [self applyRootChange:changedNode];
        return;
    }
    
    SuiteOrSpec *parent = [self existingNodeMatching:changedNode.parent];
    SuiteOrSpec *match = [self existingNodeMatching:changedNode in:parent.children];
    
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

- (void)applyRootChange:(SuiteOrSpec *)changedNode {
    SuiteOrSpec *match = [self existingNodeMatching:changedNode in:self.roots];
    
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
        for (SuiteOrSpec *n in rootsToRemove) {
            [self.roots removeObjectIdenticalTo:n];
        }
        
        [self.delegate treeReconcilerDidAddOrRemoveRoots:self];
    }
    
    // Scan the remaining roots and remove unseen nodes
    for (SuiteOrSpec *n in self.roots) {
        [self removeUnseenDescendantsOf:n];
    }
    
    
    [self.seen removeAllObjects];
}

- (void)removeUnseenDescendantsOf:(SuiteOrSpec *)ancestor {
    NSArray *childrenToRemove = [self unseenNodesIn:ancestor.children];
    
    if (childrenToRemove.count > 0) {
        for (SuiteOrSpec *n in childrenToRemove) {
            [ancestor.children removeObjectIdenticalTo:n];
        }
        
        [self.delegate treeReconciler:self didUpdateNode:ancestor];
    }
    
    for (SuiteOrSpec *child in ancestor.children) {
        [self removeUnseenDescendantsOf:child];
    }
}

- (NSArray<SuiteOrSpec *> *)unseenNodesIn:(NSArray<SuiteOrSpec *> *)arr {
    NSMutableArray<SuiteOrSpec *> *result = [NSMutableArray array];
    
    for (SuiteOrSpec *n in arr) {
        if (![self.seen containsObject:n]) {
            [result addObject:n];
        }
    }
    
    return result;
}

- (void)updateExistingNode:(SuiteOrSpec *)target from:(SuiteOrSpec *)changedNode {
    target.status = changedNode.status;
    // TODO copy other result properties
    [self.delegate treeReconciler:self didUpdateNode:target];
}

- (SuiteOrSpec * _Nullable)existingNodeMatching:(SuiteOrSpec *)changedNode  {
    NSMutableArray<SuiteOrSpec *> *candidates;
    
    if (changedNode.parent == nil) {
        candidates = self.roots;
    } else {
        candidates = [self existingNodeMatching:changedNode.parent].children;
    }

    return [self existingNodeMatching:changedNode in:candidates];
}

- (SuiteOrSpec * _Nullable)existingNodeMatching:(SuiteOrSpec *)changedNode in:(NSArray<SuiteOrSpec *> *)candidates {
    for (SuiteOrSpec *c in candidates) {
        if ([c.name isEqualToString:changedNode.name]) {
            return c;
        }
    }
    
    return nil;
}

@end
