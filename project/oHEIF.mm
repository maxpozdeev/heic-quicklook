//
//  oHEIF.m
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import "oHEIF.h"
#include <libheif/heif_cxx.h>
#include <turbojpeg.h>

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

-(BOOL)decodePrimaryImageWithColorSpace:(CGColorSpaceRef)_colorSpace
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


-(BOOL)decodePrimaryImageWithColorSpace2:(CGColorSpaceRef)_colorSpace
{
	CGColorSpaceModel model = CGColorSpaceGetModel(_colorSpace);
	if (model != kCGColorSpaceModelRGB)
	{
		NSLog(@"Output colorspace is not supported: %@", CGColorSpaceCopyName(_colorSpace));
		return NO;
	}
	
	
	try
	{
		heif::Context ctx = heif::Context();
		ctx.read_from_file( std::string(_path.UTF8String) );
		
		heif::ImageHandle imageHandle = ctx.get_primary_image_handle();
		_width  = (size_t)imageHandle.get_width();
		_height = (size_t)imageHandle.get_height();
		
		heif::Image image = imageHandle.decode_image(heif_colorspace_undefined, heif_chroma_undefined);
		
		heif_colorspace cs = image.get_colorspace();
		heif_chroma chroma = image.get_chroma_format();
		
		if (heif_colorspace_YCbCr == cs)
		{
			//convert to RGB using turbo-jpeg
			
			TJSAMP samp;
			if (heif_chroma_420 == chroma) samp = TJSAMP_420;
			else if (heif_chroma_422 == chroma) samp = TJSAMP_422;
			else if (heif_chroma_444 == chroma) samp = TJSAMP_444;
			else {
				NSLog(@"Unsupported input chroma : %i", chroma);
				return NO;
			}
			
			if (image.get_bits_per_pixel(heif_channel_Y) != 8 ||
				image.get_bits_per_pixel(heif_channel_Cb) != 8 ||
				image.get_bits_per_pixel(heif_channel_Cr) != 8)
			{
				NSLog(@"Unexpected bits per pixel");
				return NO;
			}
			
			
			int in_y_stride=0, in_cb_stride=0, in_cr_stride=0;
			const uint8_t* y = image.get_plane(heif_channel_Y, &in_y_stride);
			const uint8_t* u = image.get_plane(heif_channel_Cb, &in_cb_stride);
			const uint8_t* v = image.get_plane(heif_channel_Cr, &in_cr_stride);
			const unsigned char* planes[] = {y, u, v};
			
			tjhandle tjh = tjInitDecompress();
			int strides[] = {in_y_stride, in_cb_stride, in_cr_stride};
			unsigned char *buf = (unsigned char *)malloc(_width * 4 *_height);
			
			int r = tjDecodeYUVPlanes(tjh, (const unsigned char**)&planes, (int*)&strides, samp, buf, (int)_width, (int)_width*4, (int)_height, TJPF_RGBA, 0);
			if (r != 0)
			{
				NSLog(@"YUV decode failed: %i", r);
				free(buf);
				tjDestroy(tjh);
				return NO;
			}
			tjDestroy(tjh);
			
			CGContextRef bitmapContext = CGBitmapContextCreate(
															   (void*)buf,
															   _width,
															   _height,
															   8, // bitsPerComponent
															   (size_t)_width*4, // bytesPerRow
															   _colorSpace,
															   kCGImageAlphaNoneSkipLast);
			_cgImage = CGBitmapContextCreateImage(bitmapContext);
			CFRelease(bitmapContext);
			free(buf);
			
		}
		else
		{
			NSLog(@"Input file colorspace is not supported yet : %i", cs);
			return NO;
		}
		
		
		
		return YES;
	}
	catch (heif::Error e)
	{
		NSLog(@"libheif: %s", e.get_message().c_str() );
	}
	return NO;;
}

-(BOOL)decodePrimaryImageAndLog
{
	try
	{
		heif::Context ctx = heif::Context();
		ctx.read_from_file( std::string(_path.UTF8String) );
		
		heif::ImageHandle imageHandle = ctx.get_primary_image_handle();
		_width  = (size_t)imageHandle.get_width();
		_height = (size_t)imageHandle.get_height();
		
		heif::Image image = imageHandle.decode_image(heif_colorspace_undefined, heif_chroma_undefined);
		
		heif_colorspace cs = image.get_colorspace();
		heif_chroma chroma = image.get_chroma_format();
		
		if (cs == heif_colorspace_RGB) {
			NSLog(@"Colorspace: RGB, %i/%i/%i bpp", image.get_bits_per_pixel(heif_channel_R), image.get_bits_per_pixel(heif_channel_G), image.get_bits_per_pixel(heif_channel_B));
		}
		else if (cs == heif_colorspace_YCbCr) {
			NSLog(@"Colorspace: YUV, %i/%i/%i bpp", image.get_bits_per_pixel(heif_channel_Y), image.get_bits_per_pixel(heif_channel_Cb), image.get_bits_per_pixel(heif_channel_Cr));
		}
		else if (cs == heif_colorspace_monochrome) {
			NSLog(@"Colorspace: monochrome");
		}
		else
			NSLog(@"Colorspace: unknown %i", cs);

		
		if (chroma == heif_chroma_420)
			NSLog(@"Chroma: 4:2:0");
		else
			NSLog(@"Chroma: unknown %i", cs);
		
		
		heif_color_profile_type cpt = heif_image_handle_get_color_profile_type(imageHandle.get_raw_image_handle());
		if (cpt == heif_color_profile_type_not_present) {
			NSLog(@"No color profile");
		}
		else
		{
			size_t cpsize = heif_image_handle_get_raw_color_profile_size(imageHandle.get_raw_image_handle());
			
			if (cpt == heif_color_profile_type_nclx) {
				NSLog(@"Color profile: nclx, %ld bytes", cpsize);
			}
			else if (cpt == heif_color_profile_type_rICC) {
				NSLog(@"Color profile: rICC, %ld bytes", cpsize);
			}
			else if (cpt == heif_color_profile_type_prof) {
				NSLog(@"Color profile: prof, %ld bytes", cpsize);
			}
			else {
				NSLog(@"Color profile: unknown (%i), %ld bytes", cpt, cpsize);
			}
		}
		
		return NO;
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
	if (_cgImage) CFRelease(_cgImage);
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
