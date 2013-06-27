//
//  NoHitTextField.m
//  Kwiggly
//
//  Created by Enno Brehm on Sat Mar 20 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "NoHitTextField.h"


@implementation NoHitTextField

/* need to override so we can drag the window be clicking into the label as well */
- (BOOL)mouseDownCanMoveWindow {
	return YES;
}

@end
