//
//  AppDelegate.m
//  heic_quicklook_test
//
//  Created by Max Pozdeev on 24/02/2019.
//  Copyright © 2019 Max Pozdeev. All rights reserved.
//

#import "AppDelegate.h"
#import "oHEIF.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label;

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
	
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
		if(result == NSFileHandlingPanelOKButton)
		{
			NSString *fileExt = openPanel.URL.pathExtension.lowercaseString;
			
			if (![fileExt isEqualToString:@"heic"] )
			{
				self.label.stringValue = [NSString stringWithFormat:@"%@: not a HEIC file", openPanel.URL.lastPathComponent];
				return;
			}

			//do work here
			NSString *sSize = [oHEIF stringSizeOfImageAtPath:openPanel.URL.path];
			
			self.label.stringValue = [NSString stringWithFormat:@"%@ image size: %@", openPanel.URL.lastPathComponent, sSize];
		}
	}];
}


@end
