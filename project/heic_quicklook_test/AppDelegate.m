//
//  AppDelegate.m
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import "AppDelegate.h"
#import "oHEIF.h"
#import "ImageView.h"

@interface AppDelegate ()


@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet ImageView *view;

@property (strong) oHEIF *heicFile;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
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


- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames;
{
	if (filenames && filenames.count > 0)
		[self doOpenFile:[filenames objectAtIndex:0]];
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
	   self.heicFile = [[oHEIF alloc] initWithFileAtPath:filename];
	   if ([self.heicFile decodeFirstImageWithColorSpace:self.window.colorSpace.CGColorSpace])
	   {
		   self.label.stringValue = [NSString stringWithFormat:@"%@ | %ldx%ld", self.heicFile.path.lastPathComponent, self.heicFile.width, self.heicFile.height];
		   //self.view.image = [[NSImage alloc] initWithCGImage:self.heicFile.cgImage size:NSZeroSize];
		   self.view.cgImage = self.heicFile.cgImage;
		   [self.view setNeedsDisplay:YES];
	   }
	   else {
		   self.label.stringValue = [NSString stringWithFormat:@"%@ | %ldx%ld | Can not decode image", self.heicFile.path.lastPathComponent, self.heicFile.width, self.heicFile.height];
	   }
	   
   });
}


@end
