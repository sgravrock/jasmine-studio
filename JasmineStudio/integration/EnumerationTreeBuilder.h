//
//  EnumerationTreeBuilder.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TopSuite;

// Builds a model tree from the output of Jasmine's enumerate command.
@interface EnumerationTreeBuilder : NSObject

- (TopSuite *)fromJsonData:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
