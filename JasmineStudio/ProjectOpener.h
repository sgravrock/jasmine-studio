//
//  ProjectOpener.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/19/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProjectOpener: NSObject

+ (void)promptAndOpenThen:(void (^)(NSWindow *))onSuccess onCancel:(void (^)(void))onCancel;
+ (NSWindow *)openProjectWithBaseDir:(NSString *)baseDir error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
