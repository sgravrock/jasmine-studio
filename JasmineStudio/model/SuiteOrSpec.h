//
//  Models.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    SuiteOrSpecTypeSuite,
    SuiteOrSpecTypeSpec
} SuiteOrSpecType;

typedef enum {
    SuiteOrSpecStatusNotStarted,
    SuiteOrSpecStatusRunning,
    SuiteOrSpecStatusPassed,
    SuiteOrSpecStatusFailed,
    SuiteOrSpecStatusPending,
    SuiteOrSpecStatusExcluded
} SuiteOrSpecStatus;


// Represents a suite or spec, as determined by the type property.
@interface SuiteOrSpec: NSObject

@property (nonatomic, readonly, assign) SuiteOrSpecType type;
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, weak) SuiteOrSpec * _Nullable parent;
// Children of a suite. If the object represents a spec, children should
// be empty, although this is not enforced.
@property (nonatomic, readonly, strong) NSMutableArray<SuiteOrSpec *> *children;

@property (nonatomic, assign) SuiteOrSpecStatus status;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(SuiteOrSpecType)type name:(NSString *)name;

- (NSArray<NSString *> *)path;

@end

NS_ASSUME_NONNULL_END
