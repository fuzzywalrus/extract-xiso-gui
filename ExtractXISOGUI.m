#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface ExtractXISOGUI : NSObject <NSApplicationDelegate>
@property (strong, nonatomic) NSWindow *window;
@property (strong, nonatomic) NSTextField *statusLabel;
@property (strong, nonatomic) NSProgressIndicator *progressIndicator;
@property (strong, nonatomic) NSTextView *outputView;
@end

@implementation ExtractXISOGUI

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupMenu];
    [self setupUI];
}

- (void)setupMenu {
    // Create the main menu bar
    NSMenu *mainMenu = [[NSMenu alloc] init];
    
    // Create the application menu (first menu item)
    NSMenu *appMenu = [[NSMenu alloc] init];
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    [appMenuItem setSubmenu:appMenu];
    [mainMenu addItem:appMenuItem];
    
    // Add "About Extract-XISO" menu item
    NSMenuItem *aboutItem = [[NSMenuItem alloc] initWithTitle:@"About Extract-XISO" 
                                                      action:@selector(showAbout:) 
                                               keyEquivalent:@""];
    [aboutItem setTarget:self];
    [appMenu addItem:aboutItem];
    
    // Add separator
    [appMenu addItem:[NSMenuItem separatorItem]];
    
    // Add "Quit Extract-XISO" menu item with Command+Q
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit Extract-XISO" 
                                                     action:@selector(terminate:) 
                                              keyEquivalent:@"q"];
    [quitItem setTarget:[NSApplication sharedApplication]];
    [appMenu addItem:quitItem];
    
    // Set the main menu
    [[NSApplication sharedApplication] setMainMenu:mainMenu];
}

