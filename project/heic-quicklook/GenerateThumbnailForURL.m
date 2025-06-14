#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import "oHEIF.h"
#import "oHEIF+TJ.h"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
	@autoreleasepool {
		
		//NSLog(@"HEICAVIF: want thumb for %@, options %@, maxSize %@", url, options, NSStringFromSize(maxSize));
		
		float needScale = [[((__bridge NSDictionary*)options) objectForKey:@"QLThumbnailOptionScaleFactor"] floatValue];
		CGSize needSize = maxSize;
		if (needScale > 1.0) needSize = CGSizeMake(maxSize.width * needScale, maxSize.height * needScale);
		
		oHEIF *heicFile = [[oHEIF alloc] initWithFileAtPath:((__bridge NSURL*)url).path];
		CGSize size = [heicFile sizeOfPrimaryImage];
		
		if (CGSizeEqualToSize(size, CGSizeZero)) {
			return noErr;
		}
		
		
		BOOL decoded = [heicFile decodePrimaryImageWithTJ];
		if (decoded)
		{
			if (QLThumbnailRequestIsCancelled(thumbnail)) {
				return noErr;
			}

			CGImageRef imageToShow = heicFile.cgImage;
			
			//make smaller for cache?
			if (size.width > needSize.width || size.height > needSize.height)
			{
				CGFloat scale = MAX(size.width/needSize.width, size.height/needSize.height);
				CGRect targetRect = CGRectIntegral(CGRectMake(0, 0, size.width/scale, size.height/scale));
				
				CGContextRef newImageContext = CGBitmapContextCreate (NULL, targetRect.size.width, targetRect.size.height, 8, 0, CGImageGetColorSpace(imageToShow), kCGImageAlphaNoneSkipLast);
				CGContextSetInterpolationQuality(newImageContext, kCGInterpolationNone);
				CGContextDrawImage(newImageContext, targetRect, heicFile.cgImage);
				imageToShow = CGBitmapContextCreateImage(newImageContext);
				CFRelease(newImageContext);
			}
			
            // On catalina+ use "icon" as flavor key
            NSDictionary *properties = @{ @"IconFlavor": @(5), @"icon": @(5) }; //icon mode for images 5
	
			QLThumbnailRequestSetImage(thumbnail, imageToShow, (__bridge CFDictionaryRef) properties);
		}

	}
	
	return noErr;
}


void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}


