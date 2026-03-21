//
//  EnumerationTreeBuilder.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 3/21/26.
//

#import "EnumerationTreeBuilder.h"
#import "SuiteNode.h"

@implementation EnumerationTreeBuilder

- (NSArray<SuiteNode *> *)fromJsonData:(NSData *)data error:(NSError **)error {
    id jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                   options:0
                                                     error:error];
    
    if (!jsonArray) {
        return nil;
    }
        
    if (![jsonArray isKindOfClass:[NSArray class]]) {
        *error = [[NSError alloc] initWithDomain:@"JasmineStudio" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Expeected JSON to be an array"}];
        return nil;
    }
    
    return [self fromJsonArray:jsonArray error:error];
}

- (NSArray<SuiteNode *> *)fromJsonArray:(NSArray *)jsonArray error:(NSError **)error {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:jsonArray.count];
    
    // TODO type check
    for (NSDictionary *jsonObject in jsonArray) {
        SuiteNode *newNode = [self suiteNodeFromJsonObject:jsonObject error:error];
        
        if (!newNode) {
            return nil;
        }
        
        [result addObject:newNode];
    }
    
    return result;

}

- (SuiteNode *)suiteNodeFromJsonObject:(NSDictionary *)jsonObject error:(NSError **)error {
    NSString *type = jsonObject[@"type"];
    NSString *name = jsonObject[@"description"]; // TODO check this
    NSArray<SuiteNode *> *children;
    
    if ([type isEqualToString:@"suite"]) {
        // TODO type/existence check children
        children = [self fromJsonArray:jsonObject[@"children"] error:error];
        
        if (!children) {
            return nil;
        }
        
        SuiteNode *node = [[SuiteNode alloc] initWithType:SuiteNodeTypeSuite name:name];
        [node.children addObjectsFromArray:children];
        
        for (SuiteNode *child in children) {
            child.parent = node;
        }
        
        return node;
    } else if ([type isEqualToString:@"spec"]) {
        return [[SuiteNode alloc] initWithType:SuiteNodeTypeSpec name:name];
    } else {
        // TODO report error
        return nil;
    }
}

@end
