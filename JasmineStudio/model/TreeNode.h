//
//  Models.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// TODO: Might be better to remove this and use class type instead
typedef enum {
    TreeNodeTypeTopSuite,
    TreeNodeTypeSuite,
    TreeNodeTypeSpec
} TreeNodeType;

typedef enum {
    TopSuiteStatusNotStarted,
    TopSuiteStatusRunning,
    TopSuiteStatusPassed,
    TopSuiteStatusFailed,
    TopSutieStatusIncomplete
} TopSuiteStatus;

typedef enum {
    SuiteOrSpecStatusNotStarted,
    SuiteOrSpecStatusRunning,
    SuiteOrSpecStatusPassed,
    SuiteOrSpecStatusFailed,
    SuiteOrSpecStatusPending,
    SuiteOrSpecStatusExcluded
} SuiteOrSpecStatus;

@class SuiteOrSpec;


@interface TreeNode: NSObject

@property (nonatomic, readonly, assign) TreeNodeType type;
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, weak) TreeNode * _Nullable parent;
// The node's children. If the node represents a spec, children should be empty,
// although this is not enforced.
@property (nonatomic, readonly, strong) NSMutableArray<SuiteOrSpec *> *children;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(TreeNodeType)type name:(NSString *)name NS_DESIGNATED_INITIALIZER;

- (NSArray<NSString *> *)path;
- (void)updateFrom:(TreeNode *)other;

@end


@interface TopSuite: TreeNode

@property (nonatomic, assign) TopSuiteStatus status;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithType:(TreeNodeType)type name:(NSString *)name NS_UNAVAILABLE;

@end


// Represents a suite or spec, as determined by the type property.
@interface SuiteOrSpec: TreeNode

@property (nonatomic, assign) SuiteOrSpecStatus status;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(TreeNodeType)type name:(NSString *)name NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
