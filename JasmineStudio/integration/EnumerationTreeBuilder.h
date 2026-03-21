//
//  EnumerationTreeBuilder.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SuiteNode;

@interface EnumerationTreeBuilder : NSObject

- (NSArray<SuiteNode *> *)fromJsonData:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
