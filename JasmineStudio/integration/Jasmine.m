//
//  Jasmine.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/21/25.
//

#import "Jasmine.h"
#import "ExternalCommandRunner.h"
#import "ProjectConfig.h"

@interface Jasmine()
@property (nonatomic, strong) ExternalCommandRunner *cmdRunner;
@end

@implementation Jasmine

- (instancetype)initWithConfig:(ProjectConfig *)config commandRunner:(ExternalCommandRunner *)commandRunner {
    self = [super init];
    
    if (self) {
        _config = config;
        _cmdRunner = commandRunner;
    }
    
    return self;
}

- (void)enumerateWithCallback:(EnumerationCallback)callback {
    [self.cmdRunner run:self.config.nodePath
               withArgs:@[[self jasmineExecutable], @"enumerate"]
                   path:self.config.path
       workingDirectory:self.config.projectBaseDir
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

- (void)runNode:(SuiteNode *)node withCallback:(RunCallback)callback {
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
    [self.cmdRunner run:self.config.nodePath
               withArgs:@[[self jasmineExecutable], arg]
                   path:self.config.path
       workingDirectory:self.config.projectBaseDir
      completionHandler:^(int exitCode, NSData * _Nullable output, NSError * _Nullable error) {
        if (error != nil) {
            callback(NO, nil, error);
        } else {
            NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
            callback(exitCode == 0, outputString, nil);
        }        
    }];
}

- (NSString *)jasmineExecutable {
    return [self.config.projectBaseDir stringByAppendingPathComponent:@"node_modules/.bin/jasmine"];
}

@end
