//
//  FontUtility.m
//  FontUtility
//
//  Created by Devs on 08/03/2017.
//  Copyright © 2017 fontyou. All rights reserved.
//

#import "FontUtility.h"

@implementation FontUtility

+(BOOL) activateFontFile:(NSURL *)fileUrl withScope:(CTFontManagerScope)scope {
    NSArray *fonts = @[fileUrl];
    CFArrayRef fontURLs = (__bridge CFArrayRef)fonts;
    CFArrayRef cfErrors = NULL;
    BOOL activationRes = YES;

    @try {
        activationRes = CTFontManagerRegisterFontsForURLs(fontURLs, scope, &cfErrors);
    }
    @catch (NSException *e) {
        activationRes = NO;
    }

    if (activationRes == NO) { // Activation fail
        if (cfErrors == NULL || CFArrayGetCount(cfErrors) == 0) {
            CFErrorRef err = NULL;
            activationRes = YES;

            @try {
                activationRes = CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fileUrl, scope, &err);
            }
            @catch (NSException *e) {
                activationRes = NO;
            }
        }
    }

    if (cfErrors != NULL) {
        CFRelease(cfErrors);
    }
    return activationRes;
}

+(BOOL) deactivateFontFile:(NSURL *)fileUrl withScope:(CTFontManagerScope)scope {
    CFArrayRef errors = NULL;
    BOOL res = YES;

    if (fileUrl == nil || [fileUrl isFileURL] == NO) {
        return NO;
    }

    NSArray *fonts = @[fileUrl];
    CFArrayRef toDeactivate = (__bridge CFArrayRef)fonts;
    @try {
        res = CTFontManagerUnregisterFontsForURLs(toDeactivate, scope, &errors);
    }
    @catch (NSException *exception) {
        res = NO;
    }

    if (!res) {
        if(errors == NULL || CFArrayGetCount(errors) == 0) {
            int fontScope = CTFontManagerGetScopeForURL((__bridge CFURLRef)fileUrl);
            if (fontScope == kCTFontManagerScopeNone) {
                return YES;
            } else {
                CFErrorRef fontError = NULL;
                BOOL fontRes = YES;

                @try {
                    fontRes = CTFontManagerUnregisterFontsForURL((__bridge CFURLRef)fileUrl, fontScope, &fontError);
                }
                @catch (NSException *e) {
                    fontRes = NO;
                }

                if(fontRes) {
                    return YES;
                }
            }
        }
        return NO;
    } else {
        return YES;
    }
}

+(BOOL) isFontActive:(NSURL *)fileUrl withScope:(CTFontManagerScope)expectedScope {
    int scope = CTFontManagerGetScopeForURL((__bridge CFURLRef)fileUrl);
    return scope == expectedScope;
}

@end