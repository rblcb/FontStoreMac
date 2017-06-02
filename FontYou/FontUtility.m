//
//  FontUtility.m
//  FontUtility
//
//  Created by Devs on 08/03/2017.
//  Copyright © 2017 fontyou. All rights reserved.
//

#import "FontUtility.h"

@implementation FontUtility


NSString * ADD_KEY = @"CTFontManagerAvailableFontURLsAdded";
NSString * REMOVE_KEY = @"CTFontManagerAvailableFontURLsRemoved";

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
        } else {
            NSArray *errors = (__bridge NSArray*)cfErrors;
            NSError *error = errors[0];
            
            // We allow error 105 (Font already activated for this scope)
            
            if (error.code == 105) activationRes = YES;
        }
    }

    if (activationRes == YES) {
        NSDictionary * nsInfo = [NSDictionary dictionaryWithObjectsAndKeys: ADD_KEY, fonts, nil];
        ATSFontNotify(kATSFontNotifyActionFontsChanged, (__bridge void *)(nsInfo));
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
                    NSDictionary * nsInfo = [NSDictionary dictionaryWithObjectsAndKeys: REMOVE_KEY, fonts, nil];
                    ATSFontNotify(kATSFontNotifyActionFontsChanged, (__bridge void *)(nsInfo));
                    return YES;
                }
            }
        }
        return NO;
    } else {
        NSDictionary * nsInfo = [NSDictionary dictionaryWithObjectsAndKeys: REMOVE_KEY, fonts, nil];
        ATSFontNotify(kATSFontNotifyActionFontsChanged, (__bridge void *)(nsInfo));
        return YES;
    }
}

+(BOOL) isFontActive:(NSURL *)fileUrl withScope:(CTFontManagerScope)expectedScope {
    int scope = CTFontManagerGetScopeForURL((__bridge CFURLRef)fileUrl);
    return scope == expectedScope;
}

+(CGFontRef) createCGFontFromData:(NSData*)data CF_RETURNS_RETAINED {
    if (data == nil) {
        return NULL;
    }

    CFDataRef cfdata = (__bridge CFDataRef)data;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(cfdata);

    CGFontRef cgfont = CGFontCreateWithDataProvider(provider);
    CGDataProviderRelease(provider);

    return cgfont;
}

+(BOOL) activateCGFont:(CGFontRef)font {
    if (font == NULL) {
        return NO;
    }

    return CTFontManagerRegisterGraphicsFont(font, NULL);
}

+(BOOL) deactivateCGFont:(CGFontRef)font {
    if (font == NULL) {
        return NO;
    }

    return CTFontManagerUnregisterGraphicsFont(font, NULL);
}

@end
