//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/Resolver.h,v 1.3 2004/03/24 14:06:04 enno Exp $
//  Kwiggly
//
//  Created by Enno Brehm on Fri Mar 19 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Builtins.h"


@interface Resolver : NSObject {
    NSDictionary *searchDict;
    Builtins* builtins;
}


+ (Resolver *) sharedInstance;

- (void) readDefaults;
- (void) resolve: (NSString*) fullSearchString;
- (void) defaultsChanged: (NSNotification*) note;
-(BOOL) isKeyword:(NSString*) aString;


@end
