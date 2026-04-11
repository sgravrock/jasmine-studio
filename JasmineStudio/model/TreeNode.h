//
//  Models.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, weak) TreeNode * _Nullable parent;
// The node's children. If the node represents a spec, children should be empty,
// although this is not enforced.
@property (nonatomic, readonly, strong) NSMutableArray<SuiteOrSpec *> *children;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

- (NSArray<NSString *> *)path;
- (void)updateFrom:(TreeNode *)other;

@end


@interface TopSuite: TreeNode

@property (nonatomic, assign) TopSuiteStatus status;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithName:(NSString *)name NS_UNAVAILABLE;

@end


// A node that is not the top suite.
@interface SuiteOrSpec: TreeNode

@property (nonatomic, assign) SuiteOrSpecStatus status;

@end


@interface Suite: SuiteOrSpec
@end


@interface Spec: SuiteOrSpec
@end

NS_ASSUME_NONNULL_END
