//
//  ReporterEvent.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/20/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReporterEvent : NSObject

@property (nonatomic, readonly, strong) NSString *eventName;
@property (nonatomic, readonly, strong) NSDictionary *payload;

+ (instancetype)fromOutputLine:(NSString *)line error:(NSError **)error;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEventName:(NSString *)eventName payload:(NSDictionary *)payload NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
