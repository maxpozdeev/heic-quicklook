//
//  oHEIF.m
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import "oHEIF.h"
#include <libheif/heif_cxx.h>

@implementation oHEIF

//readonly property
@synthesize path = _path, width = _width, height = _height, cgImage = _cgImage;


-(instancetype)initWithFileAtPath:(NSString*)path
{
	self = [super init];
	_path = path;
	_cgImage = nil;
	
	return self;
}

-(CGSize)sizeOfPrimaryImage
{
    try
    {
        heif::Context ctx = heif::Context();
        ctx.read_from_file( std::string(_path.UTF8String) );
        
        heif::ImageHandle imageHandle = ctx.get_primary_image_handle();
        CGFloat w = (CGFloat)imageHandle.get_width();
        CGFloat h = (CGFloat)imageHandle.get_height();
        return CGSizeMake(w, h);
    }
    catch (heif::Error e)
    {
        NSLog(@"libheif: %s", e.get_message().c_str() );
        return CGSizeZero;
    }
}

-(BOOL)decodeFirstImageWithColorSpace:(CGColorSpaceRef)_colorSpace
{
	try
	{
		heif::Context ctx = heif::Context();
		ctx.read_from_file( std::string(_path.UTF8String) );
		
		heif::ImageHandle imageHandle = ctx.get_primary_image_handle();
		_width  = (size_t)imageHandle.get_width();
		_height = (size_t)imageHandle.get_height();
		
		heif::Image image = imageHandle.decode_image(heif_colorspace_RGB, heif_chroma_interleaved_RGBA); //32 bit per pixel
		
		int stride;
		const uint8_t* data = image.get_plane(heif_channel_interleaved, &stride);
		
		if (stride == 0)
			return NO;
		
		//CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef bitmapContext = CGBitmapContextCreate(
														   (void*)data,
														   _width,
														   _height,
														   8, // bitsPerComponent
														   (size_t)stride, // bytesPerRow
														   _colorSpace,
														   kCGImageAlphaNoneSkipLast);
		//CFRelease(colorSpace);
		_cgImage = CGBitmapContextCreateImage(bitmapContext);
		CFRelease(bitmapContext);

		return YES;
		
		//CFBridgingRelease(cgImage); //CFRelease(cgImage);
	}
	catch (heif::Error e)
	{
		NSLog(@"libheif: %s", e.get_message().c_str() );
		return NO;
	}
	return NO;
}

-(void)dealloc
{
	CFRelease(_cgImage);
	//[super dealloc]; //ARC will
}



+(NSString*)stringSizeOfImageAtPath:(NSString*)path
{
	try
	{
		heif::Context ctx = heif::Context();
		ctx.read_from_file( std::string(path.UTF8String) );
		
		heif::ImageHandle image = ctx.get_primary_image_handle();
		
		int w = image.get_width();
		int h = image.get_height();
		
		return [NSString stringWithFormat:@"%i x %i", w, h];
		
	}
	catch (heif::Error e)
	{
		NSLog(@"libheif: %s", e.get_message().c_str() );
		return nil;
	}
}

@end
