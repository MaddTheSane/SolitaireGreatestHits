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
#import "SolitaireTimer.h"
#import "SolitaireScoreKeeper.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"

#import "SolitaireKlondikeGame.h"
#import "SolitaireSingleCardKlondikeGame.h"
#import "SolitaireFreeCellGame.h"
#import "SolitaireSpiderGame.h"
#import "SolitaireAcesUpGame.h"
#import "SolitaireBakersGame.h"
#import "SolitaireCanfieldGame.h"
#import "SolitaireFortyThievesGame.h"
#import "SolitairePyramidGame.h"
#import "SolitaireGolfGame.h"
#import "SolitaireScorpianGame.h"
#import "SolitaireYukonGame.h"


#include <stdlib.h>
#include <time.h>

// Private methods
@interface SolitaireController(NSObject)
-(void) requestDonation;
-(void) selectGameWithRegistryIndex: (NSInteger)index;

// Sheet callbacks
-(void) newGameAlertDidEnd: (NSAlert*)alert returnCode: (int)returnCode contextInfo: (void*)contextInfo;
-(void) restartGameAlertDidEnd: (NSAlert*)alert returnCode: (int)returnCode contextInfo: (void*)contextInfo;
-(void) savePanelDidEnd: (NSSavePanel*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo;
-(void) openPanelDidEnd: (NSOpenPanel*)panel returnCode: (int)returnCode  contextInfo: (void*)contextInfo;
-(void) preferencesSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(void) chooseGameAlertDidEnd: (NSAlert*)alert returnCode: (int)returnCode contextInfo: (void*)contextInfo;
@end

// Toolbar Item Identifier strings
static NSString* SolitaireNewGameToolbarItemIdentifier = @"Solitaire New Game Toolbar Item";
static NSString* SolitaireRestartGameToolbarItemIdentifier = @"Solitaire Restart Game Toolbar Item";
static NSString* SolitaireSaveGameToolbarItemIdentifier = @"Solitaire Save Game Toolbar Item";
static NSString* SolitaireOpenGameToolbarItemIdentifier = @"Solitaire Open Game Toolbar Item";
static NSString* SolitairePreferencesToolbarItemIdentifier = @"Solitaire Preferences Toolbar Item";
static NSString* SolitaireChooseGameToolbarItemIdentifier = @"Solitaire Choose Game Toolbar Item";
static NSString* SolitaireAutoToolbarItemIdentifier = @"Solitaire Auto Toolbar Item";
static NSString* SolitaireUndoToolbarItemIdentifier = @"Solitaire Undo Toolbar Item";
static NSString* SolitaireRedoToolbarItemIdentifier = @"Solitaire Redo Toolbar Item";
static NSString* SolitaireInstructionsToolbarItemIdentifier = @"Solitaire Instructions Toolbar Item";

@implementation SolitaireController

@synthesize window;
@synthesize preferences;
@synthesize view;
@synthesize timer;
@synthesize scoreKeeper;

+(void) initialize {
    // Setup the defaults system.
    NSMutableDictionary* defaultValues = [[NSMutableDictionary alloc] initWithCapacity: 8];

    [defaultValues setObject:[NSNumber numberWithInt: NSOffState] forKey: @"showScoreAndTime"];
    [defaultValues setObject:[NSNumber numberWithInt: 0] forKey: @"selectedGameIndex"];

    NSData* colorAsData = [NSKeyedArchiver archivedDataWithRootObject: 
        [NSColor colorWithCalibratedRed: 0.12f green: 0.64f blue: 0.33f alpha: 1.0f]];
        
    [defaultValues setObject: colorAsData forKey: @"backgroundColor"];

    NSData* dateAsData = [NSKeyedArchiver archivedDataWithRootObject: [NSDate distantPast]];
    [defaultValues setObject: dateAsData forKey: @"lastDonateDate"];

    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}

-(void) awakeFromNib {
    
    // About window is created upon request.
    aboutWindow_ = nil;
    
    // Create Bar at the bottom of the window.
    [self.window setAutorecalculatesContentBorderThickness: YES forEdge: NSMinYEdge];
    [self.window setContentBorderThickness: 22.0 forEdge: NSMinYEdge];
    
    // Create Toolbar
    NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier: @"SolitaireToolbar"];
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode: NSToolbarSizeModeRegular];
    toolbar.delegate = self;
    [self.window setToolbar: toolbar];
        
    // Register Games
    gameRegistry_ = [[NSMutableArray alloc] initWithCapacity: 16];
    gameDictionary_ = [[NSMutableDictionary alloc] initWithCapacity: 16];
    [self registerGames];
    
    // Load selected game
    NSNumber* selectedGameIndex = [[NSUserDefaults standardUserDefaults] objectForKey: @"selectedGameIndex"];
    [self selectGameWithRegistryIndex: [selectedGameIndex intValue]];
    
    self.preferences = nil;
}

