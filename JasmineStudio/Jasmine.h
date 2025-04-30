//
//  Jasmine.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>
#import "Models.h"

NS_ASSUME_NONNULL_BEGIN

@class ExternalCommandRunner;

typedef void (^EnumerationCallback)(NSArray<SuiteNode *> * _Nullable result, NSError  * _Nullable error);
// RunCallback params will be one of three combinations:
// * passed:NO, output:nil, error:non-nil if there was an error starting Jasmine or reading output
// * passed:NO, output:non-nil, error:nil if Jasmine ran but failed
// * passed:YES, output:non-nil, error:nil if the run succeeded
// TODO: richer result than just raw output
typedef void (^RunCallback)(BOOL passed, NSString * _Nullable output, NSError * _Nullable error);


@interface Jasmine : NSObject

@property (nonatomic, readonly, strong) NSString *baseDir;
@property (nonatomic, readonly, strong) NSString *nodePath;

- (instancetype)initWithBaseDir:(NSString *)baseDir
                       nodePath:(NSString *)nodePath
                  commandRunner:(ExternalCommandRunner *)commandRunner;
- (void)enumerateWithCallback:(EnumerationCallback)callback;
- (void)runNode:(SuiteNode *)node withCallback:(RunCallback)callback;

@end

NS_ASSUME_NONNULL_END
