//
//  ConfigTests.m
//  ConfigTests
//
//  Created by Stephen Gravrock on 4/18/25.
//

#import <XCTest/XCTest.h>
#import "config.h"

@interface ConfigTests : XCTestCase
@property (nonatomic, strong) NSString *tempDir;
@end

@implementation ConfigTests

- (void)setUp {
    NSString *tmpl =
        [NSTemporaryDirectory() stringByAppendingPathComponent:@"configtests.XXXXXX"];
    NSMutableData *dirnameData = [NSMutableData dataWithLength:strlen([tmpl UTF8String] + 1)];
    strcpy([dirnameData mutableBytes], [tmpl UTF8String]);
    
    if (mkdtemp([dirnameData mutableBytes]) == NULL) {
        XCTFail(@"Failed to create temp dir name");
        return;
    }
    
    self.tempDir = [[NSString alloc] initWithData:dirnameData encoding:NSUTF8StringEncoding];
    
    if (mkdir([self.tempDir UTF8String], 0700) != 0) {
        XCTFail(@"Failed to create temp dir");
    }
}

- (void)tearDown {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.tempDir error:&error];
    XCTAssertNil(error);
}

- (void)testIsValidProjectDir_nil {
    XCTAssertFalse(isValidProjectBaseDir(nil));
}

- (void)testIsValidProjectDir_emptyString {
    XCTAssertFalse(isValidProjectBaseDir(@""));
}

- (void)testIsValidProjectDir_dirWithoutJasmineExecutable {
    XCTAssertFalse(isValidProjectBaseDir(self.tempDir));
}

- (void)testIsValidProjectDir_dirWithoutJasmineConfigFile {
    [self createJasmineExecutableIn:self.tempDir];
    XCTAssertFalse(isValidProjectBaseDir(self.tempDir));
}

- (void)testIsValidProjectDir_valid {
    [self createJasmineConfigIn:self.tempDir];
    [self createJasmineExecutableIn:self.tempDir];
    XCTAssertTrue(isValidProjectBaseDir(self.tempDir));
}

- (void)testIsValidNodePath_notExists {
    XCTAssertFalse(isValidNodePath([self.tempDir stringByAppendingPathComponent:@"bogus"]));
}

- (void)testIsValidNodePath_directory {
    XCTAssertFalse(isValidNodePath(self.tempDir));
}

- (void)testIsValidNodePath_notExecutable {
    NSString *path = [self.tempDir stringByAppendingPathComponent:@"somefile"];
    BOOL ok = [[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data] attributes:nil];
    XCTAssertTrue(ok);
    XCTAssertFalse(isValidNodePath(path));
}

- (void)testIsValidNodePath_valid {
    NSString *path = [self.tempDir stringByAppendingPathComponent:@"somefile"];
    BOOL ok = [[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data] attributes:nil];
    XCTAssertTrue(ok);
    int result = chmod([path UTF8String], 0755);
    XCTAssertEqual(0, result);
    XCTAssertTrue(isValidNodePath(path));
}

- (void)createJasmineExecutableIn:(NSString *)baseDir {
    NSString *nodeBin = [baseDir stringByAppendingPathComponent:@"node_modules/.bin"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:nodeBin withIntermediateDirectories:YES attributes:nil error:&error];
    XCTAssertNil(error);
    
    if (error != nil) {
        return;
    }
    
    NSString *jasmine = [nodeBin stringByAppendingPathComponent:@"jasmine"];
    BOOL ok = [[NSFileManager defaultManager] createFileAtPath:jasmine contents:[NSData data] attributes:nil];
    XCTAssertTrue(ok);
}

- (void)createJasmineConfigIn:(NSString *)baseDir {
    NSString *configDir = [baseDir stringByAppendingPathComponent:@"spec/support"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:configDir withIntermediateDirectories:YES attributes:nil error:&error];
    XCTAssertNil(error);
    
    NSString *jasmine = [configDir stringByAppendingPathComponent:@"jasmine.mjs"];
    BOOL ok = [[NSFileManager defaultManager] createFileAtPath:jasmine contents:[NSData data] attributes:nil];
    XCTAssertTrue(ok);
}

@end