-(void) windowDidBecomeKey: (NSNotification *)notification {
    static BOOL isStarting = YES;
    if(isStarting) {
        isStarting = NO;
        [self newGame];
        [self requestDonation];
    }
}

-(void) registerGames {
    [self registerGame: [[SolitaireKlondikeGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireSingleCardKlondikeGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireFreeCellGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireSpiderGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireAcesUpGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireBakersGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireCanfieldGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireFortyThievesGame alloc] initWithController: self]];
    [self registerGame: [[SolitairePyramidGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireGolfGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireScorpianGame alloc] initWithController: self]];
    [self registerGame: [[SolitaireYukonGame alloc] initWithController: self]];
}

-(void) registerGame: (SolitaireGame*)game {
    [gameRegistry_ addObject: game];
    [gameDictionary_ setObject: game forKey: [game name]];
    
    NSMenuItem* gameItem = [[NSMenuItem alloc] initWithTitle: [game name] action: @selector(onGameSelected:) keyEquivalent: @""];

    NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu* gameMenu = [[mainMenu itemWithTitle: @"Game"] submenu];
    [gameMenu addItem: gameItem];

    [gameItem setState: NSOffState]; 
}

-(NSArray*) availableGames {
    return [gameRegistry_ copy];
}

-(void) newGame {
    [self.view reset];
    
    [game_ reset];
    [game_ gameWithSeed: time(0)];
    [game_ initializeGame];
    [game_ layoutGameComponents];
    [game_ startGame];
    
    // Hide or Display Score
    if(![game_ keepsScore]) [scoreKeeper hideScore: YES];
    else [scoreKeeper hideScore: NO];
    
    //
}

-(void) restartGame {
    [self.view reset];
    
    [game_ reset];
    [game_ gameWithSeed: [game_ gameSeed]];
    [game_ initializeGame];
    [game_ layoutGameComponents];
    [game_ startGame];
}

-(void) saveGameWithFilename: (NSString*)filename {
    SolitaireSavedGameImage* gameImage = [game_ generateSavedGameImage];
    [gameImage archiveGameTime: [self.timer secondsEllapsed]];
    if([game_ keepsScore]) [gameImage archiveGameScore: [self.scoreKeeper score]];
    
    [NSKeyedArchiver archiveRootObject: gameImage toFile: filename];
}

-(void) openGameWithFilename: (NSString*)filename {
    SolitaireSavedGameImage* gameImage = [NSKeyedUnarchiver unarchiveObjectWithFile: filename];
    SolitaireGame* newGame = [gameDictionary_ objectForKey: [gameImage gameName]];
    if(newGame != nil) {
        [self.view reset];    
        [self selectGameWithRegistryIndex: [gameRegistry_ indexOfObject: newGame]];
        [game_ reset];
        
        [game_ loadSavedGameImage: gameImage];
        [self.timer setSecondsEllapsed: [gameImage unarchiveGameTime]];
        if([game_ keepsScore]) [self.scoreKeeper setInitialScore: [gameImage unarchiveGameScore]];
        
        [game_ layoutGameComponents];
    }
}

