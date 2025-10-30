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

    // Register default preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = @{@"CheckForUpdatesOnLaunch": @YES};
    [defaults registerDefaults:appDefaults];

    // Check for updates on launch if preference is enabled
    // Use a 1-second delay to ensure the app is fully initialized and run loop is running
    BOOL checkOnLaunch = [defaults boolForKey:@"CheckForUpdatesOnLaunch"];
    if (checkOnLaunch) {
        [self performSelector:@selector(performAutomaticUpdateCheck) withObject:nil afterDelay:1.0];
    }
}

- (void)performAutomaticUpdateCheck {
    [self performUpdateCheck:NO]; // NO = automatic/silent mode
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

    // Add "Preferences..." menu item with Command+,
    NSMenuItem *preferencesItem = [[NSMenuItem alloc] initWithTitle:@"Preferences..."
                                                            action:@selector(showPreferences:)
                                                     keyEquivalent:@","];
    [preferencesItem setTarget:self];
    [appMenu addItem:preferencesItem];

    // Add separator
    [appMenu addItem:[NSMenuItem separatorItem]];

    // Add "Quit Extract-XISO" menu item with Command+Q
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit Extract-XISO"
                                                     action:@selector(terminate:)
                                              keyEquivalent:@"q"];
    [quitItem setTarget:[NSApplication sharedApplication]];
    [appMenu addItem:quitItem];

    // Create Help menu
    NSMenu *helpMenu = [[NSMenu alloc] initWithTitle:@"Help"];
    NSMenuItem *helpMenuItem = [[NSMenuItem alloc] init];
    [helpMenuItem setSubmenu:helpMenu];
    [mainMenu addItem:helpMenuItem];

    // Add "Check for Updates..." menu item
    NSMenuItem *updateItem = [[NSMenuItem alloc] initWithTitle:@"Check for Updates..."
                                                       action:@selector(checkForUpdates:)
                                                keyEquivalent:@""];
    [updateItem setTarget:self];
    [helpMenu addItem:updateItem];

    // Set the main menu
    [[NSApplication sharedApplication] setMainMenu:mainMenu];
}

- (IBAction)showAbout:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Extract-XISO GUI"];
    [alert addButtonWithTitle:@"OK"];

    // Create an accessory view with clickable link
    NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 300, 100)];
    [textView setEditable:NO];
    [textView setSelectable:YES];
    [textView setDrawsBackground:NO];

    // Create attributed string with clickable link
    NSMutableAttributedString *aboutText = [[NSMutableAttributedString alloc] initWithString:@"Based on Extract-XISO v2.7.1\n\nA tool for creating, extracting, and listing Xbox ISO files.\n\nOriginal CLI by XboxDev organization\nGUI version by Greg Gant, "];

    // Add the clickable link
    NSAttributedString *link = [[NSAttributedString alloc] initWithString:@"greggant.com"
        attributes:@{
            NSLinkAttributeName: [NSURL URLWithString:@"https://greggant.com"],
            NSForegroundColorAttributeName: [NSColor blueColor],
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
        }];
    [aboutText appendAttributedString:link];

    [[textView textStorage] setAttributedString:aboutText];
    [textView setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [[textView string] length])];

    [alert setAccessoryView:textView];
    [alert runModal];
}

- (IBAction)showPreferences:(id)sender {
    // Create a modal alert-style dialog (simpler and crash-free)
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Preferences"];
    [alert setInformativeText:@""];
    [alert addButtonWithTitle:@"OK"];

    // Create accessory view for the checkbox
    NSView *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 40)];

    // Check for updates on launch checkbox
    NSButton *checkOnLaunchBox = [[NSButton alloc] initWithFrame:NSMakeRect(0, 10, 300, 20)];
    [checkOnLaunchBox setButtonType:NSButtonTypeSwitch];
    [checkOnLaunchBox setTitle:@"Check for updates on launch"];

    // Load current preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL checkOnLaunch = [defaults boolForKey:@"CheckForUpdatesOnLaunch"];
    [checkOnLaunchBox setState:checkOnLaunch ? NSControlStateValueOn : NSControlStateValueOff];

    [accessoryView addSubview:checkOnLaunchBox];
    [alert setAccessoryView:accessoryView];

    // Show modal dialog
    [alert runModal];

    // Save preference after dialog closes
    BOOL isEnabled = ([checkOnLaunchBox state] == NSControlStateValueOn);
    [defaults setBool:isEnabled forKey:@"CheckForUpdatesOnLaunch"];
    [defaults synchronize];
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
    [titleLabel setStringValue:@"Based on Extract-XISO v2.7.1 - GUI Wrapper"];
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

