//
//  oHEIF.h
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface oHEIF : NSObject

@property (strong, readonly) NSString *path;
@property (readonly) size_t width;
@property (readonly) size_t height;
@property (readonly) CGImageRef cgImage;

-(instancetype)initWithFileAtPath:(NSString*)path;
-(BOOL)decodeFirstImageWithColorSpace:(CGColorSpaceRef)_colorSpace;

+(NSString*)stringSizeOfImageAtPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
