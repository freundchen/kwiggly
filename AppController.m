//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/AppController.m,v 1.22 2004/03/26 15:57:38 enno Exp $
//
//  Created by Enno Brehm on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>

#import "AppController.h"
#import "Resolver.h"
#import "Commons.h"

@interface AppController (private)
-(void) colorFirstWord:(NSMutableAttributedString*) storage fromString:(NSString*) string;
- (void) colorFirstWord: (NSText*) text;
@end


const UInt32 kMyHotKeyIdentifier= 'kwig'; //'golw';
                             //53: escape
                             //10: degree/roof
                             //const UInt32 kMyHotKey = 10; //the degree/roof key

static EventHotKeyRef gMyHotKeyRef = 0; /* a reference to the stored hotkey. needed for unregistration */
static AppController* theInstance; /* singleton */

static NSCharacterSet *whitespace = nil;// = [NSCharacterSet whitespaceCharacterSet]; 
static NSCharacterSet *nonWhitespace = nil;// = [whitespace invertedSet]; 

static NSWindow* theKeyWin;

const int modifiers[] = { cmdKey, optionKey, controlKey }; 
static NSColor *keywordColor = nil;

int getIntDefault(NSString* key, int defValue) {
    int v = [[NSUserDefaults standardUserDefaults] integerForKey: key];
    return (v!=0 ? v : defValue);
}

@implementation AppController

-(int)registerHotkey:(int) keycode withModifier: (int) modifier {
    
    EventHotKeyID gMyHotKeyID;
    
    if( gMyHotKeyRef != 0 ) {
        UnregisterEventHotKey(gMyHotKeyRef);
        gMyHotKeyRef = 0;
    }
    
    gMyHotKeyID.signature=kMyHotKeyIdentifier;
    gMyHotKeyID.id=1;
    
    int regErr = RegisterEventHotKey(keycode, modifier, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);
    NSLog(@"Register hotkey code %d %d. (%d)", keycode, modifier, regErr);

    return regErr;
}


-(void) registerDefaults {
	NSMutableDictionary *defs = [NSMutableDictionary dictionary];
	NSColor *col = [NSColor colorWithCalibratedRed:0 green:0.5 blue:0 alpha:1];
	NSData *data = [NSArchiver archivedDataWithRootObject:col];
	[defs setObject:data forKey:KeywordColorKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults: defs];
}


- (void) awakeFromNib {
    theInstance = self;

    [self registerDefaults];
    
    int keycode = getIntDefault(HotKeyCodeKey, DEFAULT_HOTKEY);
    int modIndex = [[NSUserDefaults standardUserDefaults] integerForKey: ModifierIndexKey];
    if( modIndex < 0 || modIndex > MAX_MODIFIER_INDEX ) {
        modIndex = 0;
    }

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(defaultsChanged:) 
												 name: NSUserDefaultsDidChangeNotification  
											   object: nil];
	
	
    [self registerHotkey: keycode withModifier: modifiers[modIndex]];
	whitespace = [[NSCharacterSet whitespaceCharacterSet] retain]; 
	nonWhitespace = [[whitespace invertedSet] retain]; 
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:KeywordColorKey];
	keywordColor = [[NSUnarchiver unarchiveObjectWithData:data] retain];
		
    NSString *fpath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    defaultsDict = [[NSDictionary dictionaryWithContentsOfFile:fpath] retain];
    if( (GetCurrentKeyModifiers() & cmdKey) > 0 ) {
        NSLog(@"command pressed during launch: show prefs");
        [self showPreferences:self];
        [NSApp activateIgnoringOtherApps: YES];
    }

}


- (void) doShow: (id) sender {
	int windows[150];
	int n;
	int i = 0;
	NSCountWindows(&n);
	NSLog(@"%d windows", n);
	if( n > 150 ) n = 150;

	NSWindowList(n, windows);
	NSWindow *keyWin = nil; 
	for(;i<n;i++) {
		keyWin = [NSApp windowWithWindowNumber:windows[i]];
		NSLog(@"%d:%d %@", i, windows[i], keyWin);
		if( keyWin==nil ) continue;
		if([keyWin isKeyWindow]) {
			break;
		}
	}
	NSLog(@"keywin %@", keyWin);
	if( i < n && keyWin != nil && keyWin != mainWindow) {
		NSLog(@"setting key win to %@", keyWin);
		theKeyWin = keyWin;
	}
	
    [NSApp activateIgnoringOtherApps: YES];
	[mainWindow makeKeyAndOrderFront: self];
	
	//[[searchField cell] ]
	//[mainWindow startWindowMoveIn: self];
}