-(IBAction) onNewGame: (id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: @"Yes"];
    [alert addButtonWithTitle: @"Cancel"];
    [alert setMessageText: @"New Game"];
    [alert setInformativeText: @"Do you want to end the current game and start a new one?"];
    [alert setAlertStyle: NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow: self.window modalDelegate: self didEndSelector:@selector(newGameAlertDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction) onRestartGame: (id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: @"Yes"];
    [alert addButtonWithTitle: @"Cancel"];
    [alert setMessageText: @"Restart Game"];
    [alert setInformativeText: @"Do you want to start the current game from the beginning?"];
    [alert setAlertStyle: NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow: self.window modalDelegate: self didEndSelector:@selector(restartGameAlertDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction) onSaveGame: (id)sender {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex: 0];

    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setTitle: @"Save Game"];
    [savePanel setExtensionHidden: YES];
    [savePanel setRequiredFileType: @"sgh"];
    [savePanel beginSheetForDirectory: documentsDirectory file: @"Untitled" modalForWindow: self.window modalDelegate: self
        didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction) onOpenGame: (id)sender {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex: 0];

    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle: @"Open Game"];
    [openPanel setExtensionHidden: YES];
    [openPanel setCanChooseFiles: YES];
    [openPanel setCanChooseDirectories: NO];
    [openPanel setAllowsMultipleSelection: NO];

    [openPanel beginSheetForDirectory: documentsDirectory file: nil types: [NSArray arrayWithObject: @"sgh"]
        modalForWindow: self.window modalDelegate: self
            didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction) onPreferences: (id)sender {
    if(self.preferences == nil) {
        SolitairePreferencesController* controller = [[SolitairePreferencesController alloc] init];
        [NSBundle loadNibNamed: @"Preferences" owner: controller];
        self.preferences = controller;
    }
    
    [NSApp beginSheet: self.preferences.preferencesPanel modalForWindow: self.window modalDelegate: self
        didEndSelector: @selector(preferencesSheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction) onChooseGame: (id)sender {
    NSArray* games = [self availableGames];

    // Create a matrix of radio buttons
    NSButtonCell *prototype = [[NSButtonCell alloc] init];
    [prototype setTitle: @"Choose a Game..."];
    [prototype setButtonType: NSRadioButton];
    NSRect matrixRect = NSMakeRect(0.0, 0.0, 300.0, 225.0);
    NSMatrix* matrix = [[NSMatrix alloc] initWithFrame: matrixRect
                                                    mode: NSRadioModeMatrix
                                               prototype: (NSCell*)prototype
                                            numberOfRows: [games count]
                                         numberOfColumns: 1];
    NSSize cellSize = [matrix cellSize];
    cellSize.width = 200;
    [matrix setCellSize: cellSize];
                                                                              
    int index = 0;
    NSArray *cellArray = [matrix cells];
    for(SolitaireGame* game in games) {
        NSCell* cell = [cellArray objectAtIndex: index];
        [cell setTitle: [game name]];
        if(game == game_) [matrix selectCellAtRow: index column: 0];
        index++;
    }

    // Create an alert sheet.
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: @"Play This Game"];
    [alert addButtonWithTitle: @"Cancel"];
    [alert setMessageText: @"Choose a different Solitaire game..."];
    [alert setInformativeText: @"Do you want to end the current game and start a new one?"];
    [alert setAccessoryView: matrix];
    [alert setAlertStyle: NSInformationalAlertStyle];
    
    [alert beginSheetModalForWindow: self.window modalDelegate: self
        didEndSelector: @selector(chooseGameAlertDidEnd:returnCode:contextInfo:) contextInfo: matrix];
}

-(IBAction) onAbout: (id)sender {
    if(!aboutWindow_) [NSBundle loadNibNamed: @"About" owner: self];
    [aboutWindow_ orderFront: self];
}

-(IBAction) onGameSelected: (NSMenuItem*)sender {
    // Uncheck current game item.
    NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu* gameMenu = [[mainMenu itemWithTitle: @"Game"] submenu];
    
    [self selectGameWithRegistryIndex: [gameMenu indexOfItem: sender]];
    [self newGame];
}

-(IBAction) onInstructions: (id)sender {
    NSString* bookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
    NSString* anchor = [[game_ name] stringByReplacingOccurrencesOfString: @" " withString: @""];
    anchor = [anchor stringByReplacingOccurrencesOfString: @"\'" withString: @""];
    [[NSHelpManager sharedHelpManager] openHelpAnchor: anchor inBook: bookName];
}

-(IBAction) onAutoFinish: (id)sender {
    if([game_ supportsAutoFinish]) [game_ autoFinishGame];
}

-(SolitaireGame*) game {
    return game_;
}

// Toolbar delegate methods

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar {
    return [NSArray arrayWithObjects:
        SolitaireNewGameToolbarItemIdentifier,
        SolitaireRestartGameToolbarItemIdentifier,
        SolitaireSaveGameToolbarItemIdentifier,
        SolitaireOpenGameToolbarItemIdentifier,
        SolitairePreferencesToolbarItemIdentifier,
        SolitaireChooseGameToolbarItemIdentifier,
        SolitaireAutoToolbarItemIdentifier,
        SolitaireUndoToolbarItemIdentifier,
        SolitaireRedoToolbarItemIdentifier,
        SolitaireInstructionsToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier, nil];
}

-(NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar *)toolbar {
    return [NSArray arrayWithObjects:
        SolitaireNewGameToolbarItemIdentifier,
        SolitaireRestartGameToolbarItemIdentifier,
        SolitaireChooseGameToolbarItemIdentifier,
        SolitairePreferencesToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        SolitaireSaveGameToolbarItemIdentifier,
        SolitaireOpenGameToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        SolitaireAutoToolbarItemIdentifier,
        SolitaireUndoToolbarItemIdentifier,
        SolitaireRedoToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        SolitaireInstructionsToolbarItemIdentifier, nil];
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
    else if([itemIdentifier isEqualTo: SolitaireRestartGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Restart Game"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Restart this game"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"RestartIcon" ofType:@"icns"]]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onRestartGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if([itemIdentifier isEqualTo: SolitaireSaveGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Save Game"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Save your current game"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"SaveIcon" ofType:@"icns"]]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onSaveGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if([itemIdentifier isEqualTo: SolitaireOpenGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Open Game"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Open a previous game"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"OpenIcon" ofType:@"icns"]]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onOpenGame:)];
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
    else if ([itemIdentifier isEqualTo: SolitaireChooseGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Choose Game"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Choose a different game to play"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"ChooseGame" ofType:@"icns"]]];;
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onChooseGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualTo: SolitaireAutoToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Auto Finish"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Auto finish this game"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"AutoIcon" ofType:@"icns"]]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onAutoFinish:)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualTo: SolitaireUndoToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Undo"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Undo last move"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"UndoIcon" ofType:@"icns"]]];
        [toolbarItem setTarget: [self.view undoManager]];
        [toolbarItem setAction: @selector(undo)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualTo: SolitaireRedoToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"Redo"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Redo move"];
        [toolbarItem setImage: [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"RedoIcon" ofType:@"icns"]]];
        [toolbarItem setTarget: [self.view undoManager]];
        [toolbarItem setAction: @selector(redo)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualTo: SolitaireInstructionsToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: @"How To Play"];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: @"Instructions on how to play this game"];
        [toolbarItem setImage: [NSImage imageNamed: @"NSInfo"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onInstructions:)];
        [toolbarItem setEnabled: YES];
    }
    return toolbarItem;
}

