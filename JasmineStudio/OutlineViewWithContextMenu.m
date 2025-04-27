//
//  OutlineViewWithContextMenu.m
//  JasmineStudio
//
//  Created by Stephen Gravrock on 4/27/25.
//

#import "OutlineViewWithContextMenu.h"

@interface OutlineViewWithContextMenu()
@end

@implementation OutlineViewWithContextMenu

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSPoint originInWindow = [self convertPoint:[event locationInWindow]
                                         toView:nil];
    // TODO: do we need to handle multiple selection?
    NSInteger originRow = [self rowAtPoint:originInWindow];
    
    if (originRow == -1) {
        return nil;
    }
    
    // TODO: draw highlight rectangle around the origin of the menu click
    return [self.menuDelegate menuForOutlineView:self row:originRow];
}

@end
