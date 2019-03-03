//
//  CGWindowController.m
//  heic_quicklook
//
//  Created by max on 27.02.19.
//  Copyright (c) 2019 Max Pozdeev. All rights reserved.
//

#import "CGWindowController.h"
#import "ImageView.h"
#import "oHEIF.h"

@interface CGWindowController ()

@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet ImageView *view;

@property (strong) oHEIF *heicFile;

@end

@implementation CGWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)openFile:(id)sender {
    
    NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
     {
         if(result == NSFileHandlingPanelOKButton)
         {
             [self doOpenFile:openPanel.URL.path];
         }
     }];
}

-(void)doOpenFile:(NSString*)filename
{
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
    [self.window setTitleWithRepresentedFilename:filename];
    
    NSString *fileExt = filename.pathExtension.lowercaseString;
    if (![fileExt isEqualToString:@"heic"] )
    {
        self.label.stringValue = [NSString stringWithFormat:@"%@ | Not a HEIC file", filename.lastPathComponent];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
					   NSDate *methodStart = [NSDate date];
					   
                       self.heicFile = [[oHEIF alloc] initWithFileAtPath:filename];
					   
					   //CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
					   CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
                       if ([self.heicFile decodePrimaryImageWithColorSpace:cs])
                       {
						   NSDate *methodFinish = [NSDate date];
						   NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
						   
                           self.label.stringValue = [NSString stringWithFormat:@"%@ | %ldx%ld | %f sec", self.heicFile.path.lastPathComponent, self.heicFile.width, self.heicFile.height, executionTime];
                           [self.view setCgImage:self.heicFile.cgImage];
                           [self.view setNeedsDisplay:YES];
                       }
                       else {
                           self.label.stringValue = [NSString stringWithFormat:@"%@ | %ldx%ld | Can not decode image", self.heicFile.path.lastPathComponent, self.heicFile.width, self.heicFile.height];
                       }
					   CGColorSpaceRelease(cs);
                       
                   });
}

@end
