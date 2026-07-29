#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

// Info glyph that explains one option. The built-in NSView toolTip proved
// unreliable here, so the hover behaviour is driven explicitly by a tracking
// area and an NSPopover. Clicking toggles the same popover, which gives a
// non-hover path for anyone who never rests the pointer long enough.
//
// Subclasses NSImageView deliberately: the control lookup in executeCommand:
// matches only NSButton / NSTextField / NSPopUpButton, so this stays inert there.
@interface InfoIconView : NSImageView
@property (copy, nonatomic) NSString *helpText;
@property (strong, nonatomic) NSPopover *helpPopover;
- (void)hideHelp;
@end

@implementation InfoIconView

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    for (NSTrackingArea *existing in [self trackingAreas]) {
        [self removeTrackingArea:existing];
    }
    // InVisibleRect keeps the area correct across the window resize that
    // expanding and collapsing the options list performs
    NSTrackingArea *area = [[NSTrackingArea alloc]
        initWithRect:NSZeroRect
             options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp |
                      NSTrackingInVisibleRect)
               owner:self
            userInfo:nil];
    [self addTrackingArea:area];
}

- (void)showHelp {
    if ([self.helpText length] == 0 || [self.helpPopover isShown]) { return; }

    const CGFloat textWidth = 260, padding = 12;
    NSFont *font = [NSFont systemFontOfSize:11];
    NSRect measured = [self.helpText
        boundingRectWithSize:NSMakeSize(textWidth, 10000)
                     options:NSStringDrawingUsesLineFragmentOrigin
                  attributes:@{NSFontAttributeName: font}];
    CGFloat textHeight = ceil(NSHeight(measured));

    NSTextField *label = [[NSTextField alloc]
        initWithFrame:NSMakeRect(padding, padding, textWidth, textHeight)];
    [label setStringValue:self.helpText];
    [label setFont:font];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setBordered:NO];
    [label setDrawsBackground:NO];
    [label setTextColor:[NSColor labelColor]];
    [[label cell] setWraps:YES];

    NSView *content = [[NSView alloc]
        initWithFrame:NSMakeRect(0, 0, textWidth + padding * 2, textHeight + padding * 2)];
    [content addSubview:label];

    NSViewController *controller = [[NSViewController alloc] init];
    [controller setView:content];

    self.helpPopover = [[NSPopover alloc] init];
    [self.helpPopover setContentViewController:controller];
    [self.helpPopover setContentSize:content.frame.size];
    [self.helpPopover setBehavior:NSPopoverBehaviorApplicationDefined];
    [self.helpPopover setAnimates:NO];
    [self.helpPopover showRelativeToRect:[self bounds]
                                  ofView:self
                           preferredEdge:NSRectEdgeMaxX];
}

- (void)hideHelp {
    [self.helpPopover close];
    self.helpPopover = nil;
}

- (void)mouseEntered:(NSEvent *)event { [self showHelp]; }
- (void)mouseExited:(NSEvent *)event { [self hideHelp]; }

- (void)mouseDown:(NSEvent *)event {
    if ([self.helpPopover isShown]) {
        [self hideHelp];
    } else {
        [self showHelp];
    }
}

@end

@interface ExtractXISOGUI : NSObject <NSApplicationDelegate>
@property (strong, nonatomic) NSWindow *window;
@property (strong, nonatomic) NSTextField *statusLabel;
@property (strong, nonatomic) NSProgressIndicator *progressIndicator;
@property (strong, nonatomic) NSTextView *outputView;
@property (strong, nonatomic) NSButton *executeButton;
// Collapsible options section
@property (strong, nonatomic) NSButton *optionsDisclosureButton;
@property (strong, nonatomic) NSTextField *optionsSummaryLabel;
@property (strong, nonatomic) NSArray<NSView *> *optionRowViews;    // hidden when collapsed
@property (strong, nonatomic) NSArray<NSView *> *viewsAboveOptions; // shifted when collapsing
@property (assign, nonatomic) BOOL optionsExpanded; // what the user asked for
@property (assign, nonatomic) BOOL layoutExpanded;  // what the frames currently reflect
@end

// Vertical space the option rows occupy. Collapsing removes exactly this much
// from the window and slides everything above the disclosure row down to match.
static const CGFloat kOptionsBlockHeight = 104;

static NSString * const kOptionsExpandedKey = @"OptionsExpanded";

