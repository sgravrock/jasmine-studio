//
//  ReporterTreeBuilder.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SuiteNode;
@class ReporterEvent;
@class ReporterTreeBuilder;

@protocol ReporterTreeBuilderDelegate

// TODO: a callback on handleEvent:error: might work better.
- (void)reporterTreeBuilder:(ReporterTreeBuilder *)sender didUpdateNode:(SuiteNode *)node;

@end

// Builds a model tree from reporter events.
// A single SuiteNode instance will be created for each suite and spec and
// reused across relevant reporter events.
// A new ReporterTreeBuilder instance should be created for each Jasmine run.
@interface ReporterTreeBuilder : NSObject

@property (nonatomic, weak) id<ReporterTreeBuilderDelegate> delegate;

- (BOOL)handleEvent:(ReporterEvent *)event error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
