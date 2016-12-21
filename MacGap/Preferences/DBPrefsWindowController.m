//
//  DBPrefsWindowController.m
//

#import "DBPrefsWindowController.h"

@implementation DBPrefsWindowController {
	NSMutableArray *toolbarIdentifiers;
	NSMutableDictionary *toolbarViews;
	NSMutableDictionary *toolbarItems;
	
	NSView *contentSubview;
	NSViewAnimation *viewAnimation;
}

@synthesize crossFade = _crossFade;
@synthesize shiftSlowsAnimation = _shiftSlowsAnimation;


#pragma mark -
#pragma mark Class Methods

+ (DBPrefsWindowController *)sharedPrefsWindowController{
    static DBPrefsWindowController *_sharedPrefsWindowController = nil;    
	if(!_sharedPrefsWindowController){
		_sharedPrefsWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _sharedPrefsWindowController;
}

// Subclasses can override this to use a nib with a different name.
+ (NSString *)nibName{
   return @"Preferences";
}


#pragma mark -
#pragma mark Setup & Teardown

- (id)initWithWindow:(NSWindow *)window{
	if((self = [super initWithWindow:nil])){
        // Set up an array and some dictionaries to keep track
        // of the views we'll be displaying.
        toolbarIdentifiers = [[NSMutableArray alloc] init];
        toolbarViews = [[NSMutableDictionary alloc] init];
        toolbarItems = [[NSMutableDictionary alloc] init];

        // Set up an NSViewAnimation to animate the transitions.
        viewAnimation = [[NSViewAnimation alloc] init];
        [viewAnimation setAnimationBlockingMode:NSAnimationNonblocking];
        [viewAnimation setAnimationCurve:NSAnimationEaseInOut];
        [viewAnimation setDelegate:(id<NSAnimationDelegate>)self];

        self.crossFade = YES;
        self.shiftSlowsAnimation = YES;
	}
	return self;
}

- (void)windowDidLoad{
    // Create a new window to display the preference views.
    // If the developer attached a window to this controller
    // in Interface Builder, it gets replaced with this one.
    NSWindow *window = 
    [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,1000,1000)
                                styleMask:(NSTitledWindowMask |
                                           NSClosableWindowMask |
                                           NSMiniaturizableWindowMask)
                                  backing:NSBackingStoreBuffered
                                    defer:YES];
    [self setWindow:window];
    contentSubview = [[NSView alloc] initWithFrame:[[[self window] contentView] frame]];
    [contentSubview setAutoresizingMask:(NSViewMinYMargin | NSViewWidthSizable)];
    [[[self window] contentView] addSubview:contentSubview];
    [[self window] setShowsToolbarButton:NO];
}


#pragma mark -
#pragma mark Configuration

- (void)setupToolbar{
    // Subclasses must override this method to add items to the
    // toolbar by calling -addView:label: or -addView:label:image:.
}

- (void)addView:(NSView *)view label:(NSString *)label{
    [self addView:view label:label image:[NSImage imageNamed:label]];
}

- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image{
    if(view == nil){
        return;
    }
	
    NSString *identifier = [label copy];

    [toolbarIdentifiers addObject:identifier];
    [toolbarViews setObject:view forKey:identifier];

    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    [item setLabel:label];
    [item setImage:image];
    [item setTarget:self];
    [item setAction:@selector(toggleActivePreferenceView:)];

    [toolbarItems setObject:item forKey:identifier];
    
#if !__has_feature(objc_arc)    
    [identifier release];
    [item release];
#endif
}


#pragma mark -
#pragma mark Overriding Methods

- (IBAction)showWindow:(id)sender{
    // This forces the resources in the nib to load.
    [self window];

    // Clear the last setup and get a fresh one.
    [toolbarIdentifiers removeAllObjects];
    [toolbarViews removeAllObjects];
    [toolbarItems removeAllObjects];
    [self setupToolbar];

    if(![toolbarIdentifiers count]){
        return;
    }

    if([[self window] toolbar] == nil){
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"DBPreferencesToolbar"];
        [toolbar setAllowsUserCustomization:NO];
        [toolbar setAutosavesConfiguration:NO];
        [toolbar setSizeMode:NSToolbarSizeModeDefault];
        [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
        [toolbar setDelegate:(id<NSToolbarDelegate>)self];
        [[self window] setToolbar:toolbar];
    }

    NSString *firstIdentifier = [toolbarIdentifiers objectAtIndex:0];
    [[[self window] toolbar] setSelectedItemIdentifier:firstIdentifier];
    [self displayViewForIdentifier:firstIdentifier animate:NO];

    [[self window] center];
    [[self window] setLevel:NSFloatingWindowLevel];

    [super showWindow:sender];
}