- (IBAction)showAbout:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Extract-XISO GUI v2.7.1"];
    [alert setInformativeText:@"A native macOS GUI wrapper for extract-xiso.\n\nCreated for easy Xbox ISO extraction and repackaging.\n\nOriginal extract-xiso by *in* <in@fishtank.com>"];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (void)setupUI {
    // Create main window
    self.window = [[NSWindow alloc] 
        initWithContentRect:NSMakeRect(100, 100, 500, 500)
        styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable)
        backing:NSBackingStoreBuffered
        defer:NO];
    
    [self.window setTitle:@"Extract-XISO GUI"];
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    
    // Create content view
    NSView *contentView = [[NSView alloc] initWithFrame:self.window.contentView.frame];
    [self.window setContentView:contentView];
    
    // Title label
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 450, 460, 30)];
    [titleLabel setStringValue:@"Extract-XISO v2.7.1 - GUI Wrapper"];
    [titleLabel setEditable:NO];
    [titleLabel setBordered:NO];
    [titleLabel setBackgroundColor:[NSColor clearColor]];
    [titleLabel setFont:[NSFont boldSystemFontOfSize:16]];
    [titleLabel setAlignment:NSTextAlignmentCenter];
    [contentView addSubview:titleLabel];
    
    // Mode selection
    NSTextField *modeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 410, 100, 20)];
    [modeLabel setStringValue:@"Mode:"];
    [modeLabel setEditable:NO];
    [modeLabel setBordered:NO];
    [modeLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:modeLabel];
    
    NSPopUpButton *modePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(130, 407, 200, 26)];
    [modePopup addItemWithTitle:@"Extract XISO (default)"];
    [modePopup addItemWithTitle:@"Create XISO"];
    [modePopup addItemWithTitle:@"List XISO contents"];
    [modePopup addItemWithTitle:@"Rewrite/Optimize XISO"];
    [contentView addSubview:modePopup];
    
    // File selection
    NSTextField *fileLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 370, 100, 20)];
    [fileLabel setStringValue:@"XISO File:"];
    [fileLabel setEditable:NO];
    [fileLabel setBordered:NO];
    [fileLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:fileLabel];
    
    NSTextField *fileField = [[NSTextField alloc] initWithFrame:NSMakeRect(130, 370, 250, 22)];
    [fileField setPlaceholderString:@"Select XISO file or directory..."];
    [contentView addSubview:fileField];
    
    NSButton *browseButton = [[NSButton alloc] initWithFrame:NSMakeRect(390, 368, 90, 26)];
    [browseButton setTitle:@"Browse..."];
    [browseButton setTarget:self];
    [browseButton setAction:@selector(browseForFile:)];
    [contentView addSubview:browseButton];
    
    // Output directory
    NSTextField *outputLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 330, 100, 20)];
    [outputLabel setStringValue:@"Output Dir:"];
    [outputLabel setEditable:NO];
    [outputLabel setBordered:NO];
    [outputLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:outputLabel];
    
    NSTextField *outputField = [[NSTextField alloc] initWithFrame:NSMakeRect(130, 330, 250, 22)];
    [outputField setPlaceholderString:@"Required: Select output directory..."];
    [contentView addSubview:outputField];
    
    NSButton *outputBrowseButton = [[NSButton alloc] initWithFrame:NSMakeRect(390, 328, 90, 26)];
    [outputBrowseButton setTitle:@"Browse..."];
    [outputBrowseButton setTarget:self];
    [outputBrowseButton setAction:@selector(browseForOutput:)];
    [contentView addSubview:outputBrowseButton];
    
    // Options
    NSTextField *optionsLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 290, 100, 20)];
    [optionsLabel setStringValue:@"Options:"];
    [optionsLabel setEditable:NO];
    [optionsLabel setBordered:NO];
    [optionsLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:optionsLabel];
    
    NSButton *quietCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(130, 290, 120, 20)];
    [quietCheckbox setButtonType:NSButtonTypeSwitch];
    [quietCheckbox setTitle:@"Quiet mode (-q)"];
    [contentView addSubview:quietCheckbox];
    
    NSButton *skipSystemCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(260, 290, 200, 20)];
    [skipSystemCheckbox setButtonType:NSButtonTypeSwitch];
    [skipSystemCheckbox setTitle:@"Skip $SystemUpdate (-s)"];
    [contentView addSubview:skipSystemCheckbox];
    
    // Auto-repackage option (new checkbox)
    NSButton *repackageCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(130, 270, 300, 20)];
    [repackageCheckbox setButtonType:NSButtonTypeSwitch];
    [repackageCheckbox setTitle:@"Auto-repackage extracted files (-c)"];
    [repackageCheckbox setState:NSControlStateValueOn]; // Checked by default
    [contentView addSubview:repackageCheckbox];
    
    // Execute button
    NSButton *executeButton = [[NSButton alloc] initWithFrame:NSMakeRect(200, 240, 100, 30)];
    [executeButton setTitle:@"Execute"];
    [executeButton setTarget:self];
    [executeButton setAction:@selector(executeCommand:)];
    [contentView addSubview:executeButton];
    
    // Progress indicator
    self.progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(20, 180, 460, 20)];
    [self.progressIndicator setStyle:NSProgressIndicatorStyleBar];
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator setHidden:YES];
    [contentView addSubview:self.progressIndicator];
    
    // Status label
    self.statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 150, 460, 20)];
    [self.statusLabel setStringValue:@"Ready"];
    [self.statusLabel setEditable:NO];
    [self.statusLabel setBordered:NO];
    [self.statusLabel setBackgroundColor:[NSColor clearColor]];
    [self.statusLabel setAlignment:NSTextAlignmentCenter];
    [contentView addSubview:self.statusLabel];
    
    // Output text view  
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 20, 460, 120)];
    self.outputView = [[NSTextView alloc] initWithFrame:scrollView.contentView.frame];
    [self.outputView setString:@"Command output will appear here..."];
    [self.outputView setEditable:NO];
    [scrollView setDocumentView:self.outputView];
    [scrollView setHasVerticalScroller:YES];
    [contentView addSubview:scrollView];
}

- (IBAction)browseForFile:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowedFileTypes:@[@"iso", @"xiso"]];
    
    if ([openPanel runModal] == NSModalResponseOK) {
        NSString *filePath = [[openPanel URL] path];
        
        // Find the file field properly instead of using hardcoded index
        NSTextField *fileField = nil;
        for (NSView *subview in [self.window.contentView subviews]) {
            if ([subview isKindOfClass:[NSTextField class]]) {
                NSTextField *field = (NSTextField *)subview;
                NSString *placeholder = [field placeholderString];
                if (placeholder && [placeholder containsString:@"XISO file"]) {
                    fileField = field;
                    break;
                }
            }
        }
        
        if (fileField) {
            [fileField setStringValue:filePath];
        }
    }
}

- (IBAction)browseForOutput:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    
    if ([openPanel runModal] == NSModalResponseOK) {
        NSString *dirPath = [[openPanel URL] path];
        
        // Find the output field properly instead of using hardcoded index
        NSTextField *outputField = nil;
        for (NSView *subview in [self.window.contentView subviews]) {
            if ([subview isKindOfClass:[NSTextField class]]) {
                NSTextField *field = (NSTextField *)subview;
                NSString *placeholder = [field placeholderString];
                if (placeholder && [placeholder containsString:@"output"]) {
                    outputField = field;
                    break;
                }
            }
        }
        
        if (outputField) {
            [outputField setStringValue:dirPath];
        }
    }
}

