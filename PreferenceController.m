//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/PreferenceController.m,v 1.12 2004/03/26 15:57:38 enno Exp $
//
//  Created by Enno Brehm on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

#import "AppController.h"
#import "commons.h"


static NSString* KeywordColumnID = @"keyword";
static NSString* URLColumnID     = @"url";
static NSString* ActiveColumnID     = @"activeColumn";


@implementation PreferenceController

- (id) initWithAppController: (AppController*) aController {
    self =  [super initWithWindowNibName: @"Preferences"];
    if( self != nil ) {
        appController = [aController retain];
        hotkeys = [[aController hotkeys] retain];
    }
    return self;
}


- (void) dealloc {
    [expansions release];
    [keywords release];
    [hotkeys release];
    [appController release];
    [super dealloc];
}


- (void) windowDidLoad {
    NSLog(@"Nib loaded %@", [self window]);
    [tableView setFont:[NSFont systemFontOfSize: 9]];
    
    int keycode = [[NSUserDefaults standardUserDefaults] integerForKey:HotKeyCodeKey];
    if( keycode == 0 ) {
        keycode = DEFAULT_HOTKEY;
    }
    
    int modIndex = [[NSUserDefaults standardUserDefaults] integerForKey:ModifierIndexKey];
    if( modIndex < 0 || modIndex > MAX_MODIFIER_INDEX) {
        modIndex = 0;
    }
    [modifierPopup selectItemAtIndex: modIndex];
    
    
    /* populate hotkey box */
    [hotkeyPopup removeAllItems];
    int i;
    int itemToSelect = -1;
    for(i=0; i<[hotkeys count]; i++) {
        NSDictionary* hk = [hotkeys objectAtIndex: i];
        [hotkeyPopup addItemWithTitle: [hk objectForKey:NameKey]];
        if( keycode == [[hk objectForKey:KeyCodeKey] intValue] ) {
            itemToSelect = i;
        }
    }
    [hotkeyPopup selectItemAtIndex: itemToSelect];
    
//    NSButtonCell *bCell = [[NSButtonCell alloc] init];
//    [bCell setButtonType: NSSwitchButton];
//    [bCell setImagePosition: NSImageOnly];
//    [enableColumn setDataCell: bCell];
//    [bCell release];
}


- (void) windowWillClose: (id) aNot {
	if([NSColorPanel sharedColorPanelExists]) {
		NSColorPanel *scp = [NSColorPanel sharedColorPanel];
		[scp close];
	}
    /* just to end editing */
    [[self window] makeFirstResponder: tableView];
    [self apply: self];
    [NSApp hide: self];
}


- (void) loadValues {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey: KeywordMapKey];
    keywords = [[NSMutableArray alloc] initWithArray:[dict allKeys]];
    expansions = [[NSMutableArray array] retain];
    

    int n = [keywords count];
    int i;
    for(i=0; i<n; i++) {
        NSString *key = [keywords objectAtIndex:i];
        NSString *exp = [dict objectForKey: key];
        [expansions addObject:exp];
        //NSLog(@"mapping %@ ===> %@", key, exp);
    }
}


-(void) updateHotkey: (id) sender {
    int hkIndex = [hotkeyPopup indexOfSelectedItem];
    int modIndex = [modifierPopup indexOfSelectedItem];
    
    if( hkIndex == -1 || modIndex == -1 || modIndex > 2) {
        NSBeep();
        NSLog(@"no valid hotkey selected");
        return;
    }
    
    int keycode = [[[hotkeys objectAtIndex:hkIndex] objectForKey:KeyCodeKey] intValue];
    int modifier = modifiers[modIndex];
    
    [appController registerHotkey:keycode withModifier: modifier];
    [[NSUserDefaults standardUserDefaults] setInteger:keycode forKey:HotKeyCodeKey];
    [[NSUserDefaults standardUserDefaults] setInteger:modIndex forKey:ModifierIndexKey];
}


- (IBAction) hotkeySelected: (id) sender {
    int modifier = DEFAULT_MODIFIER;
    int index = [hotkeyPopup indexOfSelectedItem];
    NSLog(@"hotkey changed %d", index);
    NSDictionary *dict = [hotkeys objectAtIndex:index];
    int keycode = [[dict objectForKey:KeyCodeKey] intValue];
    [appController registerHotkey:keycode withModifier: modifier];
    [[NSUserDefaults standardUserDefaults] setInteger:keycode forKey:HotKeyCodeKey];
}

- (IBAction) modifierSelected: (id) sender {
    int modifier = DEFAULT_MODIFIER;
    int index = [hotkeyPopup indexOfSelectedItem];
    NSLog(@"hotkey changed %d", index);
    NSDictionary *dict = [hotkeys objectAtIndex:index];
    int keycode = [[dict objectForKey:KeyCodeKey] intValue];
    [appController registerHotkey:keycode withModifier: modifier];
    [[NSUserDefaults standardUserDefaults] setInteger:keycode forKey:HotKeyCodeKey];
}


