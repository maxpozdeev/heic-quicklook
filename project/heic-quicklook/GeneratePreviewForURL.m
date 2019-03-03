#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <Foundation/Foundation.h>
#import "oHEIF.h"


OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    @autoreleasepool {
        
        oHEIF *heicFile = [[oHEIF alloc] initWithFileAtPath:((__bridge NSURL*)url).path];
        CGSize size = [heicFile sizeOfPrimaryImage];
        
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            return noErr;
        }
        
        CGContextRef context = QLPreviewRequestCreateContext(preview, size, true, NULL);
		//CGColorSpaceRef cs = CGBitmapContextGetColorSpace(context); //no need to release //kCGColorSpaceDeviceRGB
		CGColorSpaceRef cs = CGDisplayCopyColorSpace(CGMainDisplayID()); //RGB with monitor color profile
		//NSLog(@"colorspace: %@", cs);
        
        //if ([heicFile decodeFirstImageWithColorSpace:cs])
		BOOL decoded = [heicFile decodePrimaryImageWithColorSpace2:cs];
		CGColorSpaceRelease(cs);
		if (decoded)
        {
            if (QLPreviewRequestIsCancelled(preview)) {
                CGContextRelease(context);
                return noErr;
            }
            
            CGRect rect = CGRectMake(0, 0, size.width, size.height);
            CGContextDrawImage(context, rect, heicFile.cgImage);
            QLPreviewRequestFlushContext(preview, context);
        }
        CGContextRelease(context);
    }
    
    return noErr;
}


void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}

