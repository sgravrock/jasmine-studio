//
//  results.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 5/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Results are mutable. They're constructed in a "not started" state and accumulate more infomation as the corresponding specs/suites execute (or don't).
@class Result;
@class NodeResult;

@protocol ResultDelegate<NSObject>
- (void)result:(Result *)sender didAddChild:(NodeResult *)child;
// TODO: iS this enough, or do we want different delegate methods for different kinds of changes?
- (void)resultDidUpdate:(Result *)sender;
@end

typedef enum {
    rsRunning,
    rsPassed,
    rsFailed,
    rsIncomplete, // for OverallResult only
    rsPending,    // for all except OverallResult
    rsExcluded,   // for specs only
} ResultStatus;


// https://jasmine.github.io/api/5.7/global.html#ExpectationResult
// expected and actual are omitted because they're unreliable and deprecateed. passed is omitted because in this context it's always false.
@interface FailedExpectation: NSObject
@property (nonatomic, readonly, strong) NSString *matcherName;
@property (nonatomic, readonly, strong) NSString *message;
@property (nonatomic, readonly, strong) NSString *stack;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype) initWithEventData:(NSDictionary *)eventData NS_DESIGNATED_INITIALIZER;
@end


// Base class for OverallResult and NodeResult
// This is logically an abstract class: you *can* instantiate it directly,
// but doing so doesn't make much sense.
@interface Result: NSObject

@property (nonatomic, readonly, strong) NSArray<NodeResult *> *children;
@property (nonatomic, assign) ResultStatus status;
@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSArray<FailedExpectation *> *failedExpectations;
@property (nonatomic, weak) id<ResultDelegate> delegate;

- (void)appendOutput:(NSString *)output;
- (void)addChild:(NodeResult *)child;
- (void)updateWithEndedEvent:(NSDictionary *)event;

@end


// https://jasmine.github.io/api/5.7/global.html#JasmineDoneInfo
@interface OverallResult : Result

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStartedEvent:(NSDictionary *)event;

@end


// Result subclass for suites and specs
// https://jasmine.github.io/api/5.7/global.html#SpecResult
// https://jasmine.github.io/api/5.7/global.html#SuiteResult
@interface NodeResult: Result

@property (nonatomic, readonly, strong) NSString *nodeId;
@property (nonatomic, readonly, strong) NSString *parentSuiteId; // may be nil
@property (nonatomic, readonly, strong) NSString *name;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStartedEvent:(NSDictionary *)event;
- (instancetype)initWithName:(NSString *)name id:(NSString *)nodeId parentId:(NSString *)parentId NS_DESIGNATED_INITIALIZER;

@end

// TODO deprecation warnings

NS_ASSUME_NONNULL_END
