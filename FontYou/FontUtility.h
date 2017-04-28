//
//  FontUtility.h
//  FontUtility
//
//  Created by Devs on 08/03/2017.
//  Copyright © 2017 fontyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontUtility : NSObject

/*!
    @function activateFontFile
    @abstract Activate a font from a file on the file system.
 
    @param  fileUrl
            Url of the font file to activate
 
    @param  scope
            The scope of the font activation
 
    @result Return false if the activation failed and true otherwise.
 */
+(BOOL) activateFontFile:(NSURL*)fileUrl withScope:(CTFontManagerScope)scope;

/*!
    @function deactivateFontFile
    @abstract Deactivate a font from a file on the file system.
 
    @param  fileUrl
            Url of the font file to deactivate
 
    @param  scope
            The scope of the font activation

    @result Return false if the deactivation failed and true otherwise.
 */
+(BOOL) deactivateFontFile:(NSURL*)fileUrl withScope:(CTFontManagerScope)scope;

/*!
    @function isFontActive
    @abstract Test if a font is active on the system.

    @param  fileUrl
            Url of the font file to test

    @param  scope
            The scope in wich to test if the font is active

    @result Return true if the font is active in the required scope and false otherwise.
 */
+(BOOL) isFontActive:(NSURL*)fileUrl withScope:(CTFontManagerScope)scope;

/*!
    @function createCGFontFromData
    @abstract Create a CGFont from the provided data
 
    @param  data
            Font data to use to create the CGFont
 
    @result Return NULL if the font creation failed and the create CGFontRef otherwise.
            The caller is responsible for releasing the returned object by using CGFontRelease.
 
    @remarks Before using the CGFont to render text, the font must be set in the current graphics state by calling CGContextSetFontSize.
 */
+(CGFontRef) createCGFontFromData:(NSData*)data;

/*!
    @function activateFontMem
    @abstract Activate a font in memory.
 
    @param  font
            The font to activate.
 
    @result Return true if the activation succeed and false otherwise.
 
    @remarks A font activated in memory is only available to the process that activated it.
 */
+(BOOL) activateCGFont:(CGFontRef)font;

/*!
 @function deactivateFontMem
 @abstract Deactivate a font activated in memory.

 @param font
        The font to activate.

 @result Return true if the deactivation succeed and false otherwise.
 */
+(BOOL) deactivateCGFont:(CGFontRef)font;

@end
