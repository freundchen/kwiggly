//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/OverlayWindow.m,v 1.4 2004/03/20 18:50:50 enno Exp $
//
//  Created by Enno Brehm on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//


#import "OverlayWindow.h"


#define ALPHA_INCREMENT 0.05
#define ALPHA_LOW 0.4
#define ALPHA_HIGH 0.9
#define X_STEP 100.0

// Some of these objects are globals because it makes it much easier to get to them
// from the hotkey handler (not a method of OverlayWindow) in a little sample like this,
// instead of making accessors for everything.

NSTimer *moveTimer1;
int moveCount;
short xDelta,yDelta;

 
@implementation OverlayWindow

// We override this initializer so we can set the NSBorderlessWindowMask styleMask, and set a few other important settings
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    NSWindow* win=[super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
    [win setOpaque:NO]; // Needed so we can see through it when we have clear stuff on top
    [win setHasShadow: YES];
    [win setLevel:NSFloatingWindowLevel]; // Let's make it sit on top of everything else
    [win setAlphaValue:ALPHA_HIGH]; 
    [win center];
    return win;
}


- (void)awakeFromNib
{
    BOOL isInside=(NSPointInRect([NSEvent mouseLocation],[self frame]));
    [[self contentView] addTrackingRect:[[self contentView] bounds] owner:self userData:nil assumeInside:isInside];

    [self setBackgroundColor: [NSColor grayColor]];
    [self setMovableByWindowBackground: YES];
    [self setReleasedWhenClosed: NO];
}

// Windows created with NSBorderlessWindowMask normally can't be key, but we want ours to be
- (BOOL) canBecomeKeyWindow
{
    return YES;
}


-(void)dealloc
{
    [self setFadeTimer:nil];
    [super dealloc];
}

static NSRect originalFrame;

// This routine is called repeatedly when the mouse exits one of the two windows from inside them.
// -mouseExited: sets up the timer that starts calling this method.
- (void)moveWinLeft:(NSTimer *)timer
{
	NSRect frame = [self frame];
	
    if ( [self screen] ) 
    {
		frame = NSOffsetRect(frame, -X_STEP, 0);
		[self setFrame: frame display: YES];
    }
	else
    {
		NSLog(@"move out complete");
        [self setFadeTimer:nil];
		[NSApp hide: self];
    }
}

// This routine is called repeatedly when the mouse exits one of the two windows from inside them.
// -mouseExited: sets up the timer that starts calling this method.
- (void)moveWinRight:(NSTimer *)timer
{
	NSRect frame = [self frame];
	
	int x = NSMinX([self frame]);
	
    if ( x + X_STEP < NSMinX(originalFrame) ) 
    {
		frame = NSOffsetRect(frame, X_STEP, 0);
		[self setFrame: frame display: YES];
    }
	else
    {
		NSLog(@"move in complete");

        [self setFadeTimer:nil];
		[self setFrame:originalFrame display:YES];
    }
}



// If the mouse enters a window, go make sure we fade in
- (void)startWindowMoveOut:(id) sender
{
	if( ! [self screen] ) {
		return;
	}
	
	originalFrame = [self frame];
	NSLog(@"move out req, remembering frame %@", NSStringFromRect(originalFrame));

    [self setFadeTimer:[NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
													  selector:@selector(moveWinLeft:) 
													  userInfo:nil repeats:YES]];
}
 
 // If the mouse exits a window, go make sure we fade out
- (void)startWindowMoveIn:(id) sender
{
	NSRect frame = [self frame];
	NSLog(@"move in from %@ to %@", NSStringFromRect(frame), NSStringFromRect(originalFrame) );
	if( NSMinX(frame) >= NSMinX(originalFrame) ) {
		NSLog(@"not necessary");
		return;
	}
	
    [self setFadeTimer:[NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
													  selector:@selector(moveWinRight:) 
													  userInfo:nil repeats:YES]];
 }

// 
// A getter and setter for our main timer that handles window fading

- (NSTimer *)fadeTimer
{
    return fadeTimer;
}

- (void)setFadeTimer:(NSTimer *)timer
{
    [timer retain];
    [fadeTimer invalidate];
    [fadeTimer release];
    fadeTimer=timer;
}


@end
