#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface ExtractXISOGUI : NSObject <NSApplicationDelegate>
@property (strong, nonatomic) NSWindow *window;
@property (strong, nonatomic) NSTextField *statusLabel;
@property (strong, nonatomic) NSProgressIndicator *progressIndicator;
@end

@implementation ExtractXISOGUI

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupUI];
}

- (void)setupUI {
    // Create main window
    self.window = [[NSWindow alloc] 
        initWithContentRect:NSMakeRect(100, 100, 500, 400)
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
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 350, 460, 30)];
    [titleLabel setStringValue:@"Extract-XISO v2.7.1 - GUI Wrapper"];
    [titleLabel setEditable:NO];
    [titleLabel setBordered:NO];
    [titleLabel setBackgroundColor:[NSColor clearColor]];
    [titleLabel setFont:[NSFont boldSystemFontOfSize:16]];
    [titleLabel setAlignment:NSTextAlignmentCenter];
    [contentView addSubview:titleLabel];
    
    // Mode selection
    NSTextField *modeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 310, 100, 20)];
    [modeLabel setStringValue:@"Mode:"];
    [modeLabel setEditable:NO];
    [modeLabel setBordered:NO];
    [modeLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:modeLabel];
    
    NSPopUpButton *modePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(130, 307, 200, 26)];
    [modePopup addItemWithTitle:@"Extract XISO (default)"];
    [modePopup addItemWithTitle:@"Create XISO"];
    [modePopup addItemWithTitle:@"List XISO contents"];
    [modePopup addItemWithTitle:@"Rewrite/Optimize XISO"];
    [contentView addSubview:modePopup];
    
    // File selection
    NSTextField *fileLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 270, 100, 20)];
    [fileLabel setStringValue:@"XISO File:"];
    [fileLabel setEditable:NO];
    [fileLabel setBordered:NO];
    [fileLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:fileLabel];
    
    NSTextField *fileField = [[NSTextField alloc] initWithFrame:NSMakeRect(130, 270, 250, 22)];
    [fileField setPlaceholderString:@"Select XISO file or directory..."];
    [contentView addSubview:fileField];
    
    NSButton *browseButton = [[NSButton alloc] initWithFrame:NSMakeRect(390, 268, 90, 26)];
    [browseButton setTitle:@"Browse..."];
    [browseButton setTarget:self];
    [browseButton setAction:@selector(browseForFile:)];
    [contentView addSubview:browseButton];
    
    // Output directory
    NSTextField *outputLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 230, 100, 20)];
    [outputLabel setStringValue:@"Output Dir:"];
    [outputLabel setEditable:NO];
    [outputLabel setBordered:NO];
    [outputLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:outputLabel];
    
    NSTextField *outputField = [[NSTextField alloc] initWithFrame:NSMakeRect(130, 230, 250, 22)];
    [outputField setPlaceholderString:@"Optional output directory..."];
    [contentView addSubview:outputField];
    
    NSButton *outputBrowseButton = [[NSButton alloc] initWithFrame:NSMakeRect(390, 228, 90, 26)];
    [outputBrowseButton setTitle:@"Browse..."];
    [outputBrowseButton setTarget:self];
    [outputBrowseButton setAction:@selector(browseForOutput:)];
    [contentView addSubview:outputBrowseButton];
    
    // Options
    NSTextField *optionsLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 190, 100, 20)];
    [optionsLabel setStringValue:@"Options:"];
    [optionsLabel setEditable:NO];
    [optionsLabel setBordered:NO];
    [optionsLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:optionsLabel];
    
    NSButton *quietCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(130, 190, 120, 20)];
    [quietCheckbox setButtonType:NSButtonTypeSwitch];
    [quietCheckbox setTitle:@"Quiet mode (-q)"];
    [contentView addSubview:quietCheckbox];
    
    NSButton *skipSystemCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(260, 190, 200, 20)];
    [skipSystemCheckbox setButtonType:NSButtonTypeSwitch];
    [skipSystemCheckbox setTitle:@"Skip $SystemUpdate (-s)"];
    [contentView addSubview:skipSystemCheckbox];
    
    // Execute button
    NSButton *executeButton = [[NSButton alloc] initWithFrame:NSMakeRect(200, 140, 100, 30)];
    [executeButton setTitle:@"Execute"];
    [executeButton setTarget:self];
    [executeButton setAction:@selector(executeCommand:)];
    [contentView addSubview:executeButton];
    
    // Progress indicator
    self.progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(20, 100, 460, 20)];
    [self.progressIndicator setStyle:NSProgressIndicatorStyleBar];
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator setHidden:YES];
    [contentView addSubview:self.progressIndicator];
    
    // Status label
    self.statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 70, 460, 20)];
    [self.statusLabel setStringValue:@"Ready"];
    [self.statusLabel setEditable:NO];
    [self.statusLabel setBordered:NO];
    [self.statusLabel setBackgroundColor:[NSColor clearColor]];
    [self.statusLabel setAlignment:NSTextAlignmentCenter];
    [contentView addSubview:self.statusLabel];
    
    // Output text view
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 20, 460, 40)];
    NSTextView *outputView = [[NSTextView alloc] initWithFrame:scrollView.contentView.frame];
    [outputView setString:@"Command output will appear here..."];
    [outputView setEditable:NO];
    [scrollView setDocumentView:outputView];
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
        NSTextField *fileField = [self.window.contentView subviews][4];
        [fileField setStringValue:filePath];
    }
}

