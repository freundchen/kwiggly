//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/AppController.h,v 1.8 2004/03/20 18:50:50 enno Exp $
//
//  Created by Enno Brehm on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Carbon/Carbon.h>

#import "PreferenceController.h"
#import "OverlayWindow.h"

#define DEFAULT_HOTKEY (53)
#define DEFAULT_MODIFIER (cmdKey)

extern const int modifiers[];
#define MAX_MODIFIER_INDEX (2)

@interface AppController : NSResponder {
    PreferenceController* preferenceController;

    IBOutlet NSTextField* searchField;
    IBOutlet OverlayWindow *mainWindow;
    IBOutlet NSPopUpButton *popUp;
    
    NSDictionary *defaultsDict;
}

- (IBAction) showPreferences: (id) sender;
- (IBAction) showAbout: (id) sender;
- (IBAction) executeSearch: (id) sender;

-(int)registerHotkey:(int) keycode withModifier: (int) modifier;

-(NSArray*)hotkeys;

@end
