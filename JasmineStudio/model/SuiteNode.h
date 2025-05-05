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


@interface SuiteNode: NSObject

@property (nonatomic, readonly, assign) SuiteNodeType type;
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, weak) SuiteNode * _Nullable parent;
@property (nonatomic, readonly, strong) NSMutableArray<SuiteNode *> *children;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(SuiteNodeType)type name:(NSString *)name;

- (NSArray<NSString *> *)path;

@end

NSArray<SuiteNode *> *suiteNodesFromJson(NSData *jsonData, NSError **error);

NS_ASSUME_NONNULL_END
