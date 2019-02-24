//
//  ImageView.m
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import "ImageView.h"

@implementation ImageView

- (void)drawRect:(NSRect)dirtyRect
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
		CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
		CGContextDrawImage(context, CGRectMake( (CGFloat)(tsz.width-newSize.width)/2, (CGFloat)(tsz.height-newSize.height)/2, newSize.width, newSize.height), _cgImage);
	}

}

@end
