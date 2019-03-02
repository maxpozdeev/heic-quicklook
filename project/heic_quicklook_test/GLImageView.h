//
//  GLImageView.h
//  heic_quicklook
//
//  Created by max on 27.02.19.
//  Copyright (c) 2019 Max Pozdeev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GLImageView : NSOpenGLView

- (void)setCgImage:(CGImageRef)cgImage;

@end
