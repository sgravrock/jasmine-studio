//
//  ReporterTreeBuilder.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import "ReporterTreeBuilder.h"
#import "ReporterEvent.h"
#import "TreeNode.h"

@interface ReporterTreeBuilder()
@property (nonatomic, strong) SuiteOrSpec * _Nullable currentSpec;
@property (nonatomic, strong) NSMutableArray<SuiteOrSpec *> *currentSuites;
@property (nonatomic, strong) TopSuite *topSuite;
@end

@implementation ReporterTreeBuilder

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _currentSuites = [NSMutableArray array];
        _topSuite = [[TopSuite alloc] init];
    }
    
    return self;
}

- (BOOL)handleEvent:(ReporterEvent *)event error:(NSError **)error {
    // Rather than linking nodes to their parents by ID, we assume that the
    // currently running suite is the parent. That's safe because we don't
    // run Jasmine in parallel mode.
    
    NSString * _Nullable name = event.payload[@"description"];

    if ([event.eventName isEqualToString:@"specStarted"]) {
        // TODO validate name
        SuiteOrSpec *node = [[Spec alloc] initWithName:name];
        node.status = SuiteOrSpecStatusRunning;
        
        if (self.currentSuites.count == 0) {
            node.parent = self.topSuite;
        } else {
            node.parent = [self.currentSuites lastObject];
        }
        
        self.currentSpec = node;
        [self.delegate reporterTreeBuilder:self didUpdateNode:node];
    } else if ([event.eventName isEqualToString:@"specDone"]) {
        SuiteOrSpec *node = self.currentSpec;
        self.currentSpec = nil;
        
        node.status = [self statusFromPayload:event.payload error:error];
        if (*error != nil) {
            return NO;
        }
        
        [self.delegate reporterTreeBuilder:self didUpdateNode:node];
    } else if ([event.eventName isEqualToString:@"suiteStarted"]) {
        // TODO validate name
        SuiteOrSpec *node = [[Suite alloc] initWithName:name];
        node.status = SuiteOrSpecStatusRunning;

        if (self.currentSuites.count == 0) {
            node.parent = self.topSuite;
        } else {
            node.parent = [self.currentSuites lastObject];
        }

        [self.currentSuites addObject:node];
        [self.delegate reporterTreeBuilder:self didUpdateNode:node];
    } else if ([event.eventName isEqualToString:@"suiteDone"]) {
        SuiteOrSpec *node = [self.currentSuites lastObject];
        [self.currentSuites removeLastObject];
        
        node.status = [self statusFromPayload:event.payload error:error];
        if (*error != nil) {
            return NO;
        }
        
        [self.delegate reporterTreeBuilder:self didUpdateNode:node];
    }
    
    return YES;
}

- (SuiteOrSpecStatus)statusFromPayload:(NSDictionary *)payload error:(NSError **)error {
    NSString *status = payload[@"status"];
    
    if (status == nil) {
        *error = [[NSError alloc] initWithDomain:@"JasmineStudio" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Missing status field in event payload"}];
        return SuiteOrSpecStatusFailed;
    }
    
    if ([status isEqualToString:@"passed"]) {
        return SuiteOrSpecStatusPassed;
    } else if ([status isEqualToString:@"failed"]) {
        return SuiteOrSpecStatusFailed;
    } else if ([status isEqualToString:@"pending"]) {
        return SuiteOrSpecStatusPending;
    } else if ([status isEqualToString:@"excluded"]) {
        return SuiteOrSpecStatusExcluded;
    } else {
        *error = [[NSError alloc] initWithDomain:@"JasmineStudio" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid status field in event payload"}];
        return SuiteOrSpecStatusFailed;
    }
}

@end
