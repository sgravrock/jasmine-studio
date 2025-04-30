//
//  Jasmine.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>
#import "Models.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^EnumerationCallback)(NSArray<SuiteNode *> * _Nullable result, NSError  * _Nullable error);


@interface Jasmine : NSObject

@property (nonatomic, readonly, strong) NSString *baseDir;
@property (nonatomic, readonly, strong) NSString *nodePath;

- (instancetype)initWithBaseDir:(NSString *)baseDir nodePath:(NSString *)nodePath;
- (void)enumerateWithCallback:(EnumerationCallback)callback;
- (void)runNode:(SuiteNode *)node;

@end

NS_ASSUME_NONNULL_END
