//
//  config.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/20/25.
//

#import "config.h"

static BOOL hasJasmineExecutable(NSString *baseDir);
static BOOL hasJasmineConfig(NSString *baseDir);


BOOL isValidProjectBaseDir(NSString *baseDir) {
    return baseDir.length > 0 && hasJasmineExecutable(baseDir) && hasJasmineConfig(baseDir);
}

static BOOL hasJasmineExecutable(NSString *baseDir) {
    NSString *jasmineExePath = [baseDir stringByAppendingPathComponent:@"node_modules/.bin/jasmine"];
    
    BOOL ret =[[NSFileManager defaultManager] fileExistsAtPath:jasmineExePath];
    return ret;
}

static BOOL hasJasmineConfig(NSString *baseDir) {
    // TODO: Can we just ask jasmine whether there is a config file?
    NSString *configDir = [baseDir stringByAppendingPathComponent:@"spec/support"];
    NSArray *names = @[@"jasmine.mjs", @"jasmine.js", @"jasmine.json"];

    for (NSString *n in names) {
        NSString *path = [configDir stringByAppendingPathComponent:n];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
    
    return NO;
}


BOOL isValidNodePath(NSString *path) {
    if (path.length == 0) {
        return NO;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isdir;
    BOOL exists = [fm fileExistsAtPath:path isDirectory:&isdir];
    return exists && !isdir && [fm isExecutableFileAtPath:path];
}
