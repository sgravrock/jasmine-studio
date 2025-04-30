//
//  Jasmine.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import "Jasmine.h"
#import "ExternalCommand.h"

@implementation Jasmine

- (instancetype)initWithBaseDir:(NSString *)baseDir nodePath:(NSString *)nodePath {
    self = [super init];
    
    if (self) {
        _baseDir = baseDir;
        _nodePath = nodePath;
    }
    
    return self;
}

- (void)enumerateWithCallback:(EnumerationCallback)callback {
    [ExternalCommand run:self.nodePath
                withArgs:@[[self jasmineExecutable], @"enumerate"]
             inDirectory:self.baseDir
       completionHandler:^(int exitCode, NSData * _Nullable output, NSError * _Nullable error) {
        if (error != nil) {
            callback(nil, error);
        } else if (exitCode != 0) {
            // TODO: pass this along
            // Probably need to include the output since it can be diagnostic
            // esp. when using too old a jasmine version.
            NSLog(@"oh no: %@", [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding]);
        } else {
            NSArray<SuiteNode *> *roots = suiteNodesFromJson(output, &error);
            callback(roots, error);
        }
    }];
}

- (void)runNode:(SuiteNode *)node {
    // TODO: inject an ExternalCommand. This is getting to the point where tests would be good.
    NSError *error = nil;
    NSData *pathData = [NSJSONSerialization dataWithJSONObject:[node path]
                                                       options:0
                                                         error:&error];
    
    if (!pathData) {
        // TODO report this properly
        NSLog(@"JSON serialization failed: %@", [error localizedDescription]);
        return;
    }
    
    NSString *pathJson = [[NSString alloc] initWithData:pathData
                                               encoding:NSUTF8StringEncoding];
    // No need to escape anything since we're not using a shell
    NSString *arg = [NSString stringWithFormat:@"--filter-path=%@", pathJson];
    [ExternalCommand run:self.nodePath
                withArgs:@[[self jasmineExecutable], arg]
             inDirectory:self.baseDir
       completionHandler:^(int exitCode, NSData * _Nullable output, NSError * _Nullable error) {
        NSLog(@"%d %@", exitCode, error);

        if (output == nil) {
            NSLog(@"No output");
        } else {
            NSLog(@"Output: %@", [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding]);
        }
    }];
}

- (NSString *)jasmineExecutable {
    return [self.baseDir stringByAppendingPathComponent:@"node_modules/.bin/jasmine"];
}

@end
