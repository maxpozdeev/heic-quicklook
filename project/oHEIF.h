//
//  oHEIF.h
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface oHEIF : NSObject {
    size_t _width;
    size_t _height;
    CGImageRef _cgImage;
}

@property (strong, readonly) NSString *path;
@property (readonly) size_t width;
@property (readonly) size_t height;
@property (readonly) CGImageRef cgImage;
@property (readwrite) NSString *lastErrorString;

-(instancetype)initWithFileAtPath:(NSString*)path;
-(CGSize)sizeOfPrimaryImage;
-(BOOL)decodePrimaryImage;
-(BOOL)decodePrimaryImageWithColorSpace:(CGColorSpaceRef)_colorSpace;
-(BOOL)decodePrimaryImageAndLog;

+(NSString*)stringSizeOfImageAtPath:(NSString*)path;

@end
