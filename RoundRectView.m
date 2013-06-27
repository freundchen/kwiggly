//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/RoundRectView.m,v 1.6 2004/03/20 18:50:50 enno Exp $
//
//  Created by Enno Brehm on Thu Jul 24 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "RoundRectView.h"


@implementation RoundRectView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


/* the following op is replace by cancelOperation: in AppController. (since Panther) */
//- (BOOL)performKeyEquivalent:(NSEvent *)event {
//    if( [event type] == NSKeyDown ) {
//        NSString *cs = [event characters];
//        if( [cs length] > 0) {
//            unichar c = [cs characterAtIndex: 0];
//            if( c == '\033' ) {
//                [NSApp tryToPerform: @selector(doHide:) with:nil];
//                return YES;
//            }
//        }
//        
//    }
//    return [super performKeyEquivalent: event];
//}



- (void)drawRect:(NSRect)rect
{
    NSRect dim = [self bounds];
    float x = dim.origin.x;
    float y = dim.origin.y;
    float w = dim.size.width;
    float h = dim.size.height;
    float radius = dim.size.height / 2;
    
    [[NSColor clearColor] set];
    NSRectFill([self frame]);

    //NSLog(@"%@ %f %f %f %f", @"display ", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //NSLog(@"%@ %f %f %f %f", @"bounds ", x, y, w, h);

    [[NSColor blackColor] set];


    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: NSMakePoint(x, y + radius)];
    [path appendBezierPathWithArcWithCenter: NSMakePoint(x + radius, y + h - radius)
                                     radius: radius startAngle: 180 endAngle: 90 clockwise: YES];
    [path appendBezierPathWithArcWithCenter: NSMakePoint(x + w - radius, y + h - radius)
                                     radius: radius startAngle: 90 endAngle: 0 clockwise: YES];
    [path appendBezierPathWithArcWithCenter: NSMakePoint(x + w - radius, y + radius)
                                     radius: radius startAngle: 0 endAngle: 270 clockwise: YES];
    [path appendBezierPathWithArcWithCenter: NSMakePoint(x + radius, y + radius)
                                     radius: radius startAngle: 270 endAngle: 180 clockwise: YES];
    [path fill];

    [super drawRect: rect];
}


@end