- (IBAction)browseForOutput:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    
    if ([openPanel runModal] == NSModalResponseOK) {
        NSString *dirPath = [[openPanel URL] path];
        NSTextField *outputField = [self.window.contentView subviews][6];
        [outputField setStringValue:dirPath];
    }
}

- (IBAction)executeCommand:(id)sender {
    [self.statusLabel setStringValue:@"Executing..."];
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:nil];
    
    // Get values from UI
    NSPopUpButton *modePopup = [self.window.contentView subviews][2];
    NSTextField *fileField = [self.window.contentView subviews][4];
    NSTextField *outputField = [self.window.contentView subviews][6];
    NSButton *quietCheckbox = [self.window.contentView subviews][8];
    NSButton *skipSystemCheckbox = [self.window.contentView subviews][9];
    
    NSString *selectedFile = [fileField stringValue];
    NSString *outputDir = [outputField stringValue];
    NSInteger selectedMode = [modePopup indexOfSelectedItem];
    
    if ([selectedFile length] == 0) {
        [self showAlert:@"Please select a file or directory"];
        [self.progressIndicator stopAnimation:nil];
        [self.progressIndicator setHidden:YES];
        [self.statusLabel setStringValue:@"Ready"];
        return;
    }
    
    // Build command
    NSMutableArray *arguments = [NSMutableArray array];
    
    // Add mode flag
    switch (selectedMode) {
        case 0: // Extract (default)
            if ([outputDir length] > 0) {
                [arguments addObject:@"-d"];
                [arguments addObject:outputDir];
            }
            break;
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
    
    // Execute command
    [self executeExtractXISO:arguments];
}

- (void)executeExtractXISO:(NSArray *)arguments {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *executablePath = [[NSBundle mainBundle] resourcePath];
        executablePath = [executablePath stringByAppendingPathComponent:@"extract-xiso"];
        
        // Fallback to build directory if not bundled
        if (![[NSFileManager defaultManager] fileExistsAtPath:executablePath]) {
            executablePath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
            executablePath = [executablePath stringByAppendingPathComponent:@"build/extract-xiso"];
        }
        
        // Final fallback for development
        if (![[NSFileManager defaultManager] fileExistsAtPath:executablePath]) {
            executablePath = @"./build/extract-xiso";
        }
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:executablePath];
        [task setArguments:arguments];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        [task setStandardError:pipe];
        
        NSFileHandle *file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data = [file readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [task waitUntilExit];
        int status = [task terminationStatus];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressIndicator stopAnimation:nil];
            [self.progressIndicator setHidden:YES];
            
            if (status == 0) {
                [self.statusLabel setStringValue:@"Command completed successfully"];
            } else {
                [self.statusLabel setStringValue:[NSString stringWithFormat:@"Command failed with exit code %d", status]];
            }
            
            // Update output view
            NSScrollView *scrollView = [self.window.contentView subviews][12];
            NSTextView *outputView = (NSTextView *)[scrollView documentView];
            [outputView setString:output ?: @"No output"];
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