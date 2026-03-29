//
//  ReporterTreeBuilder.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import "ReporterTreeBuilder.h"
#import "ReporterEvent.h"
#import "SuiteNode.h"

@interface ReporterTreeBuilder()
@property (nonatomic, strong) SuiteNode * _Nullable currentSpec;
@property (nonatomic, strong) NSMutableArray<SuiteNode *> *currentSuites;
@end

@implementation ReporterTreeBuilder

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _currentSuites = [NSMutableArray array];
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
        SuiteNode *node = [[SuiteNode alloc] initWithType:SuiteNodeTypeSpec
                                                     name:name];
        node.status = SuiteNodeStatusRunning;
        node.parent = [self.currentSuites lastObject];
        self.currentSpec = node;
        [self.delegate reporterTreeBuilder:self didUpdateNode:node];
    } else if ([event.eventName isEqualToString:@"specDone"]) {
        SuiteNode *node = self.currentSpec;
        self.currentSpec = nil;
        
        node.status = [self statusFromPayload:event.payload error:error];
        if (*error != nil) {
            return NO;
        }
        
        [self.delegate reporterTreeBuilder:self didUpdateNode:node];
    } else if ([event.eventName isEqualToString:@"suiteStarted"]) {
        // TODO validate name
        SuiteNode *node = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite
                                                     name:name];
        node.status = SuiteNodeStatusRunning;
        node.parent = [self.currentSuites lastObject];
        [self.currentSuites addObject:node];
        [self.delegate reporterTreeBuilder:self didUpdateNode:node];
    } else if ([event.eventName isEqualToString:@"suiteDone"]) {
        SuiteNode *node = [self.currentSuites lastObject];
        [self.currentSuites removeLastObject];
        
        node.status = [self statusFromPayload:event.payload error:error];
        if (*error != nil) {
            return NO;
        }
        
        [self.delegate reporterTreeBuilder:self didUpdateNode:node];
    }
    
    return YES;
}

- (SuiteNodeStatus)statusFromPayload:(NSDictionary *)payload error:(NSError **)error {
    NSString *status = payload[@"status"];
    
    if (status == nil) {
        *error = [[NSError alloc] initWithDomain:@"JasmineStudio" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Missing status field in event payload"}];
        return SuiteNodeStatusFailed;
    }
    
    if ([status isEqualToString:@"passed"]) {
        return SuiteNodeStatusPassed;
    } else if ([status isEqualToString:@"failed"]) {
        return SuiteNodeStatusFailed;
    } else if ([status isEqualToString:@"pending"]) {
        return SuiteNodeStatusPending;
    } else if ([status isEqualToString:@"excluded"]) {
        return SuiteNodeStatusExcluded;
    } else {
        *error = [[NSError alloc] initWithDomain:@"JasmineStudio" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid status field in event payload"}];
        return SuiteNodeStatusFailed;
    }
}

@end
