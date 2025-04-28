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

- (NSString *)jasmineExecutable {
    return [self.baseDir stringByAppendingPathComponent:@"node_modules/.bin/jasmine"];
}


@end
