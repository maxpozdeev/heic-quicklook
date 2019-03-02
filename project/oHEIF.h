//
//  oHEIF.h
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface oHEIF : NSObject

@property (strong, readonly) NSString *path;
@property (readonly) size_t width;
@property (readonly) size_t height;
@property (readonly) CGImageRef cgImage;

-(instancetype)initWithFileAtPath:(NSString*)path;
-(CGSize)sizeOfPrimaryImage;
-(BOOL)decodeFirstImageWithColorSpace:(CGColorSpaceRef)_colorSpace;
-(BOOL)decodePrimaryImageWithColorSpace2:(CGColorSpaceRef)_colorSpace;
-(BOOL)decodePrimaryImageInOriginalColorspace;

+(NSString*)stringSizeOfImageAtPath:(NSString*)path;

@end
