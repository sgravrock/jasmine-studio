//
//  Models.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import "Models.h"

static NSArray<SuiteNode *> *suiteNodesFromJsonArray(NSArray *jsonArray, NSError **error);
static SuiteNode *suiteNodeFromJsonObject(NSDictionary *jsonObject, NSError **error);

@implementation SuiteNode

- (instancetype)initWithType:(SuiteNodeType)type name:(NSString *)name {
    self = [super init];
    
    if (self) {
        _type = type;
        _name = name;
        _children = [NSMutableArray array];
    }
    
    return self;
}

- (NSArray<NSString *> *)path {
    if (!self.parent) {
        return @[self.name];
    }
    
    return [[self.parent path] arrayByAddingObject:self.name];    
}

@end


NSArray<SuiteNode *> *suiteNodesFromJson(NSData *jsonData, NSError **error) {
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
    
    return suiteNodesFromJsonArray(jsonObject, error);
}

static NSArray<SuiteNode *> *suiteNodesFromJsonArray(NSArray *jsonArray, NSError **error) {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:jsonArray.count];
    
    // TODO type check
    for (NSDictionary *jsonObject in jsonArray) {
        SuiteNode *newNode = suiteNodeFromJsonObject(jsonObject, error);
        
        if (!newNode) {
            return nil;
        }
        
        [result addObject:newNode];
    }
    
    return result;
}

static SuiteNode *suiteNodeFromJsonObject(NSDictionary *jsonObject, NSError **error) {
    NSString *type = jsonObject[@"type"];
    NSString *name = jsonObject[@"description"]; // TODO check this
    NSArray<SuiteNode *> *children;
    
    if ([type isEqualToString:@"suite"]) {
        // TODO type/existence check children
        children = suiteNodesFromJsonArray(jsonObject[@"children"], error);
        
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
