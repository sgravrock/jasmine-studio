//
//  ReporterEvent.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/20/26.
//

#import "ReporterEvent.h"

@implementation ReporterEvent

+ (instancetype)fromOutputLine:(NSString *)line error:(NSError **)error {
    if (![line hasPrefix:@"##jasmineStudio:"]) {
        *error = [[NSError alloc] initWithDomain:@"JasmineStudio"
                                            code:-1
                                        userInfo:@{NSLocalizedDescriptionKey: @"reporter output line lacks expected prefix"}];
        return nil;
    }
    
    line = [line substringFromIndex:16];
    NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:error];
    
    if (!jsonObject) {
        return nil;
    }
    
    if (![jsonObject isKindOfClass:[NSDictionary class]]) {
        *error = [[NSError alloc] initWithDomain:@"JasmineStudio"
                                            code:-1
                                        userInfo:@{NSLocalizedDescriptionKey: @"Expeected event JSON to be a dictionary"}];
        return nil;
    }
    
    NSString *eventName = [jsonObject objectForKey:@"eventName"];
    NSDictionary *payload = [jsonObject objectForKey:@"payload"];
    return [[ReporterEvent alloc] initWithEventName:eventName
                                                         payload:payload];
}

- (instancetype)initWithEventName:(NSString *)eventName payload:(NSDictionary *)payload {
    self = [super init];
    
    if (self) {
        _eventName = eventName;
        _payload = payload;
    }
    
    return self;
}

@end