@implementation ExtractXISOGUI

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Registered before setupUI so the window can be built at the persisted size
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = @{@"CheckForUpdatesOnLaunch": @YES,
                                  kOptionsExpandedKey: @NO};
    [defaults registerDefaults:appDefaults];

    [self setupMenu];
    [self setupUI];

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


// Static (non-editable) text. Kept free of a placeholderString so it is ignored
// by the control lookup in executeCommand:, which matches text fields on theirs.
- (NSTextField *)labelWithText:(NSString *)text
                         frame:(NSRect)frame
                     alignment:(NSTextAlignment)alignment
                          font:(NSFont *)font
                         color:(NSColor *)color {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    [label setStringValue:text];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setBordered:NO];
    [label setDrawsBackground:NO];
    [label setAlignment:alignment];
    [label setFont:font];
    [label setTextColor:color];
    return label;
}

// Small info glyph parked at the right edge of an option row. NSImageView is
// none of the three classes the control lookup matches on, so it is inert there.
- (InfoIconView *)infoIconWithTooltip:(NSString *)tooltip atY:(CGFloat)y {
    InfoIconView *icon = [[InfoIconView alloc] initWithFrame:NSMakeRect(514, y, 18, 18)];
    NSImage *glyph = [NSImage imageWithSystemSymbolName:@"info.circle"
                                accessibilityDescription:tooltip];
    if (glyph) {
        [icon setImage:glyph];
        [icon setContentTintColor:[NSColor secondaryLabelColor]];
    }
    // Help comes from the popover, not the system tooltip, so the two cannot
    // both appear on the same hover
    [icon setHelpText:tooltip];
    [icon setAccessibilityLabel:tooltip];
    [icon setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    return icon;
}

- (void)setupUI {
    // Layout grid. Origin is bottom-left, so rows are listed top-down by
    // descending y. Window is 560x560 with 24pt margins; labels occupy
    // x 24-120 (right-aligned) and controls start at x 132.
    // Frames below describe the EXPANDED layout; collapsing is handled by
    // applyOptionsExpanded:, which shifts the upper block down by
    // kOptionsBlockHeight and shrinks the window to match.
    const CGFloat windowWidth = 560;
    const CGFloat windowHeight = 616;
    const CGFloat margin = 24;
    const CGFloat labelX = 24, labelWidth = 96;
    const CGFloat controlX = 132;
    const CGFloat fullWidth = windowWidth - (margin * 2);

    self.window = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(100, 100, windowWidth, windowHeight)
        styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                   NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
        backing:NSBackingStoreBuffered
        defer:NO];

    [self.window setTitle:@"Extract-XISO GUI"];

    NSView *contentView = [[NSView alloc] initWithFrame:self.window.contentView.frame];
    [self.window setContentView:contentView];

    // --- Header -----------------------------------------------------------
    NSTextField *titleLabel = [self labelWithText:@"Extract-XISO"
                                            frame:NSMakeRect(margin, 570, fullWidth, 22)
                                        alignment:NSTextAlignmentCenter
                                             font:[NSFont boldSystemFontOfSize:15]
                                            color:[NSColor labelColor]];
    [titleLabel setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [contentView addSubview:titleLabel];

    NSTextField *subtitleLabel = [self labelWithText:@"GUI wrapper for extract-xiso v2.7.1"
                                               frame:NSMakeRect(margin, 552, fullWidth, 16)
                                           alignment:NSTextAlignmentCenter
                                                font:[NSFont systemFontOfSize:11]
                                               color:[NSColor secondaryLabelColor]];
    [subtitleLabel setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [contentView addSubview:subtitleLabel];

    // NSBox is neither NSButton/NSTextField/NSPopUpButton, so the control
    // lookup in executeCommand: skips it
    NSBox *headerRule = [[NSBox alloc] initWithFrame:NSMakeRect(margin, 538, fullWidth, 1)];
    [headerRule setBoxType:NSBoxSeparator];
    [headerRule setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [contentView addSubview:headerRule];

    // --- Mode -------------------------------------------------------------
    NSTextField *modeLabel = [self labelWithText:@"Mode:"
                                           frame:NSMakeRect(labelX, 504, labelWidth, 17)
                                       alignment:NSTextAlignmentRight
                                            font:[NSFont systemFontOfSize:13]
                                           color:[NSColor labelColor]];
    [modeLabel setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:modeLabel];

    NSPopUpButton *modePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(controlX, 500, 220, 25)];
    [modePopup addItemWithTitle:@"Extract XISO (default)"];
    [modePopup addItemWithTitle:@"Create XISO"];
    [modePopup addItemWithTitle:@"List XISO contents"];
    [modePopup addItemWithTitle:@"Rewrite/Optimize XISO"];
    [modePopup setToolTip:@"Extract unpacks an ISO, Create builds one from a folder, "
                          @"List shows contents, Rewrite optimizes an existing ISO."];
    [modePopup setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:modePopup];

    // --- Input file -------------------------------------------------------
    NSTextField *fileLabel = [self labelWithText:@"XISO File:"
                                           frame:NSMakeRect(labelX, 466, labelWidth, 17)
                                       alignment:NSTextAlignmentRight
                                            font:[NSFont systemFontOfSize:13]
                                           color:[NSColor labelColor]];
    [fileLabel setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:fileLabel];

    // Placeholder must keep the substring "XISO file" - executeCommand: finds
    // this field by matching on it
    NSTextField *fileField = [[NSTextField alloc] initWithFrame:NSMakeRect(controlX, 462, 300, 24)];
    [fileField setPlaceholderString:@"Select XISO file or directory..."];
    [fileField setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [contentView addSubview:fileField];

    NSButton *browseButton = [[NSButton alloc] initWithFrame:NSMakeRect(444, 461, 92, 26)];
    [browseButton setTitle:@"Browse..."];
    [browseButton setBezelStyle:NSBezelStyleRounded];
    [browseButton setTarget:self];
    [browseButton setAction:@selector(browseForFile:)];
    [browseButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [contentView addSubview:browseButton];

    // --- Output directory -------------------------------------------------
    NSTextField *outputLabel = [self labelWithText:@"Output Dir:"
                                             frame:NSMakeRect(labelX, 428, labelWidth, 17)
                                         alignment:NSTextAlignmentRight
                                              font:[NSFont systemFontOfSize:13]
                                             color:[NSColor labelColor]];
    [outputLabel setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:outputLabel];

    // Placeholder must keep the substring "output" - see executeCommand:
    NSTextField *outputField = [[NSTextField alloc] initWithFrame:NSMakeRect(controlX, 424, 300, 24)];
    [outputField setPlaceholderString:@"Required: Select output directory..."];
    [outputField setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [contentView addSubview:outputField];

    NSButton *outputBrowseButton = [[NSButton alloc] initWithFrame:NSMakeRect(444, 423, 92, 26)];
    [outputBrowseButton setTitle:@"Browse..."];
    [outputBrowseButton setBezelStyle:NSBezelStyleRounded];
    [outputBrowseButton setTarget:self];
    [outputBrowseButton setAction:@selector(browseForOutput:)];
    [outputBrowseButton setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    [contentView addSubview:outputBrowseButton];

    // --- Options (collapsible) --------------------------------------------
    // Disclosure row. Stays visible in both states; only the rows beneath it
    // are hidden when collapsed.
    NSTextField *optionsLabel = [self labelWithText:@"Options:"
                                              frame:NSMakeRect(labelX, 384, labelWidth, 17)
                                          alignment:NSTextAlignmentRight
                                               font:[NSFont systemFontOfSize:13]
                                              color:[NSColor labelColor]];
    [optionsLabel setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:optionsLabel];

    // Empty title, so the control lookup in executeCommand: cannot mistake it
    // for one of the option checkboxes
    self.optionsDisclosureButton = [[NSButton alloc] initWithFrame:NSMakeRect(controlX, 382, 18, 18)];
    [self.optionsDisclosureButton setButtonType:NSButtonTypePushOnPushOff];
    [self.optionsDisclosureButton setBezelStyle:NSBezelStyleDisclosure];
    [self.optionsDisclosureButton setTitle:@""];
    [self.optionsDisclosureButton setToolTip:@"Show or hide the extraction options."];
    [self.optionsDisclosureButton setTarget:self];
    [self.optionsDisclosureButton setAction:@selector(toggleOptions:)];
    [self.optionsDisclosureButton setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:self.optionsDisclosureButton];

    // Summarises what is switched on while the rows are hidden, so enabled
    // options (including the destructive one) are never invisible
    self.optionsSummaryLabel = [self labelWithText:@""
                                             frame:NSMakeRect(controlX + 24, 384, 388, 17)
                                         alignment:NSTextAlignmentLeft
                                              font:[NSFont systemFontOfSize:11]
                                             color:[NSColor secondaryLabelColor]];
    [[self.optionsSummaryLabel cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.optionsSummaryLabel setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [contentView addSubview:self.optionsSummaryLabel];

    // One option per row, each with an info icon on the right whose tooltip
    // explains it. 28pt row pitch; see kOptionsBlockHeight.
    NSString *quietHelp = @"Suppresses the CLI's per-file progress lines. The final summary "
                          @"still appears in the output area below.";
    NSString *skipSystemHelp = @"Leaves the $SystemUpdate folder out of the extraction. It holds "
                               @"the Xbox dashboard updater rather than game data.";
    NSString *repackageHelp = @"After extracting, rebuilds the files into a decrypted "
                              @"<name>_repackaged.iso in the output directory. The original ISO "
                              @"is left untouched.";
    NSString *cleanupHelp = @"Moves the extracted folder to the Trash once the repackaged ISO is "
                            @"verified, reclaiming several GB of scratch space. Skipped if "
                            @"repackaging fails. The original ISO is never deleted.";

    NSButton *quietCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(controlX, 356, 370, 20)];
    [quietCheckbox setButtonType:NSButtonTypeSwitch];
    [quietCheckbox setTitle:@"Quiet mode (-q)"];
    [quietCheckbox setToolTip:quietHelp];
    [quietCheckbox setTarget:self];
    [quietCheckbox setAction:@selector(optionCheckboxChanged:)];
    [quietCheckbox setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:quietCheckbox];
    InfoIconView *quietInfo = [self infoIconWithTooltip:quietHelp atY:357];
    [contentView addSubview:quietInfo];

    NSButton *skipSystemCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(controlX, 328, 370, 20)];
    [skipSystemCheckbox setButtonType:NSButtonTypeSwitch];
    [skipSystemCheckbox setTitle:@"Skip $SystemUpdate (-s)"];
    [skipSystemCheckbox setToolTip:skipSystemHelp];
    [skipSystemCheckbox setTarget:self];
    [skipSystemCheckbox setAction:@selector(optionCheckboxChanged:)];
    [skipSystemCheckbox setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:skipSystemCheckbox];
    InfoIconView *skipSystemInfo = [self infoIconWithTooltip:skipSystemHelp atY:329];
    [contentView addSubview:skipSystemInfo];

    NSButton *repackageCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(controlX, 300, 370, 20)];
    [repackageCheckbox setButtonType:NSButtonTypeSwitch];
    [repackageCheckbox setTitle:@"Auto-repackage extracted files (-c)"];
    [repackageCheckbox setState:NSControlStateValueOn]; // Checked by default
    [repackageCheckbox setToolTip:repackageHelp];
    [repackageCheckbox setTarget:self];
    [repackageCheckbox setAction:@selector(optionCheckboxChanged:)];
    [repackageCheckbox setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:repackageCheckbox];
    InfoIconView *repackageInfo = [self infoIconWithTooltip:repackageHelp atY:301];
    [contentView addSubview:repackageInfo];

    // Sub-option of auto-repackage, so indented one step under it
    NSButton *cleanupCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(controlX + 20, 272, 350, 20)];
    [cleanupCheckbox setButtonType:NSButtonTypeSwitch];
    [cleanupCheckbox setTitle:@"Delete extracted files after repackaging"];
    [cleanupCheckbox setState:NSControlStateValueOn]; // Checked by default
    [cleanupCheckbox setToolTip:cleanupHelp];
    [cleanupCheckbox setTarget:self];
    [cleanupCheckbox setAction:@selector(optionCheckboxChanged:)];
    [cleanupCheckbox setAutoresizingMask:NSViewMinYMargin];
    [contentView addSubview:cleanupCheckbox];
    InfoIconView *cleanupInfo = [self infoIconWithTooltip:cleanupHelp atY:273];
    [contentView addSubview:cleanupInfo];

    self.optionRowViews = @[quietCheckbox, quietInfo,
                            skipSystemCheckbox, skipSystemInfo,
                            repackageCheckbox, repackageInfo,
                            cleanupCheckbox, cleanupInfo];
    self.viewsAboveOptions = @[titleLabel, subtitleLabel, headerRule,
                               modeLabel, modePopup,
                               fileLabel, fileField, browseButton,
                               outputLabel, outputField, outputBrowseButton,
                               optionsLabel, self.optionsDisclosureButton, self.optionsSummaryLabel];

    // --- Execute ----------------------------------------------------------
    self.executeButton = [[NSButton alloc] initWithFrame:NSMakeRect((windowWidth - 120) / 2, 228, 120, 32)];
    [self.executeButton setTitle:@"Execute"];
    [self.executeButton setBezelStyle:NSBezelStyleRounded];
    [self.executeButton setKeyEquivalent:@"\r"]; // default button - picks up the accent colour
    [self.executeButton setTarget:self];
    [self.executeButton setAction:@selector(executeCommand:)];
    [self.executeButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin];
    [contentView addSubview:self.executeButton];

    // --- Progress and status ----------------------------------------------
    self.progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(margin, 198, fullWidth, 20)];
    [self.progressIndicator setStyle:NSProgressIndicatorStyleBar];
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator setHidden:YES];
    [self.progressIndicator setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [contentView addSubview:self.progressIndicator];

    self.statusLabel = [self labelWithText:@"Ready"
                                     frame:NSMakeRect(margin, 174, fullWidth, 17)
                                 alignment:NSTextAlignmentCenter
                                      font:[NSFont systemFontOfSize:12]
                                     color:[NSColor secondaryLabelColor]];
    [self.statusLabel setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [contentView addSubview:self.statusLabel];

    // --- Output -----------------------------------------------------------
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(margin, margin, fullWidth, 138)];
    [scrollView setBorderType:NSBezelBorder];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutohidesScrollers:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    self.outputView = [[NSTextView alloc] initWithFrame:scrollView.contentView.bounds];
    [self.outputView setString:@"Command output will appear here..."];
    [self.outputView setEditable:NO];
    [self.outputView setRichText:NO];
    // CLI output is column-aligned, so it wants a fixed-pitch face
    [self.outputView setFont:[NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular]];
    [self.outputView setTextColor:[NSColor labelColor]];
    [self.outputView setTextContainerInset:NSMakeSize(4, 6)];
    [self.outputView setAutoresizingMask:NSViewWidthSizable];
    [[self.outputView textContainer] setWidthTracksTextView:YES];
    [scrollView setDocumentView:self.outputView];
    [contentView addSubview:scrollView];

    // Cleanup only applies when repackaging, so mirror the repackage state
    [self syncCleanupCheckboxEnabledState];

    // Restore the persisted disclosure state before centring, so the window is
    // centred at the size it will actually be shown at
    [self.window setContentMinSize:NSMakeSize(windowWidth, windowHeight)];
    self.layoutExpanded = YES; // frames above are the expanded layout
    BOOL expanded = [[NSUserDefaults standardUserDefaults] boolForKey:kOptionsExpandedKey];
    [self applyOptionsExpanded:expanded];
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
}

#pragma mark - Collapsible options

- (IBAction)toggleOptions:(id)sender {
    [self applyOptionsExpanded:!self.optionsExpanded];
    [[NSUserDefaults standardUserDefaults] setBool:self.optionsExpanded forKey:kOptionsExpandedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applyOptionsExpanded:(BOOL)expanded {
    self.optionsExpanded = expanded;

    [self.optionsDisclosureButton setState:expanded ? NSControlStateValueOn : NSControlStateValueOff];
    for (NSView *view in self.optionRowViews) {
        // A popover left open over a row being hidden would float unanchored
        if ([view isKindOfClass:[InfoIconView class]]) {
            [(InfoIconView *)view hideHelp];
        }
        [view setHidden:!expanded];
    }
    // The summary only earns its place while the rows are hidden
    [self.optionsSummaryLabel setHidden:expanded];
    [self updateOptionsSummary];

    // Frames as authored in setupUI are the expanded layout, so layoutExpanded
    // starts YES and the geometry below runs only on an actual change
    if (self.layoutExpanded == expanded) { return; }
    self.layoutExpanded = expanded;

    CGFloat delta = expanded ? kOptionsBlockHeight : -kOptionsBlockHeight;
    NSView *contentView = self.window.contentView;

    // Drive the geometry by hand: the autoresizing masks pin these views to the
    // top of the window, which is right for a user-driven resize but would make
    // collapsing steal height from the output view instead of compacting the
    // dialog.
    [contentView setAutoresizesSubviews:NO];

    NSRect frame = [self.window frame];
    frame.size.height += delta;
    frame.origin.y -= delta; // keep the title bar where it is
    [self.window setFrame:frame display:YES];

    // Everything from the disclosure row up moves with the top edge; the
    // execute button and output area keep their distance from the bottom.
    for (NSView *view in self.viewsAboveOptions) {
        NSRect viewFrame = [view frame];
        viewFrame.origin.y += delta;
        [view setFrame:viewFrame];
    }

    [contentView setAutoresizesSubviews:YES];

    NSSize minSize = [self.window contentMinSize];
    minSize.height += delta;
    [self.window setContentMinSize:minSize];
}

// Lists the enabled options next to the collapsed disclosure triangle. Without
// this, switched-on options - including the destructive cleanup - would be
// completely invisible in the default collapsed state.
- (void)updateOptionsSummary {
    NSButton *quietCheckbox = nil, *skipSystemCheckbox = nil;
    NSButton *repackageCheckbox = nil, *cleanupCheckbox = nil;

    for (NSView *subview in [self.window.contentView subviews]) {
        if (![subview isKindOfClass:[NSButton class]]) { continue; }
        NSButton *button = (NSButton *)subview;
        NSString *title = [button title];
        if (title && [title containsString:@"Quiet"]) {
            quietCheckbox = button;
        } else if (title && [title containsString:@"SystemUpdate"]) {
            skipSystemCheckbox = button;
        } else if (title && [title containsString:@"Auto-repackage"]) {
            repackageCheckbox = button;
        } else if (title && [title containsString:@"Delete extracted"]) {
            cleanupCheckbox = button;
        }
    }

    NSMutableArray *enabled = [NSMutableArray array];
    if ([quietCheckbox state] == NSControlStateValueOn) {
        [enabled addObject:@"quiet"];
    }
    if ([skipSystemCheckbox state] == NSControlStateValueOn) {
        [enabled addObject:@"skip $SystemUpdate"];
    }
    if ([repackageCheckbox state] == NSControlStateValueOn) {
        [enabled addObject:@"auto-repackage"];
        if ([cleanupCheckbox state] == NSControlStateValueOn) {
            [enabled addObject:@"delete extracted files"];
        }
    }

    NSString *summary = [enabled count] > 0
        ? [enabled componentsJoinedByString:@", "]
        : @"none enabled";
    [self.optionsSummaryLabel setStringValue:summary];
    [self.optionsSummaryLabel setToolTip:summary];
}

- (IBAction)optionCheckboxChanged:(id)sender {
    [self syncCleanupCheckboxEnabledState];
    [self updateOptionsSummary];
}

// Cleanup is a sub-option of auto-repackage - grey it out when repackaging is off
- (void)syncCleanupCheckboxEnabledState {
    NSButton *repackageCheckbox = nil;
    NSButton *cleanupCheckbox = nil;

    for (NSView *subview in [self.window.contentView subviews]) {
        if ([subview isKindOfClass:[NSButton class]]) {
            NSButton *button = (NSButton *)subview;
            NSString *title = [button title];
            if (title && [title containsString:@"Auto-repackage"]) {
                repackageCheckbox = button;
            } else if (title && [title containsString:@"Delete extracted"]) {
                cleanupCheckbox = button;
            }
        }
    }

    if (cleanupCheckbox) {
        [cleanupCheckbox setEnabled:([repackageCheckbox state] == NSControlStateValueOn)];
    }
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
    [self.statusLabel setStringValue:@"Executing..."];
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:nil];
    // Prevent a second click from spawning a concurrent task over the same paths
    [self.executeButton setEnabled:NO];

    // Get values from UI - find the right elements more reliably
    NSPopUpButton *modePopup = nil;
    NSTextField *fileField = nil;
    NSTextField *outputField = nil;
    NSButton *quietCheckbox = nil;
    NSButton *skipSystemCheckbox = nil;
    NSButton *repackageCheckbox = nil;
    NSButton *cleanupCheckbox = nil;

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
            } else if (title && [title containsString:@"Delete extracted"]) {
                cleanupCheckbox = button;
            }
        }
    }

    NSString *selectedFile = [fileField stringValue];
    NSString *outputDir = [outputField stringValue];
    NSInteger selectedMode = [modePopup indexOfSelectedItem];
    
    if (!selectedFile || [selectedFile length] == 0) {
        NSLog(@"No file selected, showing alert");
        [self showAlert:@"Please select a file or directory"];
        [self.progressIndicator stopAnimation:nil];
        [self.progressIndicator setHidden:YES];
        [self.statusLabel setStringValue:@"Ready"];
        [self.executeButton setEnabled:YES];
        return;
    }
    
    // Check if output directory is specified (now required)
    if (!outputDir || [outputDir length] == 0) {
        NSLog(@"No output directory selected, showing alert");
        [self showAlert:@"Please select an output directory"];
        [self.progressIndicator stopAnimation:nil];
        [self.progressIndicator setHidden:YES];
        [self.statusLabel setStringValue:@"Ready"];
        [self.executeButton setEnabled:YES];
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
        case 1: { // Create
            [arguments addObject:@"-c"];
            // extract-xiso -c <dir> [name] — pass output dir + filename as the [name] param
            // The input file (selectedFile) is actually a directory for create mode
            // We'll add selectedFile here, then the output ISO path
            // Note: arguments are built as: -c <dir> [name], so we add dir then output path
            NSString *dirName = [[selectedFile lastPathComponent] stringByDeletingPathExtension];
            if ([dirName length] == 0) {
                dirName = [selectedFile lastPathComponent];
            }
            NSString *outputIsoPath = [outputDir stringByAppendingPathComponent:
                                       [dirName stringByAppendingString:@".iso"]];
            [arguments addObject:selectedFile];
            [arguments addObject:outputIsoPath];
            // Skip adding selectedFile again at the end
            selectedFile = nil;
            break;
        }
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
    
    if (selectedFile) {
        [arguments addObject:selectedFile];
    }

    NSLog(@"Final arguments array: %@", arguments);
    
    // Check if we should auto-repackage after extraction
    BOOL shouldRepackage = (selectedMode == 0) && ([repackageCheckbox state] == NSControlStateValueOn);
    // Cleanup is a sub-option of repackaging - never runs on its own
    BOOL shouldCleanup = shouldRepackage && ([cleanupCheckbox state] == NSControlStateValueOn);

    // Execute command
    [self executeExtractXISO:arguments
                    withFile:selectedFile
                   outputDir:outputDir
             shouldRepackage:shouldRepackage
       cleanupAfterRepackage:shouldCleanup];
}

- (void)executeExtractXISO:(NSArray *)arguments withFile:(NSString *)filePath outputDir:(NSString *)outputDir shouldRepackage:(BOOL)shouldRepackage cleanupAfterRepackage:(BOOL)shouldCleanup {
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
                            [self.executeButton setEnabled:YES];
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
        
        // Set working directory to output directory (or home as fallback)
        if (outputDir && [outputDir length] > 0) {
            [task setCurrentDirectoryPath:outputDir];
        } else {
            [task setCurrentDirectoryPath:NSHomeDirectory()];
        }
        
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
        BOOL repackageRan = NO;
        BOOL repackageSucceeded = NO;
        BOOL cleanupSucceeded = NO;

        if (shouldRepackage && status == 0) {
            // Determine the extracted directory path (output dir is now required)
            NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
            NSString *extractedDirPath = [outputDir stringByAppendingPathComponent:fileName];
            
            // Create the output ISO filename with "_repackaged" suffix to avoid overwriting original
            NSString *outputIsoName = [NSString stringWithFormat:@"%@_repackaged.iso", fileName];
            NSString *outputIsoPath = [outputDir stringByAppendingPathComponent:outputIsoName];
            
            // Run the create command on the extracted directory
            if ([fileManager fileExistsAtPath:extractedDirPath]) {
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

                repackageRan = YES;
                repackageSucceeded = (repackageStatus == 0);

                // Combine outputs
                finalOutput = [NSString stringWithFormat:@"%@\n\n--- Auto-Repackaging ---\n%@", output, repackageOutput ?: @"No repackage output"];
                finalStatus = (status == 0 && repackageStatus == 0) ? 0 : MAX(status, repackageStatus);

                // Remove the extracted scratch files now that the ISO exists.
                // Deliberately conservative: every guard below must pass, and a
                // refusal is reported rather than silently skipped. The original
                // source ISO is never a deletion target.
                if (shouldCleanup) {
                    NSString *cleanupMessage = nil;

                    if (!repackageSucceeded) {
                        cleanupMessage = [NSString stringWithFormat:
                            @"Skipped: repackaging failed (exit code %d). Extracted files kept at:\n%@",
                            repackageStatus, extractedDirPath];
                    } else if ([fileName length] == 0 || [extractedDirPath isEqualToString:outputDir]) {
                        // e.g. an input named ".iso" collapses extractedDirPath onto the output dir
                        cleanupMessage = [NSString stringWithFormat:
                            @"Skipped: refusing to delete the output directory itself:\n%@", outputDir];
                    } else {
                        NSDictionary *isoAttrs = [fileManager attributesOfItemAtPath:outputIsoPath error:NULL];
                        unsigned long long isoSize = [isoAttrs fileSize];

                        BOOL isDirectory = NO;
                        BOOL extractedDirStillThere = [fileManager fileExistsAtPath:extractedDirPath
                                                                        isDirectory:&isDirectory];

                        // Guards against e.g. input /games/Halo/Halo.iso with output dir
                        // /games, where the extracted dir would contain the source ISO
                        NSString *standardizedDir = [extractedDirPath stringByStandardizingPath];
                        NSString *standardizedSource = [filePath stringByStandardizingPath];
                        BOOL sourceIsInsideExtractedDir =
                            [standardizedSource hasPrefix:[standardizedDir stringByAppendingString:@"/"]];

                        if (isoAttrs == nil || isoSize == 0) {
                            cleanupMessage = [NSString stringWithFormat:
                                @"Skipped: repackaged ISO is missing or empty. Extracted files kept at:\n%@",
                                extractedDirPath];
                        } else if (!extractedDirStillThere || !isDirectory) {
                            cleanupMessage = [NSString stringWithFormat:
                                @"Skipped: extracted path is missing or is not a directory:\n%@",
                                extractedDirPath];
                        } else if (sourceIsInsideExtractedDir) {
                            cleanupMessage = [NSString stringWithFormat:
                                @"Skipped: the original ISO lives inside the extracted directory, so "
                                @"deleting it would destroy the source:\n%@", standardizedSource];
                        } else {
                            NSError *trashError = nil;
                            NSURL *extractedDirURL = [NSURL fileURLWithPath:extractedDirPath];
                            BOOL trashed = [fileManager trashItemAtURL:extractedDirURL
                                                      resultingItemURL:NULL
                                                                 error:&trashError];
                            if (trashed) {
                                cleanupSucceeded = YES;
                                cleanupMessage = [NSString stringWithFormat:
                                    @"Moved extracted files to the Trash:\n%@", extractedDirPath];
                            } else {
                                // The ISO was still produced, so this does not fail the run
                                cleanupMessage = [NSString stringWithFormat:
                                    @"Failed to move extracted files to the Trash: %@\nFiles kept at:\n%@",
                                    trashError.localizedDescription ?: @"unknown error", extractedDirPath];
                            }
                        }
                    }

                    finalOutput = [NSString stringWithFormat:@"%@\n\n--- Cleanup ---\n%@",
                                   finalOutput, cleanupMessage];
                }
            } else {
                finalOutput = [NSString stringWithFormat:
                    @"%@\n\n--- Auto-Repackaging ---\nSkipped: expected extracted directory not found:\n%@",
                    output, extractedDirPath];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressIndicator stopAnimation:nil];
            [self.progressIndicator setHidden:YES];
            [self.executeButton setEnabled:YES];

            if (finalStatus == 0) {
                if (shouldRepackage && !repackageRan) {
                    // Extraction succeeded but the repackage step never ran - say so
                    [self.statusLabel setStringValue:@"Extraction completed, but repackaging was skipped (see output)"];
                } else if (repackageSucceeded && cleanupSucceeded) {
                    [self.statusLabel setStringValue:@"Extraction, repackaging and cleanup completed successfully"];
                } else if (repackageSucceeded && shouldCleanup) {
                    [self.statusLabel setStringValue:@"Extraction and repackaging completed, cleanup skipped (see output)"];
                } else if (repackageSucceeded) {
                    [self.statusLabel setStringValue:@"Extraction and repackaging completed successfully"];
                } else {
                    [self.statusLabel setStringValue:@"Command completed successfully"];
                }
            } else {
                [self.statusLabel setStringValue:[NSString stringWithFormat:@"Command failed with exit code %d", finalStatus]];
            }
            
            // Update output view
            [self.outputView setString:finalOutput ?: @"No output"];
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