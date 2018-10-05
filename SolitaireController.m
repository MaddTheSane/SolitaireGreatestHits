//
//  SolitaireController.m
//  Solitaire
//
//  Created by Daniel Fontaine on 6/21/08.
//  Copyright (C) 2008 Daniel Fontaine
// 
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
//

#import "SolitaireController.h"
#import "SolitairePreferencesController.h"
#import "SolitaireView.h"
#import "SolitaireKlondikeGame.h"
#import "SolitaireFreeCellGame.h"
#import "SolitaireSpiderGame.h"

#include <stdlib.h>
#include <time.h>

// Private methods
@interface SolitaireController(NSObject)
-(void) requestDonation;
-(void)newGameAlertDidEnd: (NSAlert*)alert returnCode: (int)returnCode contextInfo: (void*)contextInfo;
-(void)preferencesSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end

@implementation SolitaireController

+(void) initialize {
    // Setup the defaults system.
    NSMutableDictionary* defaultValues = [[NSMutableDictionary alloc] initWithCapacity: 8];

    NSData* colorAsData = [NSKeyedArchiver archivedDataWithRootObject: 
        [NSColor colorWithCalibratedRed: 0.12f green: 0.64f blue: 0.33f alpha: 1.0f]];
        
    [defaultValues setObject: colorAsData forKey: @"backgroundColor"];
    [defaultValues setValue: [NSNumber numberWithInt: NSOffState] forKey: @"showTimer"];
    [defaultValues setValue: [NSNumber numberWithInt: NSOnState] forKey: @"klondikeGameSelected"];
    [defaultValues setValue: [NSNumber numberWithInt: NSOffState] forKey: @"freeCellGameSelected"];
    [defaultValues setValue: [NSNumber numberWithInt: NSOffState] forKey: @"spiderGameSelected"];

    NSData* dateAsData = [NSKeyedArchiver archivedDataWithRootObject: [NSDate distantPast]];
    [defaultValues setObject: dateAsData forKey: @"lastDonateDate"];

    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}

-(void) awakeFromNib {
    
    // Create Toolbar
    NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier: @"SolitaireToolbar"];
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode: NSToolbarSizeModeRegular];
    toolbar.delegate = self;
    [window_ setToolbar: toolbar];
    
    srand(time(0));
    
    // Create the appropriate game.
    game_ = nil;
    if([klondikeGameItem_ state] == NSOnState) game_ = [[SolitaireKlondikeGame alloc] initWithView: view_];
    else if ([freeCellGameItem_ state] == NSOnState) game_ = [[SolitaireFreeCellGame alloc] initWithView: view_];
    else if ([spiderGameItem_ state] == NSOnState) game_ = [[SolitaireSpiderGame alloc] initWithView: view_];
    
    self.preferences = nil;
}

-(void) windowDidBecomeKey: (NSNotification *)notification {
    static BOOL isStarting = YES;
    if(isStarting) {
        isStarting = NO;

        [game_ initializeGame];
        [game_ startGame];
        
        [self requestDonation];
    }
}

-(IBAction) onNewGame: (id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: @"Yes"];
    [alert addButtonWithTitle: @"Cancel"];
    [alert setMessageText: @"New Game"];
    [alert setInformativeText: @"Do you want to end the current game and start a new one?"];
    [alert setAlertStyle: NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow: window_ modalDelegate: self didEndSelector:@selector(newGameAlertDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(void) newGame {
    [view_ reset];
    
    [game_ reset];
    [game_ initializeGame];
    [game_ startGame];
}

-(IBAction) onPreferences: (id)sender {
    if(self.preferences == nil) {
        SolitairePreferencesController* controller = [[SolitairePreferencesController alloc] init];
        [NSBundle loadNibNamed: @"Preferences" owner: controller];
        self.preferences = controller;
    }
    
    [NSApp beginSheet: self.preferences.preferencesPanel modalForWindow: window_ modalDelegate: self
        didEndSelector: @selector(preferencesSheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction) onKlondikeGame: (NSMenuItem*)sender {
    if([game_ class] != [SolitaireKlondikeGame class]) {
        game_ = [[SolitaireKlondikeGame alloc] initWithView: view_];
        [self newGame];
        
        [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithInt: NSOffState] forKey: @"freeCellGameSelected"];
        [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithInt: NSOffState] forKey: @"spiderGameSelected"];
    }
}

-(IBAction) onFreeCellGame: (NSMenuItem*)sender {
    if([game_ class] != [SolitaireFreeCellGame class]) {
        game_ = [[SolitaireFreeCellGame alloc] initWithView: view_];
        [self newGame];
        
        [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithInt: NSOffState] forKey: @"klondikeGameSelected"];
        [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithInt: NSOffState] forKey: @"spiderGameSelected"];
    }
}

