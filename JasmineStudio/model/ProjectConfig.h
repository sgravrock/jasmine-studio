//
//  ProjectConfig.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 5/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProjectConfig : NSObject

@property (nonatomic, readonly, strong) NSString *path; // the PATH env var
@property (nonatomic, readonly, strong) NSString *nodePath;
@property (nonatomic, readonly, strong) NSString *projectBaseDir;

- (instancetype)initWithPath:(NSString *)path
                    nodePath:(NSString *)nodePath
              projectBaseDir:(NSString *)projectBaseDir;

@end

NS_ASSUME_NONNULL_END
