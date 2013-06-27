//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/KwigglyApp.m,v 1.3 2004/03/19 20:36:29 enno Exp $
//  Kwiggly
//
//  Created by Enno Brehm on Wed Feb 25 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "KwigglyApp.h"


enum {
    // NSEvent subtypes for hotkey events (undocumented).
    kEventHotKeyPressedSubtype = 6,
    kEventHotKeyReleasedSubtype = 9,
};


@implementation KwigglyApp
 
- (void)sendEvent:(NSEvent *)theEvent
{
    if ([theEvent type] == NSSystemDefined && [theEvent subtype] ==kEventHotKeyPressedSubtype)
    {
        //NSLog(@"hotkey pressed");
        /* delegate to appcontroller via standard delegation */
        [NSApp tryToPerform: @selector(doShow:) with:nil];
    }
    
    [super sendEvent:theEvent]; // YOU MUST CALL THIS OR YOU WILL EAT EVENTS!
}
@end