- (IBAction)checkForUpdates:(id)sender {
    // Manual check - always show results
    [self performUpdateCheck:YES];
}

- (void)performUpdateCheck:(BOOL)isManualCheck {
    // Get current version from Info.plist
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    // Create URL for GitHub API
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/repos/fuzzywalrus/extract-xiso-gui/releases/latest"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    // Create a session and data task
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, __unused NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                // Only show error for manual checks
                if (isManualCheck) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Update Check Failed"];
                    [alert setInformativeText:[NSString stringWithFormat:@"Could not check for updates: %@", error.localizedDescription]];
                    [alert addButtonWithTitle:@"OK"];
                    [alert runModal];
                }
                return;
            }

            // Parse JSON response
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

            if (jsonError || !json) {
                // Only show error for manual checks
                if (isManualCheck) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Update Check Failed"];
                    [alert setInformativeText:@"Could not parse update information"];
                    [alert addButtonWithTitle:@"OK"];
                    [alert runModal];
                }
                return;
            }

            NSString *latestVersion = json[@"tag_name"];
            NSString *releaseURL = json[@"html_url"];

            // Remove 'v' prefix if present
            if ([latestVersion hasPrefix:@"v"]) {
                latestVersion = [latestVersion substringFromIndex:1];
            }

            // Compare versions
            NSComparisonResult comparison = [self compareVersion:currentVersion toVersion:latestVersion];

            NSAlert *alert = [[NSAlert alloc] init];
            BOOL shouldShowAlert = isManualCheck; // Always show for manual checks

            if (comparison == NSOrderedAscending) {
                // Current version is older - ALWAYS show this
                shouldShowAlert = YES;
                [alert setMessageText:@"Update Available"];
                [alert setInformativeText:[NSString stringWithFormat:@"A new version (v%@) is available!\n\nYou are currently running v%@.\n\nVisit: %@", latestVersion, currentVersion, releaseURL]];
                [alert addButtonWithTitle:@"OK"];
            } else if (comparison == NSOrderedSame) {
                // Same version - only show for manual checks
                [alert setMessageText:@"Up to Date"];
                [alert setInformativeText:[NSString stringWithFormat:@"You are running the latest version (v%@).", currentVersion]];
                [alert addButtonWithTitle:@"OK"];
            } else {
                // Current version is newer (development build) - only show for manual checks
                [alert setMessageText:@"Development Version"];
                [alert setInformativeText:[NSString stringWithFormat:@"You are running v%@, which is newer than the latest release (v%@).", currentVersion, latestVersion]];
                [alert addButtonWithTitle:@"OK"];
            }

            if (shouldShowAlert) {
                [alert runModal];
            }
        });
    }];

    [task resume];
}

- (NSComparisonResult)compareVersion:(NSString *)version1 toVersion:(NSString *)version2 {
    // Split versions by dots
    NSArray *v1Components = [version1 componentsSeparatedByString:@"."];
    NSArray *v2Components = [version2 componentsSeparatedByString:@"."];

    NSUInteger maxLength = MAX(v1Components.count, v2Components.count);

    for (NSUInteger i = 0; i < maxLength; i++) {
        NSInteger v1Value = (i < v1Components.count) ? [v1Components[i] integerValue] : 0;
        NSInteger v2Value = (i < v2Components.count) ? [v2Components[i] integerValue] : 0;

        if (v1Value < v2Value) {
            return NSOrderedAscending;  // version1 is older
        } else if (v1Value > v2Value) {
            return NSOrderedDescending; // version1 is newer
        }
    }

    return NSOrderedSame; // versions are equal
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

int main(__unused int argc, __unused const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        ExtractXISOGUI *delegate = [[ExtractXISOGUI alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}