- (void) doHide: (id) sender {
	//[mainWindow startWindowMoveOut: self];
	//[NSApp hide:self];
    [mainWindow orderOut:self];
	//[mainWindow close];
}


-(void)dealloc
{
    [preferenceController release];
    [defaultsDict release];
	//[searchDict release];
    [super dealloc];
}


-(IBAction) showPreferences: (id) sender {
    if (!preferenceController) {
        preferenceController = [[PreferenceController alloc] initWithAppController: self];
    }
    //NSLog(@"will show");
    [preferenceController loadValues];
    [preferenceController showWindow: self];
    [mainWindow close];
}

-(BOOL) validateMenuItem: (id <NSMenuItem>) menuItem {
    NSLog(@"validate %@ %d", [menuItem title], [menuItem tag]);
    NSWindow* panel = [preferenceController window];
    
    return !([panel isVisible]);
}

- (void)cancelOperation:(id)sender {
    [self doHide: self];
	[theKeyWin makeKeyWindow];
	theKeyWin = nil;
}

- (IBAction) executeSearch: (id) sender {
    //NSLog(@"execute");
    NSCharacterSet *trimWSSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *fullSearchString = [(NSString*)[sender objectValue] stringByTrimmingCharactersInSet: trimWSSet];
    [self doHide: self];
    
    if ([fullSearchString length] > 0) 
        [[Resolver sharedInstance] resolve:fullSearchString]; 
}


- (void) showAbout: (id) sender {
    //NSDictionary *dict = [NSDictionary dictionaryWithObject: @"$Revision: 1.22 $" forKey: @"Version"];
    [NSApp orderFrontStandardAboutPanel:self];
    [mainWindow close];
}


- (void)windowDidBecomeKey:(NSNotification *)aNotification {
    [[aNotification object] makeFirstResponder: searchField];
	[self colorFirstWord: [searchField currentEditor]];

}

- (void)applicationWillResignActive:(NSNotification *)aNotification {
    [self doHide: self];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    [mainWindow makeKeyAndOrderFront: self];
}

- (NSArray*)hotkeys {
    return [defaultsDict objectForKey:@"hotkeys"];
}

-(void) colorFirstWord:(NSMutableAttributedString*) storage fromString:(NSString*) string {
	NSRange nonspace = [string rangeOfCharacterFromSet:nonWhitespace];
	int r = [string length] - nonspace.location;
	
	if( nonspace.location == NSNotFound ) {
		return;
	}
	
	NSRange remainder = NSMakeRange(nonspace.location, r);
	NSRange endWord = [string rangeOfCharacterFromSet:whitespace options:0 range:remainder];
	NSRange firstWord = NSMakeRange(nonspace.location, endWord.location - nonspace.location);
	if( endWord.location == NSNotFound ) {
		firstWord = remainder;
	} 

	[storage removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, [string length])];
        NSString* word = [string substringWithRange:firstWord];
	if( [[Resolver sharedInstance] isKeyword:word] ) {
		[storage addAttribute:NSForegroundColorAttributeName value:keywordColor range:firstWord];
	}
}

- (void) colorFirstWord: (NSText*) text {
	if( [text isKindOfClass: [NSTextView class]] ) {
		NSTextView *tv = (NSTextView*) text;
		NSString* string = [text string];
		[self colorFirstWord: [tv textStorage] fromString: string];
	}
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
	NSTextView *tv = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	[self colorFirstWord: tv];
}

- (void) defaultsChanged: (NSNotification*) note {
	[keywordColor release];
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:KeywordColorKey];
	keywordColor = [[NSUnarchiver unarchiveObjectWithData:data] retain];
}

@end

