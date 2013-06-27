//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/Builtins.h,v 1.1 2004/03/19 20:36:29 enno Exp $
//  Kwiggly
//
//  Created by Enno Brehm on Fri Mar 19 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Builtins : NSObject {

}

- (void) performBuiltin: (NSString*) selector withArgument: (NSString*) aString;


- (void) log:(NSString*) aString;
- (void) quit:(NSString*) aString;
- (void) about:(NSString*) aString;

@end
