//
//  GLImageView.m
//  heic_quicklook
//
//  Created by max on 27.02.19.
//  Copyright (c) 2019 Max Pozdeev. All rights reserved.
//

#import "GLImageView.h"
#import <QuartzCore/CoreImage.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>

@interface GLImageView () {
    CIImage * _ciImage;
	CGImageRef _cgImage;
	CGFloat w,h;
	
	CGLContextObj _cglContext;
	NSOpenGLPixelFormat *_pixelFormat;
	NSRect _lastBounds;
}
@property (nonatomic, strong) CIContext *context;
@end

@implementation GLImageView


- (void)setCgImage:(CGImageRef)cgImage
{
    _cgImage = cgImage;
    _ciImage = [CIImage imageWithCGImage:cgImage];
	
	h = (CGFloat) CGImageGetHeight(_cgImage); //pixels, but we think this is in points
	w = (CGFloat) CGImageGetWidth(_cgImage);
}

- (void)drawRect:(NSRect)dirtyRect {

	if (!self.context)
		[self setupContext];
	
    [self.openGLContext makeCurrentContext];
	
    if ([NSGraphicsContext currentContextDrawingToScreen])
    {
		[self updateMatrices];
		
		/*
		 Clear the specified subrect of the OpenGL surface then render the image into the view. Use the GL scissor test to clip to the subrect.
		 Ask CoreImage to generate an extra pixel in case it has to interpolate (allow for hardware inaccuracies).
		 */
/*
		CGRect integralRect = CGRectIntegral(NSRectToCGRect(dirtyRect));
		CGRect rr = CGRectIntersection(CGRectInset (integralRect, -1.0f, -1.0f), NSRectToCGRect(_lastBounds));
		
		glScissor(integralRect.origin.x, integralRect.origin.y, integralRect.size.width, integralRect.size.height);
		glEnable(GL_SCISSOR_TEST);
*/
		


		glClearColor(0.9f, 0.9f, 0.9f, 0.0f);
		glClear(GL_COLOR_BUFFER_BIT);

		
		if (_ciImage)
		{
			NSSize tsz = self.bounds.size; //in points
			NSRect targetRect = NSZeroRect;
			NSRect sourceRect = NSMakeRect(0, 0, w, h);
			
			if (w < tsz.width && h < tsz.height) {
				targetRect = NSMakeRect((tsz.width-w)/2, (tsz.height-h)/2, w, h);
			}
			else {
				CGFloat scale = MAX(w/tsz.width, h/tsz.height);
				targetRect = NSMakeRect((tsz.width-w/scale)/2, (tsz.height-h/scale)/2, w/scale, h/scale);
			}
			targetRect = CGRectIntegral(targetRect);
			
			//NSLog(@"Draw target %@ on %@, source %@", NSStringFromRect(targetRect), NSStringFromSize(self.bounds.size), NSStringFromRect(sourceRect));
			
			[self.context drawImage:_ciImage
							 inRect:targetRect
						   fromRect:sourceRect];
		}
			
		

		
//		glDisable(GL_SCISSOR_TEST);
		
		/*
		 Flush the OpenGL command stream. If the view is double buffered this should be replaced by [[self openGLContext] flushBuffer].
		 */
		
		glFlush();
    }
	else
	{
		NSLog(@"no drawing");
		
		//CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort], targetRect, cgImage);
		
	}
	
 

}

- (void)prepareOpenGL
{
	[super prepareOpenGL];
	NSLog(@"here");
	
	// Synchronize buffer swaps with vertical refresh rate
	GLint parm = 1;
    [self.openGLContext setValues:&parm forParameter:NSOpenGLCPSwapInterval];
    
    /* Make sure that everything we don't need is disabled. Some of these
     * are enabled by default and can slow down rendering. */
    
    glDisable(GL_ALPHA_TEST);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_SCISSOR_TEST);
    glDisable(GL_BLEND);
    glDisable(GL_DITHER);
    glDisable(GL_CULL_FACE);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_FALSE);
    glStencilMask(0);
    glClearColor(0.9f, 0.9f, 0.9f, 0.0f);
    glHint(GL_TRANSFORM_HINT_APPLE, GL_FASTEST);
}


- (void)updateMatrices
{
	NSRect bounds = [self bounds];
	
	if (!NSEqualRects(bounds, _lastBounds)) {
		
		[self.openGLContext update];
		
		/* Install an orthographic projection matrix (no perspective)
		 * with the origin in the bottom left and one unit equal to one
		 * device pixel. */
		
		glViewport(0, 0, bounds.size.width, bounds.size.height);
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrtho(0, bounds.size.width, 0, bounds.size.height, -1, 1);
		
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		
		_lastBounds = bounds;
	}
}

- (void)setupContext
{
    _cglContext = [self.openGLContext CGLContextObj];
    
    if (_pixelFormat == nil)
    {
        _pixelFormat = self.pixelFormat;
        if (_pixelFormat == nil) {
            _pixelFormat = [[self class] defaultPixelFormat];
        }
    }
	
	[self prepareOpenGL];
    
    CGLLockContext(_cglContext);
    {
        // Create a new CIContext using the new output color space
        // Since the cgl context will be rendered to the display, it is valid to rely on CI to get the colorspace from the context.
        self.context = [CIContext contextWithCGLContext:_cglContext
											pixelFormat:_pixelFormat.CGLPixelFormatObj
											 colorSpace:self.window.colorSpace.CGColorSpace
												options:nil];
    }
    CGLUnlockContext(_cglContext);
}

+ (NSOpenGLPixelFormat *)defaultPixelFormat
{
	static NSOpenGLPixelFormat *pf;
	
	if (pf == nil)
	{
		/*
		 Making sure the context's pixel format doesn't have a recovery renderer is important - otherwise CoreImage may not be able to create deeper context's that share textures with this one.
		 */
		static const NSOpenGLPixelFormatAttribute attr[] = {
			NSOpenGLPFAAccelerated,
			NSOpenGLPFANoRecovery,
			NSOpenGLPFAColorSize, 32,
			NSOpenGLPFAAllowOfflineRenderers,  /* Allow use of offline renderers */
			0
		};
		
		pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:(void *)&attr];
	}
	
	return pf;
}


@end
