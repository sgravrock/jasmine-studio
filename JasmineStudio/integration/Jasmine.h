//
//  Jasmine.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import <Foundation/Foundation.h>
#import "SuiteNode.h"
#import "StreamingExecution.h"

NS_ASSUME_NONNULL_BEGIN

@class ProjectConfig;
@class ExternalCommandRunner;
@class Jasmine;


// TODO: fold into delegate?
typedef void (^EnumerationCallback)(NSArray<SuiteNode *> * _Nullable result, NSError  * _Nullable error);

@protocol JasmineDelegate
- (void)jasmine:(Jasmine *)sender runFailedWithError:(NSError *)error;
// TODO: richer output than just raw text
- (void)jasmine:(Jasmine *)sender runDidOutputLine:(NSString *)line;
- (void)jasmine:(Jasmine *)sender runFinishedWithExitCode:(int)exitCode;
@end


@interface Jasmine : NSObject<StreamingExecutionDelegate>

@property (nonatomic, readonly, strong) ProjectConfig *config;
@property (nonatomic, weak) id<JasmineDelegate> delegate;

- (instancetype)initWithConfig:(ProjectConfig *)config
                 commandRunner:(ExternalCommandRunner *)commandRunner;
- (void)enumerateWithCallback:(EnumerationCallback)callback;
- (void)runNode:(SuiteNode *)node;

@end

NS_ASSUME_NONNULL_END
