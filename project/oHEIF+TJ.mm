//
//  oHEIF+TJ.m
//  heic_quicklook
//
//  Created by Max Pozdeev on 29.01.2021.
//  Copyright © 2021 Max Pozdeev. All rights reserved.
//

#import "oHEIF+TJ.h"
#include <libheif/heif_cxx.h>
#include <turbojpeg.h>

@implementation oHEIF (TJ)

-(BOOL)decodePrimaryImageWithTJ
{
    try
    {
        heif::Context ctx = heif::Context();
        ctx.read_from_file( std::string(self.path.UTF8String) );
        
        heif::ImageHandle imageHandle = ctx.get_primary_image_handle();
        _width  = (size_t)imageHandle.get_width();
        _height = (size_t)imageHandle.get_height();

        // Try to get raw decoded image without color conversions
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
            
            
            // Try to use embedded color profile
            CGColorSpaceRef cs = NULL;
            
            heif_color_profile_type cpt = heif_image_handle_get_color_profile_type(imageHandle.get_raw_image_handle());
            if (cpt != heif_color_profile_type_not_present)
            {
                size_t cpsize = heif_image_handle_get_raw_color_profile_size(imageHandle.get_raw_image_handle());
                void *cpdata = malloc(cpsize);
                heif_error err = heif_image_handle_get_raw_color_profile((const heif_image_handle*)imageHandle.get_raw_image_handle(), cpdata);
                if (err.code == heif_error_Ok)
                {
                    NSData *csd = [NSData dataWithBytes:cpdata length:cpsize];
                    cs = CGColorSpaceCreateWithICCProfile((__bridge CFDataRef)csd);
                }
                free(cpdata);
            }
            
            // instead use sRGB
            if (!cs) {
                cs = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
            }
            
            CGContextRef bitmapContext = CGBitmapContextCreate(
                                                               (void*)buf,
                                                               _width,
                                                               _height,
                                                               8, // bitsPerComponent
                                                               (size_t)_width*4, // bytesPerRow
                                                               cs,
                                                               kCGImageAlphaNoneSkipLast);
            _cgImage = CGBitmapContextCreateImage(bitmapContext);
            CGColorSpaceRelease(cs);
            CFRelease(bitmapContext);
            free(buf);

        }
        else if (heif_colorspace_RGB == cs)
        {
            //int bpp = image.get_bits_per_pixel(heif_channel_interleaved); //32
            
            int stride;
            uint8_t* data = image.get_plane(heif_channel_interleaved, &stride);
            
            if ( ! data ) {
                NSLog(@"No plane data after decoding");
            }
            
            
            // Try to use embedded color profile
            CGColorSpaceRef cs = NULL;
            
            heif_color_profile_type cpt = heif_image_handle_get_color_profile_type(imageHandle.get_raw_image_handle());
            if (cpt != heif_color_profile_type_not_present)
            {
                size_t cpsize = heif_image_handle_get_raw_color_profile_size(imageHandle.get_raw_image_handle());
                void *cpdata = malloc(cpsize);
                heif_error err = heif_image_handle_get_raw_color_profile((const heif_image_handle*)imageHandle.get_raw_image_handle(), cpdata);
                if (err.code == heif_error_Ok)
                {
                    NSData *csd = [NSData dataWithBytes:cpdata length:cpsize];
                    cs = CGColorSpaceCreateWithICCProfile((__bridge CFDataRef)csd);
                }
                free(cpdata);
            }
            
            // instead use sRGB
            if (!cs) {
                cs = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
            }
            
            CGContextRef bitmapContext = CGBitmapContextCreate(
                                                               (void*)data,
                                                               _width,
                                                               _height,
                                                               8, // bitsPerComponent
                                                               (size_t)_width * 4, // bytesPerRow (=stride)
                                                               cs,
                                                               kCGImageAlphaNoneSkipLast);
            _cgImage = CGBitmapContextCreateImage(bitmapContext);
            CGColorSpaceRelease(cs);
            CFRelease(bitmapContext);
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
        self.lastErrorString = [NSString stringWithFormat:@"libheif: %s", e.get_message().c_str()];
        NSLog(@"%@", self.lastErrorString);
    }
    return NO;;
}

@end
