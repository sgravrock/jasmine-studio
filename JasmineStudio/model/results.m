//
//  results.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 5/8/25.
//

#import "results.h"

@implementation FailedExpectation

- (instancetype)initWithEventData:(NSDictionary *)eventData {
    self = [super init];
    
    if (self) {
        _matcherName = eventData[@"matcherName"];
        _message = eventData[@"message"];
        _stack = eventData[@"stack"];
    }
    
    return self;
}

@end


@implementation Result

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _status = rsRunning;
        _output = @"";
        _failedExpectations = @[];
        _children = [NSMutableArray array];
    }
    
    return self;
}

- (void)addChild:(NodeResult *)child {
    [(NSMutableArray *)_children addObject:child];
    [self.delegate result:self didAddChild:child];
}

- (void)appendOutput:(NSString *)output {
    self.output = [self.output stringByAppendingString:output];
    [self.delegate resultDidUpdate:self];
}

- (void)updateWithEndedEvent:(NSDictionary *)event {
    self.failedExpectations = [self convertFailedExpectations:event[@"failedExpectations"]];
    // TODO: also debug logs.
}

- (NSArray<FailedExpectation *> *)convertFailedExpectations:(NSArray<NSDictionary *> *)eventData {
    NSUInteger n = eventData.count;
    NSMutableArray<FailedExpectation *> *result = [NSMutableArray arrayWithCapacity:n];
    
    for (NSUInteger i = 0; i < n; i++) {
        FailedExpectation *e = [[FailedExpectation alloc] initWithEventData:eventData[i]];
        [result addObject:e];
    }

    return result;
}

@end


@implementation OverallResult

- (instancetype)initWithStartedEvent:(NSDictionary *)event {
    // We don't use anything from the event.
    return [super init];
}

- (void)updateWithEndedEvent:(NSDictionary *)event {
    [super updateWithEndedEvent:event];
    NSString *status = event[@"overallStatus"];
    
    if ([status isEqualToString:@"passed"]) {
        self.status = rsPassed;
    } else if ([status isEqualToString:@"failed"]) {
        self.status = rsFailed;
    } else if ([status isEqualToString:@"incomplete"]) {
        self.status = rsIncomplete;
    } else {
        // TODO: how to handle unexpected status?
    }
    
    [self.delegate resultDidUpdate:self];
}

@end

@implementation NodeResult

- (instancetype)initWithStartedEvent:(NSDictionary *)event {
    return [self initWithName:event[@"description"] id:event[@"id"] parentId:event[@"parentSuiteId"]];
}

- (instancetype)initWithName:(NSString *)name id:(NSString *)nodeId parentId:(NSString *)parentId {
    self = [super init];
    
    if (self) {
        _name = name;
        _nodeId = nodeId;
        _parentSuiteId = parentId;
    }
    
    return self;
}

- (void)updateWithEndedEvent:(NSDictionary *)event {
    [super updateWithEndedEvent:event];
    NSString *status = event[@"status"];
    
    if ([status isEqualToString:@"passed"]) {
        self.status = rsPassed;
    } else if ([status isEqualToString:@"failed"]) {
        self.status = rsFailed;
    } else if ([status isEqualToString:@"excluded"]) {
        self.status = rsExcluded;
    } else if ([status isEqualToString:@"pending"]) {
        self.status = rsPending;
    } else {
        // TODO: how to handle unexpected status?
    }
        
    [self.delegate resultDidUpdate:self];
}

@end
