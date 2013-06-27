//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/PreferenceController.h,v 1.8 2004/03/19 20:36:29 enno Exp $
//
//  Created by Enno Brehm on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>




@class AppController;



@interface PreferenceController : NSWindowController {
    NSArray *hotkeys;
    
    NSMutableArray *keywords;
    NSMutableArray *expansions;
    
    AppController *appController;
    
    IBOutlet NSTableView *tableView;
    IBOutlet NSPopUpButton *hotkeyPopup;
    IBOutlet NSPopUpButton *modifierPopup;
}

-(PreferenceController*) initWithAppController: (AppController*) aController;

- (void) loadValues;


- (IBAction) addEntry: (id) sender;
- (IBAction) removeEntry: (id) sender;
- (IBAction) close: (id) sender;
- (IBAction) apply: (id) sender;
- (IBAction) hotkeySelected: (id) sender;
- (IBAction) modifierSelected: (id) sender;
-(void) updateHotkey: (id) sender;
@end