-(BOOL) validateToolbarItem:(NSToolbarItem *) item {
    if([item itemIdentifier] == SolitaireAutoToolbarItemIdentifier) {
        if(![game_ supportsAutoFinish]) return NO;
    }
    return YES;
}

-(BOOL) validateMenuItem: (NSMenuItem*)menuItem {
    if([[menuItem title] isEqualToString: @"Auto Finish Game"]) {
        if(![game_ supportsAutoFinish]) return NO;
    }
    return YES;
}

// Private methods

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

-(void) selectGameWithRegistryIndex: (NSInteger)index {
    NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu* gameMenu = [[mainMenu itemWithTitle: @"Game"] submenu];
    
    // Clear the check from the old game.
    if(game_ != nil) {
        NSMenuItem* currentGameItem = [gameMenu itemWithTitle: [game_ name]];
        [currentGameItem setState: NSOffState];
    }
    
    // Set the new game as the active game.
    NSMenuItem* newGameItem = [gameMenu itemAtIndex: index];
    [newGameItem setState: NSOnState];

    game_ = [gameRegistry_ objectAtIndex: index];
    
    // Register game with defaults
    [[NSUserDefaults standardUserDefaults] setInteger: index forKey: @"selectedGameIndex"];
    
    // Put the name of the game in the title of the window.
    [self.window setTitle: [NSString stringWithFormat: @"Solitaire Greatest Hits: %@", [game_ name]]];
}

// Sheet Delegate methods

-(void)newGameAlertDidEnd: (NSAlert*)alert returnCode: (int)returnCode contextInfo: (void*)contextInfo {
    if(returnCode == NSAlertFirstButtonReturn) [self newGame];
}

-(void)restartGameAlertDidEnd: (NSAlert*)alert returnCode: (int)returnCode contextInfo: (void*)contextInfo {
    if(returnCode == NSAlertFirstButtonReturn) [self restartGame];
}

-(void) savePanelDidEnd: (NSSavePanel*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo {
    if(returnCode == NSOKButton) {
        NSString* filename = [sheet filename];
        [self saveGameWithFilename: filename];
    }
}

-(void) openPanelDidEnd: (NSOpenPanel*)panel returnCode: (int)returnCode  contextInfo: (void*)contextInfo {
    if(returnCode == NSOKButton) {
        NSString* filename = [panel filename];
        [self openGameWithFilename: filename];
    }
}

- (void)preferencesSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if(returnCode == NSOKButton) {
        [self.view setTableBackground: [self.preferences.colorWell color]];
        [self.view.layer setNeedsDisplay];
    }    
    [sheet orderOut: self];
}

-(void)chooseGameAlertDidEnd: (NSAlert*)alert returnCode: (int)returnCode contextInfo: (void*)contextInfo {
    if(returnCode == NSAlertFirstButtonReturn) {
        NSMatrix* matrix = contextInfo;
        NSInteger index = [matrix selectedRow];
        [self selectGameWithRegistryIndex: index];
        [self newGame];
    }
}

@end