- (IBAction) addEntry: (id) sender {
    int n = [keywords count];
    [keywords addObject: [NSString stringWithString: KeywordColumnID]];
    [expansions addObject: [NSString stringWithString: @"http://www.somewhere.com?q=%@"]];
    [tableView reloadData];
    [tableView selectRow: n byExtendingSelection: NO];
    [tableView editColumn:0 row: n withEvent: nil select:YES];
}


- (IBAction) removeEntry: (id) sender {
    int selected = [tableView selectedRow];
    if( selected == -1 ) {
        NSBeep();
        return;
    }
    NSString* keyword = [keywords objectAtIndex:selected];
    NSString* expansion = [expansions objectAtIndex:selected];
    
    NSString *msgformat = NSLocalizedString(@"ConfirmDelete", nil); //[[NSBundle mainBundle] localizedStringForKey:@"ConfirmDelete" value:nil table:nil];
    NSString *delete = NSLocalizedString(@"Delete", nil); //[[NSBundle mainBundle] localizedStringForKey:@"Delete" value:nil table:nil];
    NSString *cancel = NSLocalizedString(@"Cancel", nil); //[[NSBundle mainBundle] localizedStringForKey:@"ConfirmDelete" value:nil table:nil];
    NSString *boundTo = NSLocalizedString(@"BoundTo", nil);
    NSString *msg = [NSString stringWithFormat: msgformat, keyword];
    NSAlert *alert = [NSAlert alertWithMessageText:msg defaultButton:delete 
                                   alternateButton:cancel otherButton:nil
                         informativeTextWithFormat:boundTo, keyword, expansion ];
    
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returned:context:) contextInfo:nil];
    
    //[keywords removeObjectAtIndex:selected];
    //[expansions removeObjectAtIndex:selected];
    //[tableView reloadData];
}


- (void) sheetDidEnd:(NSWindow*) sheet returned:(int) returnCode context: (void*) contextInfo {
    int selected = [tableView selectedRow];
    if( returnCode == 1 && selected != -1 ) {
        NSString* keyword = [keywords objectAtIndex:selected];
        NSString* expansion = [expansions objectAtIndex:selected];
        NSLog(@"remove: %@ -> %@", keyword, expansion);
        [keywords removeObjectAtIndex:selected];
        [expansions removeObjectAtIndex:selected];
        [tableView reloadData];
        
    }
}


- (BOOL) enableRemove {
    NSLog(@"enable remove");
    return [tableView selectedRow] != -1;
}

- (IBAction) apply: (id) sender {
    [tableView validateEditing];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects: expansions forKeys: keywords];
    //NSLog(@"%@", dict);

    [defaults setObject: dict forKey: KeywordMapKey];
    if( [defaults synchronize] == NO ) {
        NSLog(@"could not save user defaults");
        NSBeep();
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName: DefaultsChangedNotificationName object:nil];
}


- (IBAction) close: (id) sender {
    [[self window] close];
}



/* table datasource stuff */

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [keywords count];
}


- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    NSString *ident = [aTableColumn identifier];
    
    if( [ident isEqualToString: KeywordColumnID] ) {
        [keywords replaceObjectAtIndex:rowIndex withObject:anObject];
    } else if( [ident isEqualToString: URLColumnID] ) {
        [expansions replaceObjectAtIndex:rowIndex withObject:anObject];
    //} else if( [ident isEqualToString: ActiveColumnID] ) {
        //return [NSNumber numberWithInt:0];
    } else {
        NSLog(@"unknown col index %@", ident);
    }
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    NSString *ident = [aTableColumn identifier];

    if( [ident isEqualToString: KeywordColumnID] ) {
            return [keywords objectAtIndex: rowIndex];
    } else if( [ident isEqualToString: URLColumnID] ) {
        return [expansions objectAtIndex: rowIndex];
    //} else if( [ident isEqualToString: ActiveColumnID] ) {
    //    return [NSNumber numberWithInt:0];
    } else {
        NSLog(@"unknown col index %@", ident);
        return nil;
    }
}


//- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell
//   forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
//    static NSColor* oddColor = nil;
//    if( ! oddColor ) {
//        oddColor = [[NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.99 alpha:1.0] retain];
//    }
//    [aCell setDrawsBackground: YES];
//    if ( rowIndex % 2 ) {
//        [aCell setBackgroundColor: oddColor];
//    } else {
//        [aCell setBackgroundColor: [NSColor whiteColor]];
//    }
//}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    [self willChangeValueForKey:@"enableRemove"];
    [self didChangeValueForKey:@"enableRemove"];
}



@end