-(IBAction) onSpiderGame: (NSMenuItem*)sender {
    if([game_ class] != [SolitaireSpiderGame class]) {
        game_ = [[SolitaireSpiderGame alloc] initWithView: view_];
        [self newGame];
        
        [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithInt: NSOffState] forKey: @"klondikeGameSelected"];
        [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithInt: NSOffState] forKey: @"freeCellGameSelected"];
    }
}

-(SolitaireGame*) game {
    return game_;
}

// Toolbar delegate methods

static NSString* SolitaireNewGameToolbarItemIdentifier = @"Solitaire New Game Toolbar Item";
static NSString* SolitairePreferencesToolbarItemIdentifier = @"Solitaire Preferences Toolbar Item";
static NSString* SolitaireUndoToolbarItemIdentifier = @"Solitaire Undo Toolbar Item";

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar {
    return [NSArray arrayWithObjects:
        SolitaireNewGameToolbarItemIdentifier,
        SolitairePreferencesToolbarItemIdentifier,
        SolitaireUndoToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier, nil];
}

-(NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar *)toolbar {
    return [NSArray arrayWithObjects:
        SolitaireNewGameToolbarItemIdentifier,
        SolitairePreferencesToolbarItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        SolitaireUndoToolbarItemIdentifier, nil];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemIdentifier willBeInsertedIntoToolbar: (BOOL)flag {
    
    NSToolbarItem* toolbarItem = nil; 
    if([itemIdentifier isEqualTo: SolitaireNewGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"New Game"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Start a new game"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"SolitaireIcon" ofType:@"icns"]]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onNewGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualTo: SolitairePreferencesToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Preferences"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Change game preferences"];
        [toolbarItem setImage: [NSImage imageNamed: @"NSPreferencesGeneral"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onPreferences:)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualTo: SolitaireUndoToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Undo"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Undo last move"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"UndoIcon" ofType:@"icns"]]];
        [toolbarItem setTarget: [view_ undoManager]];
        [toolbarItem setAction: @selector(undo)];
        [toolbarItem setEnabled: YES];
    }
    return toolbarItem;
}

// Private Method

-(void) requestDonation {
    NSData* dateAsData = [[NSUserDefaults standardUserDefaults] objectForKey: @"lastDonateDate"];
    NSDate* lastDonateDate = [NSKeyedUnarchiver unarchiveObjectWithData: dateAsData];
    NSDate* todaysDate = [NSDate date];
    const NSTimeInterval secsInWeek = 604800;
    
    // Ask for donation once every four weeks.
    if([todaysDate timeIntervalSinceDate: lastDonateDate] > 4 * secsInWeek) {
        
        NSString* message = @"A great deal of effort goes into creating free software. If you enjoy Solitaire Greatest Hits then please support its continued development by making a small donation through Paypal. Thanks.";
        NSAlert* donateAlert = [NSAlert alertWithMessageText: @"Support this Software" defaultButton: @"Donate"
                alternateButton: @"No Thanks" otherButton: nil informativeTextWithFormat: message, nil];
        NSInteger clickedButton = [donateAlert runModal];
        if(clickedButton == NSAlertDefaultReturn)
            [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6662868"]];
            
        // Let defaults know we requested donation today.
        [[NSUserDefaults standardUserDefaults] setObject: [NSKeyedArchiver archivedDataWithRootObject: todaysDate] forKey: @"lastDonateDate"];
    }
}

// Sheet Delegate methods

-(void)newGameAlertDidEnd: (NSAlert*)alert returnCode: (int)returnCode contextInfo: (void*)contextInfo {
    if(returnCode == NSAlertFirstButtonReturn) [self newGame];
}

- (void)preferencesSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if(returnCode == NSOKButton) {
        [view_ showTimer: [self.preferences shouldShowTimer]];
        [view_ setTableBackground: [self.preferences.colorWell color]];
        [view_.layer setNeedsDisplay];
    }
    
    [sheet orderOut: self];
}

@synthesize preferences;

@end
