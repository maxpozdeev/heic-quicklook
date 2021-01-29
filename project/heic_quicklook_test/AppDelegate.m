//
//  AppDelegate.m
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import "AppDelegate.h"
#import "oHEIF.h"
#import "GLWindowController.h"
#import "CGWindowController.h"

@interface AppDelegate ()


@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSImageView *iview;

@property (strong) GLWindowController * wcGL;
@property (strong) CGWindowController * wcCG;

@property (strong) oHEIF *heicFile;
@property (strong) NSString *filepath;

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


- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames;
{
	if (filenames && filenames.count > 0)
		[self doOpenFile:[filenames objectAtIndex:0]];
}


-(void)doOpenFile:(NSString*)filename
{
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
	[self.window setTitleWithRepresentedFilename:filename];
    self.filepath = filename;

    dispatch_async(dispatch_get_main_queue(), ^
   {
	   NSDate *methodStart = [NSDate date];
	   
	   self.heicFile = [[oHEIF alloc] initWithFileAtPath:filename];
	   if ([self.heicFile decodePrimaryImage])
	   //if ([self.heicFile decodePrimaryImageAndLog])
	   {
		   NSDate *methodFinish = [NSDate date];
		   NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
	   
		   self.label.stringValue = [NSString stringWithFormat:@"%@ | %ldx%ld | %f sec", self.heicFile.path.lastPathComponent, self.heicFile.width, self.heicFile.height, executionTime];
		   self.iview.image = [[NSImage alloc] initWithCGImage:self.heicFile.cgImage size:NSZeroSize];
	   }
	   else {
           NSString *libError = self.heicFile.lastErrorString;
           if (libError && libError.length > 0) {
               libError = [NSString stringWithFormat:@"(%@)", libError];
           }
		   self.label.stringValue = [NSString stringWithFormat:@"%@ | %ldx%ld | Can not decode image %@",
                                     self.heicFile.path.lastPathComponent, self.heicFile.width, self.heicFile.height, libError];
	   }
	   
   });
}

- (IBAction)showGLWindow:(id)sender
{
    if (! self.wcGL)
        self.wcGL = [[GLWindowController alloc] initWithWindowNibName:@"GLWindow"];
    
    
    [self.wcGL showWindow:nil];
    [self.wcGL.window makeKeyAndOrderFront:nil];
}

- (IBAction)showCGWindow:(id)sender
{
    if (! self.wcCG)
        self.wcCG = [[CGWindowController alloc] initWithWindowNibName:@"CGWindow"];
    
    
    [self.wcCG showWindow:nil];
    [self.wcCG.window makeKeyAndOrderFront:nil];
}


- (IBAction)logFile:(id)sender {
	
	NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
	openPanel.canChooseDirectories = NO;
	openPanel.allowsMultipleSelection = NO;
	
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
	 {
		 if(result == NSFileHandlingPanelOKButton)
		 {
			 self.heicFile = [[oHEIF alloc] initWithFileAtPath:openPanel.URL.path];
			 if (!self.heicFile) {
				 return;
			 }
			 
			 if ([self.heicFile decodePrimaryImageAndLog]) {
				 
			 }
			 else {
				 NSLog(@"Failed to decode %@", self.heicFile.path.lastPathComponent);
			 }
		 }
	 }];
}

- (IBAction)reload:(id)sender {
    [self doOpenFile:self.filepath];
}

@end
