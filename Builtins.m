//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/Builtins.m,v 1.5 2004/03/26 15:57:38 enno Exp $
//  Kwiggly
//
//  Created by Enno Brehm on Fri Mar 19 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
#include <objc/objc-class.h>
#import "Builtins.h"

#import <AddressBook/AddressBook.h>

Class get_isa(id o) {
	return ((struct objc_object*)o)->isa;
}

long get_info(id cl) {
	return ((struct objc_class*)cl)->info;
}

@implementation Builtins
- (void) preferences: (NSString*) s{
    [NSApp tryToPerform: @selector(showPreferences:) with: self];
}

- (void) log:(NSString*) aString{
	NSLog(aString);
}

- (void) launch:(NSString*) aString{
    if( ! [[NSWorkspace sharedWorkspace] launchApplication:aString] ) {
        NSBeep();
    };
}

- (void) quit:(NSString*) aString{
    [NSApp terminate: self];
}

- (void) about:(NSString*) aString{
    [NSApp orderFrontStandardAboutPanel:self];
}

-(void) executeScript: (NSString*) searchString {
    NSLog(@"execute script: %@", searchString);
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource: searchString];
    NSDictionary *errorInfo;
    if( ! [script executeAndReturnError: &errorInfo] ) {
        NSLog(@"%@", errorInfo);
    };
    [script release];
} 
    
- (void) performBuiltin: (NSString*) selector withArgument: (NSString*) aString {
    NSString* actualSelector = [selector stringByAppendingString:@":"];
    SEL sel = NSSelectorFromString(actualSelector);
    
    if( [self respondsToSelector:sel] ) {
        [self performSelector:sel withObject: aString];
    }
    else {
        NSLog(@"no selector %@", actualSelector);
    }
}

- (void) newmail:(NSString*) aString{
    ABAddressBook *AB = [ABAddressBook sharedAddressBook];
    
    ABSearchElement *nickName =
        [ABPerson searchElementForProperty:kABNicknameProperty
                                     label:nil
                                       key:nil
                                     value: aString
                                comparison:kABEqualCaseInsensitive];
    
    NSArray *peopleFound =
        [AB recordsMatchingSearchElement:nickName];
    
    if( [peopleFound count] == 0) {
        NSLog(@"nickname search failed, trying last/first name");
        NSString* properties[] = { kABLastNameProperty, kABFirstNameProperty, kABFirstNamePhoneticProperty, kABLastNamePhoneticProperty, nil };
        NSString** prop = properties;
        NSMutableArray *propElems = [NSMutableArray array];
        
        for(; *prop != nil; prop++) {
            ABSearchElement *elem =
            [ABPerson searchElementForProperty:*prop
                                         label:nil
                                           key:nil
                                         value: aString
                                    comparison:kABEqualCaseInsensitive];
            [propElems addObject:elem];
        }
/*
        ABSearchElement *firstName =
            [ABPerson searchElementForProperty:kABFirstNameProperty
                                         label:nil
                                           key:nil
                                         value: aString
                                    comparison:kABEqualCaseInsensitive];
        
        ABSearchElement *lastName =
            [ABPerson searchElementForProperty:kABLastNameProperty
                                         label:nil
                                           key:nil
                                         value: aString
                                    comparison:kABEqualCaseInsensitive];
        
        ABSearchElement *firstName =
            [ABPerson searchElementForProperty:kABFirstNameProperty
                                         label:nil
                                           key:nil
                                         value: aString
                                    comparison:kABEqualCaseInsensitive];
        
*/
        
        ABSearchElement *combined =
            [ABSearchElement searchElementForConjunction:kABSearchOr
                                                children:propElems];
        peopleFound = [AB recordsMatchingSearchElement:combined];
    }
    
    
    int i;
    //NSLog(@"%d people found", [peopleFound count]);
    for(i=0; i< [peopleFound count]; i++) {
        ABPerson *person = [peopleFound objectAtIndex:i];
        ABMultiValue *emails = [person valueForProperty: kABEmailProperty];
        NSString *primIdent = [emails primaryIdentifier];
        int index = [emails indexForIdentifier:primIdent];
        NSString *email = [NSString stringWithFormat:@"mailto:%@", [emails valueAtIndex:index]];
        NSURL *emailURL = [NSURL URLWithString: email];
        NSLog(@"%@", emailURL);
        
        [[NSWorkspace sharedWorkspace] openURL:emailURL];
    }
}



@end

