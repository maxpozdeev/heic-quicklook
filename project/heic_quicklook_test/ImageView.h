//
//  ImageView.h
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ImageView : NSView

- (void)setCgImage:(CGImageRef)cgImage;

@end
