//
//  ImageView.m
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import "ImageView.h"

@interface ImageView () {
	CIImage * _ciImage;
	CGImageRef _cgImage;
}
- (void)_drawCG;
- (void)_drawCI;
@end

@implementation ImageView

- (void)drawRect:(NSRect)dirtyRect
{
	[self _drawCG];   //faster if no interpolation
	
	//[self _drawCI]; //no much difference
}


- (void)setCgImage:(CGImageRef)cgImage
{
	_cgImage = cgImage;
	
	//uncomment to use _drawCI
	//_ciImage = [CIImage imageWithCGImage:cgImage];
}



- (void)_drawCG
{
	if (!_cgImage)
		return;

	CGFloat h = (CGFloat) CGImageGetHeight(_cgImage); //pixels, but we think this is in points
	CGFloat w = (CGFloat) CGImageGetWidth(_cgImage);

	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	NSSize tsz = [self bounds].size; //in points
	
	if (w < tsz.width && h < tsz.height)
	{
		//draw as is in the center of view
		CGContextDrawImage(context, CGRectMake( (CGFloat)(tsz.width-w)/2, (CGFloat)(tsz.height-h)/2, w, h), _cgImage);
	}
	else
	{
		//need to downscale and draw in the center of view
		NSSize newSize = NSMakeSize(w, h);
		CGFloat sw = w  / tsz.width;
		CGFloat sh = h / tsz.height;
		CGFloat scale = MAX(sw, sh);
		newSize.width /= scale;
		newSize.height /= scale;
		CGContextSetInterpolationQuality(context, kCGInterpolationNone);
		CGContextDrawImage(context, CGRectMake( (CGFloat)(tsz.width-newSize.width)/2, (CGFloat)(tsz.height-newSize.height)/2, newSize.width, newSize.height), _cgImage);
	}
}


- (void)_drawCI
{
	if (!_ciImage)
		return;
	
	
	CGFloat h = (CGFloat) CGImageGetHeight(_cgImage); //pixels, but we think this is in points
	CGFloat w = (CGFloat) CGImageGetWidth(_cgImage);
	
	NSSize tsz = [self bounds].size; //in points

	if (w < tsz.width && h < tsz.height)
	{
		[_ciImage drawAtPoint:NSMakePoint((tsz.width-w)/2, (tsz.height-h)/2)
					 fromRect:NSMakeRect(0, 0, w, h)
					operation:NSCompositeSourceOver
					fraction:1];
	}
	else
	{
		//need to downscale and draw in the center of view
		CGFloat scale = MAX(w/tsz.width, h/tsz.height);
		NSRect targetRect = NSMakeRect((tsz.width-w/scale)/2, (tsz.height-h/scale)/2, w/scale, h/scale);
		[_ciImage drawInRect:targetRect
					fromRect:NSMakeRect(0, 0, w, h)
				   operation:NSCompositeSourceOver
					fraction:1];
	}
	
}

@end
