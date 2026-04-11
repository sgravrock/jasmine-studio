//
//  TreeReconciler.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import "TreeReconciler.h"
#import "TreeNode.h"

@interface TreeReconciler()
@property (nonatomic, strong) NSMutableSet<TreeNode *> *seen;
@end

@implementation TreeReconciler

- (instancetype)initWithRoot:(TopSuite *)root {
    self = [super init];
    
    if (self) {
        _root = root;
        _seen = [NSMutableSet set];
    }
    
    return self;
}

- (void)applyChange:(TreeNode *)changedNode {
    TreeNode *match, *parentMatch;
    
    if ([changedNode isKindOfClass:[TopSuite class]]) {
        match = self.root;
        parentMatch = nil;
    } else {
        parentMatch = [self existingNodeMatching:changedNode.parent];
        
        if (parentMatch == nil) {
            // Can't happen
            NSLog(@"Could not find match for parent node: %@", [changedNode.parent path]);
            return;
        }
        
        match = [self existingNodeMatching:(SuiteOrSpec *)changedNode in:parentMatch.children];
    }
        
    if (match == nil) {
        // A newly discovered node
        [self.seen addObject:changedNode];
        [parentMatch.children addObject:(SuiteOrSpec *)changedNode];
        [self.delegate treeReconciler:self didUpdateNode:parentMatch];
    } else {
        [self.seen addObject:match];
        [match updateFrom:changedNode];
        [self.delegate treeReconciler:self didUpdateNode:match];
    }
}

- (void)jasmineDone {
    [self removeUnseenDescendantsOf:self.root];
    [self.seen removeAllObjects];
}

- (void)removeUnseenDescendantsOf:(TreeNode *)ancestor {
    NSArray *childrenToRemove = [self unseenChildrenOf:ancestor];
    
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

- (NSArray<SuiteOrSpec *> *)unseenChildrenOf:(TreeNode *)parent; {
    NSMutableArray<SuiteOrSpec *> *result = [NSMutableArray array];
    
    for (SuiteOrSpec *n in parent.children) {
        if (![self.seen containsObject:n]) {
            [result addObject:n];
        }
    }
    
    return result;
}

- (TreeNode *)existingNodeMatching:(TreeNode *)changedNode  {
    if (changedNode == nil) {
        // Shouldn't happen, but avoid infinite recursion if it does
        return nil;
    }
    
    if ([changedNode isKindOfClass:[TopSuite class]]) {
        return self.root;
    }
    
    // TODO: infinite recursion here?
    NSMutableArray<SuiteOrSpec *> *candidates = [self existingNodeMatching:changedNode.parent].children;
    return [self existingNodeMatching:(SuiteOrSpec *)changedNode in:candidates];
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
