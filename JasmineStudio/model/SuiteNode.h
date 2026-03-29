//
//  Models.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    SuiteNodeTypeSuite,
    SuiteNodeTypeSpec
} SuiteNodeType;

typedef enum {
    SuiteNodeStatusNotStarted,
    SuiteNodeStatusRunning,
    SuiteNodeStatusPassed,
    SuiteNodeStatusFailed,
    SuiteNodeStatusPending,
    SuiteNodeStatusExcluded
} SuiteNodeStatus;


// Represents a suite or spec, as determined by the type property.
@interface SuiteNode: NSObject

@property (nonatomic, readonly, assign) SuiteNodeType type;
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, weak) SuiteNode * _Nullable parent;
// Children of a suite. If the SuiteNode represents a spec, children should
// be empty, although this is not enforced.
@property (nonatomic, readonly, strong) NSMutableArray<SuiteNode *> *children;

@property (nonatomic, assign) SuiteNodeStatus status;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(SuiteNodeType)type name:(NSString *)name;

- (NSArray<NSString *> *)path;

@end

NS_ASSUME_NONNULL_END
