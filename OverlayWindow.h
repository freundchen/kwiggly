
//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/OverlayWindow.h,v 1.3 2004/03/20 18:50:50 enno Exp $
//
//  Created by Enno Brehm on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface OverlayWindow : NSWindow
{
    
    NSTimer *fadeTimer;
    BOOL fadeQueued;
}

- (NSTimer *)fadeTimer;
- (void)setFadeTimer:(NSTimer *)timer;
- (void)startWindowMoveIn:(id) sender;
- (void)startWindowMoveOut:(id) sender;


@end
