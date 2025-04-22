//
//  Models.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import "Models.h"

static SuiteNodeList *mapJsonObjects(NSArray *jsonObjects, NSError **error);


@implementation Suite

- (instancetype)initWithName:(NSString *)name
                    children:(SuiteNodeList *)children {
    self = [super init];
    
    if (self) {
        _name = name;
        _children = children;
    }
    
    return self;
}

@end


@implementation Spec

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    
    if (self) {
        _name = name;
        _children = [NSArray array];
    }
    
    return self;
}

@end

SuiteNodeList *suiteNodesFromJson(NSData *jsonData, NSError **error) {
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:0
                                                      error:error];
    
    if (!jsonObject) {
        return nil;
    }
    
    if (![jsonObject isKindOfClass:[NSArray class]]) {
        *error = [[NSError alloc] initWithDomain:@"JasmineStudio" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Expeected JSON to be an array"}];
        return nil;
    }
    
    return mapJsonObjects(jsonObject, error);
}

static SuiteNodeList *mapJsonObjects(NSArray *jsonObjects, NSError **error) {
    NSUInteger n = jsonObjects.count;
    NSMutableArray<id<SuiteNode>> *result = [NSMutableArray arrayWithCapacity:n];
    
    for (NSUInteger i = 0; i < n; i++) {
        if (![jsonObjects[i] isKindOfClass:[NSDictionary class]]) {
            *error = [[NSError alloc] initWithDomain:@"JasmineStudio" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Expeected JSON array element to be a dictionary"}];
            return nil;
        }
        
        // TODO lots more presence/type/error checking
        NSString *description = [jsonObjects[i] valueForKey:@"description"];
        NSString *type = [jsonObjects[i] valueForKey:@"type"];
        id<SuiteNode> node;

        if ([type isEqualToString:@"spec"]) {
            node = [[Spec alloc] initWithName:description];
        } else if ([type isEqualToString:@"suite"]) {
            SuiteNodeList *children = mapJsonObjects([jsonObjects[i] valueForKey:@"children"], error);
            
            if (!children) {
                return nil;
            }
            
            node = [[Suite alloc] initWithName:description children:children];
        }
        
        [result addObject:node];
    }
    
    return result;
}