- (IBAction)executeCommand:(id)sender {
    NSLog(@"Execute command clicked!");
    // Write debug info to file for monitoring
    NSString *debugPath = [@"~/Desktop/extract-xiso-debug.log" stringByExpandingTildeInPath];
    NSString *debugMsg = [NSString stringWithFormat:@"[%@] Execute command clicked!\n", [NSDate date]];
    [debugMsg writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self.statusLabel setStringValue:@"Executing..."];
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:nil];
    
    // Get values from UI - find the right elements more reliably
    NSPopUpButton *modePopup = nil;
    NSTextField *fileField = nil;
    NSTextField *outputField = nil;
    NSButton *quietCheckbox = nil;
    NSButton *skipSystemCheckbox = nil;
    NSButton *repackageCheckbox = nil;
    
    // Search through subviews to find the right controls
    for (NSView *subview in [self.window.contentView subviews]) {
        if ([subview isKindOfClass:[NSPopUpButton class]]) {
            modePopup = (NSPopUpButton *)subview;
        } else if ([subview isKindOfClass:[NSTextField class]]) {
            NSTextField *field = (NSTextField *)subview;
            NSString *placeholder = [field placeholderString];
            if (placeholder && [placeholder containsString:@"XISO file"]) {
                fileField = field;
            } else if (placeholder && [placeholder containsString:@"output"]) {
                outputField = field;
            }
        } else if ([subview isKindOfClass:[NSButton class]]) {
            NSButton *button = (NSButton *)subview;
            NSString *title = [button title];
            if (title && [title containsString:@"Quiet"]) {
                quietCheckbox = button;
            } else if (title && [title containsString:@"SystemUpdate"]) {
                skipSystemCheckbox = button;
            } else if (title && [title containsString:@"Auto-repackage"]) {
                repackageCheckbox = button;
            }
        }
    }
    
    // Add more debug info about found UI elements
    NSString *uiDebugInfo = [NSString stringWithFormat:@"[%@] UI Elements Found - Mode popup: %@, File field: %@, Output field: %@\n", 
                            [NSDate date], modePopup ? @"YES" : @"NO", fileField ? @"YES" : @"NO", outputField ? @"YES" : @"NO"];
    NSString *existingContent = [NSString stringWithContentsOfFile:debugPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
    NSString *newContent = [existingContent stringByAppendingString:uiDebugInfo];
    [newContent writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSString *selectedFile = [fileField stringValue];
    NSString *outputDir = [outputField stringValue];
    NSInteger selectedMode = [modePopup indexOfSelectedItem];
    
    // Debug output field specifically
    NSString *outputDebug = [NSString stringWithFormat:@"[%@] Output field debug - Found: %@, Value: '%@', Length: %lu\n", 
                            [NSDate date], outputField ? @"YES" : @"NO", outputDir ?: @"(nil)", (unsigned long)[outputDir length]];
    NSString *existingContent3 = [NSString stringWithContentsOfFile:debugPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
    NSString *newContent3 = [existingContent3 stringByAppendingString:outputDebug];
    [newContent3 writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"Selected file: '%@'", selectedFile ?: @"(nil)");
    NSLog(@"Output dir: '%@'", outputDir ?: @"(empty)");
    NSLog(@"Selected mode: %ld", (long)selectedMode);
    
    // Debug to file
    NSString *debugInfo = [NSString stringWithFormat:@"[%@] UI Values - File: '%@', Output: '%@', Mode: %ld\n", 
                          [NSDate date], selectedFile ?: @"(nil)", outputDir ?: @"(empty)", (long)selectedMode];
    NSString *existingContent2 = [NSString stringWithContentsOfFile:debugPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
    NSString *newContent2 = [existingContent2 stringByAppendingString:debugInfo];
    [newContent2 writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if (!selectedFile || [selectedFile length] == 0) {
        NSLog(@"No file selected, showing alert");
        [self showAlert:@"Please select a file or directory"];
        [self.progressIndicator stopAnimation:nil];
        [self.progressIndicator setHidden:YES];
        [self.statusLabel setStringValue:@"Ready"];
        return;
    }
    
    // Check if output directory is specified (now required)
    if (!outputDir || [outputDir length] == 0) {
        NSLog(@"No output directory selected, showing alert");
        [self showAlert:@"Please select an output directory"];
        [self.progressIndicator stopAnimation:nil];
        [self.progressIndicator setHidden:YES];
        [self.statusLabel setStringValue:@"Ready"];
        return;
    }
    
    // Build command
    NSMutableArray *arguments = [NSMutableArray array];
    
    // Add mode flag
    switch (selectedMode) {
        case 0: { // Extract (default)
            // Create subdirectory in output folder named after the ISO file (output dir now required)
            NSString *fileName = [[selectedFile lastPathComponent] stringByDeletingPathExtension];
            NSString *extractPath = [outputDir stringByAppendingPathComponent:fileName];
            [arguments addObject:@"-d"];
            [arguments addObject:extractPath];
            break;
        }
        case 1: // Create
            [arguments addObject:@"-c"];
            break;
        case 2: // List
            [arguments addObject:@"-l"];
            break;
        case 3: // Rewrite
            [arguments addObject:@"-r"];
            if ([outputDir length] > 0) {
                [arguments addObject:@"-d"];
                [arguments addObject:outputDir];
            }
            break;
    }
    
    // Add options
    if ([quietCheckbox state] == NSControlStateValueOn) {
        [arguments addObject:@"-q"];
    }
    if ([skipSystemCheckbox state] == NSControlStateValueOn) {
        [arguments addObject:@"-s"];
    }
    
    [arguments addObject:selectedFile];
    
    NSLog(@"Final arguments array: %@", arguments);
    
    // Check if we should auto-repackage after extraction
    BOOL shouldRepackage = (selectedMode == 0) && ([repackageCheckbox state] == NSControlStateValueOn);
    
    // Execute command
    [self executeExtractXISO:arguments withFile:selectedFile outputDir:outputDir shouldRepackage:shouldRepackage];
}

- (void)executeExtractXISO:(NSArray *)arguments withFile:(NSString *)filePath outputDir:(NSString *)outputDir shouldRepackage:(BOOL)shouldRepackage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *executablePath = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // First priority: Bundled in app's Resources folder (for distribution)
        executablePath = [[NSBundle mainBundle] resourcePath];
        executablePath = [executablePath stringByAppendingPathComponent:@"extract-xiso"];
        
        if ([fileManager fileExistsAtPath:executablePath] && [fileManager isExecutableFileAtPath:executablePath]) {
            NSLog(@"Using bundled CLI binary: %@", executablePath);
        } else {
            // Second priority: Build directory (for development)
            executablePath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
            executablePath = [executablePath stringByAppendingPathComponent:@"build/extract-xiso"];
            
            if ([fileManager fileExistsAtPath:executablePath] && [fileManager isExecutableFileAtPath:executablePath]) {
                NSLog(@"Using development CLI binary: %@", executablePath);
            } else {
                // Third priority: Relative path (legacy fallback)
                executablePath = @"./build/extract-xiso";
                
                if ([fileManager fileExistsAtPath:executablePath] && [fileManager isExecutableFileAtPath:executablePath]) {
                    NSLog(@"Using relative CLI binary: %@", executablePath);
                } else {
                    // Fourth priority: System PATH (if installed)
                    executablePath = @"/usr/local/bin/extract-xiso";
                    
                    if ([fileManager fileExistsAtPath:executablePath] && [fileManager isExecutableFileAtPath:executablePath]) {
                        NSLog(@"Using system CLI binary: %@", executablePath);
                    } else {
                        // Error: CLI binary not found anywhere
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.progressIndicator stopAnimation:nil];
                            [self.progressIndicator setHidden:YES];
                            [self.statusLabel setStringValue:@"Error: extract-xiso CLI binary not found"];
                            [self showAlert:@"Cannot find extract-xiso CLI binary. Please rebuild the application."];
                        });
                        return;
                    }
                }
            }
        }
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:executablePath];
        [task setArguments:arguments];
        
        // Set working directory to user's Desktop for file operations
        NSString *desktopPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
        [task setCurrentDirectoryPath:desktopPath];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        [task setStandardError:pipe];
        
        NSFileHandle *file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data = [file readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [task waitUntilExit];
        int status = [task terminationStatus];
        
        // Handle auto-repackaging if extraction was successful
        NSString *finalOutput = output;
        int finalStatus = status;
        
        if (shouldRepackage && status == 0) {
            // Debug repackaging attempt
            NSString *debugPath = [@"~/Desktop/extract-xiso-debug.log" stringByExpandingTildeInPath];
            NSString *repackageDebug = [NSString stringWithFormat:@"[%@] Starting repackaging - shouldRepackage: YES, status: %d\n", [NSDate date], status];
            NSString *existingDebugContent = [NSString stringWithContentsOfFile:debugPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
            NSString *newDebugContent = [existingDebugContent stringByAppendingString:repackageDebug];
            [newDebugContent writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            // Determine the extracted directory path (output dir is now required)
            NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
            NSString *extractedDirPath = [outputDir stringByAppendingPathComponent:fileName];
            
            // Create the output ISO filename with "_repackaged" suffix to avoid overwriting original
            NSString *outputIsoName = [NSString stringWithFormat:@"%@_repackaged.iso", fileName];
            NSString *outputIsoPath = [outputDir stringByAppendingPathComponent:outputIsoName];
            
            // Debug directory path
            NSString *pathDebug = [NSString stringWithFormat:@"[%@] Calculated extracted path: '%@', exists: %@\n", 
                                 [NSDate date], extractedDirPath, [fileManager fileExistsAtPath:extractedDirPath] ? @"YES" : @"NO"];
            NSString *existingDebugContent2 = [NSString stringWithContentsOfFile:debugPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
            NSString *newDebugContent2 = [existingDebugContent2 stringByAppendingString:pathDebug];
            [newDebugContent2 writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            // Run the create command on the extracted directory
            if ([fileManager fileExistsAtPath:extractedDirPath]) {
                // Debug repackaging execution
                NSString *execDebug = [NSString stringWithFormat:@"[%@] Executing repackage: %@ -c '%@' '%@'\n", 
                                     [NSDate date], executablePath, extractedDirPath, outputIsoPath];
                NSString *existingDebugContent3 = [NSString stringWithContentsOfFile:debugPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
                NSString *newDebugContent3 = [existingDebugContent3 stringByAppendingString:execDebug];
                [newDebugContent3 writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                NSTask *repackageTask = [[NSTask alloc] init];
                [repackageTask setLaunchPath:executablePath];
                [repackageTask setArguments:@[@"-c", extractedDirPath, outputIsoPath]];
                [repackageTask setCurrentDirectoryPath:outputDir];
                
                NSPipe *repackagePipe = [NSPipe pipe];
                [repackageTask setStandardOutput:repackagePipe];
                [repackageTask setStandardError:repackagePipe];
                
                NSFileHandle *repackageFile = [repackagePipe fileHandleForReading];
                
                [repackageTask launch];
                
                NSData *repackageData = [repackageFile readDataToEndOfFile];
                NSString *repackageOutput = [[NSString alloc] initWithData:repackageData encoding:NSUTF8StringEncoding];
                
                [repackageTask waitUntilExit];
                int repackageStatus = [repackageTask terminationStatus];
                
                // Combine outputs
                finalOutput = [NSString stringWithFormat:@"%@\n\n--- Auto-Repackaging ---\n%@", output, repackageOutput ?: @"No repackage output"];
                finalStatus = (status == 0 && repackageStatus == 0) ? 0 : MAX(status, repackageStatus);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressIndicator stopAnimation:nil];
            [self.progressIndicator setHidden:YES];
            
            if (finalStatus == 0) {
                if (shouldRepackage && status == 0) {
                    [self.statusLabel setStringValue:@"Extraction and repackaging completed successfully"];
                } else {
                    [self.statusLabel setStringValue:@"Command completed successfully"];
                }
            } else {
                [self.statusLabel setStringValue:[NSString stringWithFormat:@"Command failed with exit code %d", finalStatus]];
            }
            
            // Update output view
            NSLog(@"Command output: %@", finalOutput ?: @"No output");
            [self.outputView setString:finalOutput ?: @"No output"];
            
            // Debug output update to file
            NSString *debugPath = [@"~/Desktop/extract-xiso-debug.log" stringByExpandingTildeInPath];
            NSString *outputDebugInfo = [NSString stringWithFormat:@"[%@] Command completed with status %d. Output length: %lu. Setting output view.\n", 
                                       [NSDate date], finalStatus, (unsigned long)[(finalOutput ?: @"No output") length]];
            NSString *existingContent = [NSString stringWithContentsOfFile:debugPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
            NSString *newContent = [existingContent stringByAppendingString:outputDebugInfo];
            [newContent writeToFile:debugPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        });
    });
}

- (void)showAlert:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        ExtractXISOGUI *delegate = [[ExtractXISOGUI alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}