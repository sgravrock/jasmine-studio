//
//  OutlineViewWithContextMenu.h
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/27/25.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class OutlineViewWithContextMenu;

@protocol OutlineViewContextMenuDelegate
- (NSMenu * _Nullable)menuForOutlineView:(OutlineViewWithContextMenu *)sender
                                     row:(NSInteger)row;
@end

@interface OutlineViewWithContextMenu : NSOutlineView
@property (nonatomic, weak) IBOutlet id<OutlineViewContextMenuDelegate> menuDelegate;
@end

NS_ASSUME_NONNULL_END
