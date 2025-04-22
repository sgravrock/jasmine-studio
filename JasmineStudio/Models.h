//
//  Models.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SuiteNode;
typedef NSArray<id<SuiteNode>> SuiteNodeList;

@protocol SuiteNode <NSObject>
- (NSString *)name;
- (SuiteNodeList *)children;
@end

@interface Suite : NSObject<SuiteNode>
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, strong) SuiteNodeList *children;
- (instancetype)initWithName:(NSString *)name
                    children:(SuiteNodeList *)children;
@end


@interface Spec : NSObject<SuiteNode>
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, strong) SuiteNodeList *children;
- (instancetype)initWithName:(NSString *)description;
@end

SuiteNodeList *suiteNodesFromJson(NSData *jsonData, NSError **error);

NS_ASSUME_NONNULL_END
