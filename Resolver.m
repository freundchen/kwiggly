//
//  $Header: /home/cvsmaster/CVSROOT/MacUtils/Kwiggly/Resolver.m,v 1.7 2004/03/26 15:57:38 enno Exp $
//  Kwiggly
//
//  Created by Enno Brehm on Fri Mar 19 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "Resolver.h"
#import "Commons.h"

static Resolver* theInstance = nil;

@implementation Resolver

- (id) init {
    self = [super init];
    if( self ) {
        builtins = [[Builtins alloc] init];
        [self readDefaults];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(defaultsChanged:) 
                                                     name: NSUserDefaultsDidChangeNotification 
                                                   object: nil];
		
    }
    return self;
}

- (void) dealloc {
    [builtins release];
    [searchDict release];
    [super dealloc];
}

+ (Resolver *) sharedInstance {
    if( theInstance == nil ) {
        theInstance = [[Resolver alloc] init];
        [theInstance readDefaults];
    }
    
    return theInstance;
}



-(NSString*) locateScript: (NSString*) scriptName {
    NSArray* searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSAllDomainsMask,YES);
    NSString *appendix = [NSString stringWithFormat:@"Application Support/Kwiggly/Scripts/%@.scpt", scriptName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    int i;
    for(i=0; i<[searchPaths count]; i++) {
        NSString *scriptPath = [[searchPaths objectAtIndex:i] stringByAppendingPathComponent: appendix];
        
        if ([fileManager fileExistsAtPath:scriptPath]) 
            return scriptPath;
    }
    
    /* finally, look in the bundle */
    return [[NSBundle mainBundle] pathForResource:scriptName ofType:@"scpt"];
}


- (void) scriptHandler: (NSString*) scriptName searchString: (NSString*) searchString {
    NSString* scriptPath = [self locateScript: scriptName];
    if( scriptPath == nil ) {
        NSLog(@"could not locate script %@.scpt", scriptName);
        return;
    }
    
    NSString *launcher = [NSString stringWithFormat: @"tell (load script (POSIX file \"%@\")) to feedMe(\"%@\")", scriptPath, searchString ];
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource: launcher];
    if( as == NULL ) {
        NSLog(@"could find but not instantiate script %@", scriptName);
    }
    
    NSDictionary *errorInfo;
    if( ! [as executeAndReturnError: &errorInfo] ) {
        NSLog(@"%@", errorInfo);
    };
    [as release];
}

- (void) builtinHandler: (NSString*) configParam searchString: (NSString*) searchString {
        //NSLog(@"builtin func <%@> %@", configParam, builtins);
        [builtins performBuiltin:configParam withArgument: searchString];
}


- (void) httpHandler: (NSString*) configURL searchString: (NSString*) searchString {
    /* TODO: what about multiple replacements? */
    NSMutableString *url = [NSMutableString stringWithFormat: @"http:%@", configURL];
    [url replaceOccurrencesOfString:@"%@" withString:searchString options:0 range:NSMakeRange(0, [url length])];
    //NSString *url = [@"http:" stringByAppendingFormat:configURL, searchString];
    NSString *escaped = (NSString*) 
		CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8 );
    
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: escaped]];
}    
    
- (void) urlHandler: (NSString*) configURL searchString: (NSString*) searchString {
    //NSString *url = [NSString stringWithFormat: configURL, searchString];
    NSMutableString *url = [NSMutableString stringWithString: configURL];
    [url replaceOccurrencesOfString:@"%@" withString:searchString options:0 range:NSMakeRange(0, [url length])];
    
    NSString *escaped = (NSString*) 
		CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8 );
    
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: escaped]];
}

- (void) logHandler: (NSString*) configURL searchString: (NSString*) searchString {
    NSMutableString *url = [NSMutableString stringWithString: configURL];
    [url replaceOccurrencesOfString:@"%@" withString:searchString options:0 range:NSMakeRange(0, [url length])];

    // for output we need to escape the % in url, if there are any left
    [url replaceOccurrencesOfString:@"%" withString:@"%%" options:0 range:NSMakeRange(0, [url length])];

    NSLog(url);
}


- (void) performHandler: (NSString*) protocol 
    configParameter: (NSString*) configParam 
           searchString: (NSString*) searchString {
    NSString* actualSelector = [protocol stringByAppendingString:@"Handler:searchString:"];
    SEL sel = NSSelectorFromString(actualSelector);
    //NSLog(@"handler: %@ %@ %@", actualSelector, configParam, searchString);
    
    if( [self respondsToSelector:sel] ) {
        [self performSelector:sel withObject: configParam withObject:searchString];
    }
    else {
        NSLog(@"no selector %@", actualSelector);
    }
}

-(BOOL) isKeyword:(NSString*) aString {
	return [searchDict objectForKey: aString] != nil;
}

- (IBAction) resolve: (NSString*) fullSearchString {
    NSCharacterSet *trimWSSet = [NSCharacterSet whitespaceCharacterSet];
    
    NSRange space = [fullSearchString rangeOfString: @" "];
    NSString *keyword = nil;
    
    NSString *searchString;
    if( space.location != NSNotFound ) {
        keyword = [fullSearchString substringToIndex: space.location];
        searchString = [[fullSearchString substringFromIndex: space.location + 1]
            stringByTrimmingCharactersInSet: trimWSSet];
    } else {
        keyword = fullSearchString;
        searchString = @"";
    }
    
    NSString* format = [searchDict objectForKey: keyword];
    if( format == nil ) {
        /* by default use google if no keyword given */
		/* XXX: evilknevil because url hard coded! */
        format = @"http://www.google.com/search?q=%@&ie=UTF-8&oe=UTF-8";
        searchString = fullSearchString;
    }
    
    NSString* protocol;
    NSString* configParam;
    NSRange colon = [format rangeOfString:@":"];
    if( colon.location == NSNotFound ) {
        protocol = format;
        configParam = @"";
    } else {
        protocol = [format substringToIndex: colon.location];
        configParam = [[format substringFromIndex: colon.location + 1]
            stringByTrimmingCharactersInSet: trimWSSet];
    }
    [self performHandler:protocol configParameter:configParam searchString:searchString];
    
    
    
}


-(void) readDefaults {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults dictionaryForKey: @"keywordMap"];
    
    if (dict == nil) {
        NSString *fpath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
        NSDictionary *defaultsDict = [[NSDictionary dictionaryWithContentsOfFile:fpath] retain];
        dict = [defaultsDict objectForKey:@"keywords"];
        [defaults setObject: dict forKey: @"keywordMap"];
    }
    
    [searchDict release];
    searchDict = [dict retain];
}

- (void) defaultsChanged: (NSNotification*) note {
	[self readDefaults];
}


@end