#pragma mark -
#pragma mark Toolbar

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar{
	return toolbarIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar{
	return toolbarIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar{
	return toolbarIdentifiers;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted{
	return [toolbarItems objectForKey:identifier];
}

- (void)toggleActivePreferenceView:(NSToolbarItem *)toolbarItem{
	[self displayViewForIdentifier:[toolbarItem itemIdentifier] animate:YES];
}

- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate{	
    // Find the view we want to display.
    NSView *newView = [toolbarViews objectForKey:identifier];

    // See if there are any visible views.
    NSView *oldView = nil;
    if([[contentSubview subviews] count] > 0) {
        // Get a list of all of the views in the window. Usually at this
        // point there is just one visible view. But if the last fade
        // hasn't finished, we need to get rid of it now before we move on.
        NSEnumerator *subviewsEnum = [[contentSubview subviews] reverseObjectEnumerator];

        // The first one (last one added) is our visible view.
        oldView = [subviewsEnum nextObject];

        // Remove any others.
        NSView *reallyOldView = nil;
        while((reallyOldView = [subviewsEnum nextObject]) != nil){
            [reallyOldView removeFromSuperviewWithoutNeedingDisplay];
        }
    }

    if(![newView isEqualTo:oldView]){
        NSRect frame = [newView bounds];
        frame.origin.y = NSHeight([contentSubview frame]) - NSHeight([newView bounds]);
        [newView setFrame:frame];
        [contentSubview addSubview:newView];
        [[self window] setInitialFirstResponder:newView];

        if(animate && [self crossFade]){
            [self crossFadeView:oldView withView:newView];
        }else{
            [oldView removeFromSuperviewWithoutNeedingDisplay];
            [newView setHidden:NO];
            [[self window] setFrame:[self frameForView:newView] display:YES animate:animate];
        }

        [[self window] setTitle:[[toolbarItems objectForKey:identifier] label]];
    }
}


#pragma mark -
#pragma mark Cross-Fading Methods

- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView{
    [viewAnimation stopAnimation];

    if([self shiftSlowsAnimation] && [[[self window] currentEvent] modifierFlags] & NSShiftKeyMask){
        [viewAnimation setDuration:1.25];
    }else{
        [viewAnimation setDuration:0.25];
    }

    NSDictionary *fadeOutDictionary = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     oldView, NSViewAnimationTargetKey,
     NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
     nil];

    NSDictionary *fadeInDictionary = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     newView, NSViewAnimationTargetKey,
     NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
     nil];

    NSDictionary *resizeDictionary = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     [self window], NSViewAnimationTargetKey,
     [NSValue valueWithRect:[[self window] frame]], NSViewAnimationStartFrameKey,
     [NSValue valueWithRect:[self frameForView:newView]], NSViewAnimationEndFrameKey,
     nil];

    NSArray *animationArray = 
    [NSArray arrayWithObjects:
     fadeOutDictionary,
     fadeInDictionary,
     resizeDictionary,
     nil];

    [viewAnimation setViewAnimations:animationArray];
    [viewAnimation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation{
    NSView *subview;

    // Get a list of all of the views in the window. Hopefully
    // at this point there are two. One is visible and one is hidden.
    NSEnumerator *subviewsEnum = [[contentSubview subviews] reverseObjectEnumerator];

    // This is our visible view. Just get past it.
    [subviewsEnum nextObject];

    // Remove everything else. There should be just one, but
    // if the user does a lot of fast clicking, we might have
    // more than one to remove.
    while((subview = [subviewsEnum nextObject]) != nil){
        [subview removeFromSuperviewWithoutNeedingDisplay];
    }

    // This is a work-around that prevents the first
    // toolbar icon from becoming highlighted.
    [[self window] makeFirstResponder:nil];
}

// Calculate the window size for the new view.
- (NSRect)frameForView:(NSView *)view{
	NSRect windowFrame = [[self window] frame];
	NSRect contentRect = [[self window] contentRectForFrameRect:windowFrame];
	float windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect);

	windowFrame.size.height = NSHeight([view frame]) + windowTitleAndToolbarHeight;
	windowFrame.size.width = NSWidth([view frame]);
	windowFrame.origin.y = NSMaxY([[self window] frame]) - NSHeight(windowFrame);
	
	return windowFrame;
}

// Close the window with cmd+w incase the app doesn't have an app menu
- (void)keyDown:(NSEvent *)theEvent{
    NSString *key = [theEvent charactersIgnoringModifiers];
    if(([theEvent modifierFlags] & NSCommandKeyMask) && [key isEqualToString:@"w"]){
        [self close];
    }else{
        [super keyDown:theEvent];
    }
}

@end
