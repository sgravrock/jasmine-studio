//
//  ProjectConfig.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 5/3/25.
//

#import "ProjectConfig.h"

@implementation ProjectConfig

- (instancetype)initWithPath:(NSString *)path
                    nodePath:(NSString *)nodePath
              projectBaseDir:(NSString *)projectBaseDir {
    self = [super init];
    
    if (self) {
        _path = path;
        _nodePath = nodePath;
        _projectBaseDir = projectBaseDir;
    }
    
    return self;
}

@end
