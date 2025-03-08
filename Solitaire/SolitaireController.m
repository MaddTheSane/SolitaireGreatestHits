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
#import "SolitaireSpiderGame.h"
#import "SolitaireAcesUpGame.h"
#import "SolitaireCanfieldGame.h"
#import "SolitaireFortyThievesGame.h"
#import "SolitairePyramidGame.h"
#import "SolitaireGolfGame.h"
#import "SolitaireScorpianGame.h"
#import "SolitaireYukonGame.h"
#import "Solitaire_Greatest_Hits-Swift.h"
#import "GeneratedAssetSymbols.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>


#include <stdlib.h>
#include <time.h>

// Private methods
@interface SolitaireController()
-(void) requestDonation;
-(void) selectGameWithRegistryIndex: (NSInteger)index;
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls;

@end

// Toolbar Item Identifier strings
static NSToolbarItemIdentifier const SolitaireNewGameToolbarItemIdentifier = @"Solitaire New Game Toolbar Item";
static NSToolbarItemIdentifier const SolitaireRestartGameToolbarItemIdentifier = @"Solitaire Restart Game Toolbar Item";
static NSToolbarItemIdentifier const SolitaireSaveGameToolbarItemIdentifier = @"Solitaire Save Game Toolbar Item";
static NSToolbarItemIdentifier const SolitaireOpenGameToolbarItemIdentifier = @"Solitaire Open Game Toolbar Item";
static NSToolbarItemIdentifier const SolitairePreferencesToolbarItemIdentifier = @"Solitaire Preferences Toolbar Item";
static NSToolbarItemIdentifier const SolitaireChooseGameToolbarItemIdentifier = @"Solitaire Choose Game Toolbar Item";
static NSToolbarItemIdentifier const SolitaireAutoToolbarItemIdentifier = @"Solitaire Auto Toolbar Item";
static NSToolbarItemIdentifier const SolitaireUndoToolbarItemIdentifier = @"Solitaire Undo Toolbar Item";
static NSToolbarItemIdentifier const SolitaireRedoToolbarItemIdentifier = @"Solitaire Redo Toolbar Item";
static NSToolbarItemIdentifier const SolitaireInstructionsToolbarItemIdentifier = @"Solitaire Instructions Toolbar Item";

@implementation SolitaireController

@synthesize window;
@synthesize preferences;
@synthesize view;
@synthesize timer;
@synthesize scoreKeeper;

+(void) initialize {
    // Setup the defaults system.
    NSMutableDictionary<NSString*,id>* defaultValues = [[NSMutableDictionary alloc] initWithCapacity: 8];

    defaultValues[@"showScoreAndTime"] = @(NSControlStateValueOff);
    defaultValues[@"selectedGameIndex"] = @0;

    NSData* colorAsData = [NSKeyedArchiver archivedDataWithRootObject: 
                           [NSColor colorNamed:ACColorNameDefaultFeltBackground] requiringSecureCoding: YES error: NULL];
        
    defaultValues[@"backgroundColor"] = colorAsData;
    defaultValues[@"cardBack"] = ACImageNameCardBack1;

    defaultValues[@"lastDonateDate"] = [NSDate distantPast];

    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}

-(void) awakeFromNib {
    
    // Create Bar at the bottom of the window.
    [self.window setAutorecalculatesContentBorderThickness: YES forEdge: NSRectEdgeMinY];
    [self.window setContentBorderThickness: 22.0 forEdge: NSRectEdgeMinY];
    
    // Create Toolbar
    NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier: @"SolitaireToolbar"];
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode: NSToolbarSizeModeRegular];
    toolbar.delegate = self;
    [self.window setToolbar: toolbar];
    if (@available(macOS 11.0, *)) {
        self.window.toolbarStyle = NSWindowToolbarStyleExpanded;
    }
    
    // Register Games
    gameRegistry_ = [[NSMutableArray alloc] initWithCapacity: 16];
    gameDictionary_ = [[NSMutableDictionary alloc] initWithCapacity: 16];
    [self registerGames];
    
    // Load selected game
    NSInteger selectedGameIndex = [[NSUserDefaults standardUserDefaults] integerForKey: @"selectedGameIndex"];
    [self selectGameWithRegistryIndex: selectedGameIndex];
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
//    [self registerGame: [[SolitaireCardPickupGame alloc] initWithController: self]];
}

-(void) registerGame: (SolitaireGame*)game {
    [gameRegistry_ addObject: game];
    gameDictionary_[[game name]] = game;
    
    NSMenuItem* gameItem = [[NSMenuItem alloc] initWithTitle: [game localizedName] action: @selector(onGameSelected:) keyEquivalent: @""];

    NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu* gameMenu = [[mainMenu itemWithTitle: NSLocalizedStringWithDefaultValue(@"377.title", @"MainMenu", [NSBundle mainBundle], @"Game", @"Class = \"NSMenuItem\"; title = \"Game\"; ObjectID = \"377\";")] submenu];
    [gameMenu addItem: gameItem];

    [gameItem setState: NSControlStateValueOff];
}

-(NSArray*) availableGames {
    return [gameRegistry_ copy];
}

-(void) newGame {
    [self.view reset];
    
    [game_ reset];
    [game_ gameWithSeed: 0xffffffff & time(NULL)];
    [game_ initializeGame];
    [game_ layoutGameComponents];
    [game_ startGame];
    
    // Hide or Display Score
    if(![game_ keepsScore]) [scoreKeeper hideScore: YES];
    else [scoreKeeper hideScore: NO];
}

-(void) restartGame {
    [self.view reset];
    
    [game_ reset];
    [game_ gameWithSeed: [game_ gameSeed]];
    [game_ initializeGame];
    [game_ layoutGameComponents];
    [game_ startGame];
}

-(BOOL) saveGameToURL:(NSURL*)filename error:(NSError**)error
{
    SolitaireSavedGameImage* gameImage = [game_ generateSavedGameImage];
    [gameImage setGameTime: [self.timer secondsElapsed]];
    if([game_ keepsScore]) {
        [gameImage setGameScore: [self.scoreKeeper score]];
    }

    NSData *dat = [NSKeyedArchiver archivedDataWithRootObject:gameImage requiringSecureCoding:NO error:error];
    if (!dat) {
        return NO;
    }
    return [dat writeToURL:filename options:NSDataWritingAtomic error:error];
}

-(BOOL) openGameFromURL:(NSURL*)filename error:(NSError**)error
{
    NSData *localData = [NSData dataWithContentsOfURL:filename options:NSDataReadingMappedIfSafe error:error];
    if (!localData) {
        return NO;
    }
    SolitaireSavedGameImage* gameImage = [NSKeyedUnarchiver unarchivedObjectOfClass:[SolitaireSavedGameImage class] fromData:localData error:error];
    if (!gameImage) {
        return NO;
    }
    SolitaireGame* newGame = [gameDictionary_ objectForKey: [gameImage gameName]];
    if (!newGame) {
        [self.view reset];
        [self selectGameWithRegistryIndex: [gameRegistry_ indexOfObject: newGame]];
        [game_ reset];
        
        [game_ loadSavedGameImage: gameImage];
        [self.timer setSecondsElapsed: [gameImage gameTime]];
        if ([game_ keepsScore]) {
            [self.scoreKeeper setInitialScore: [gameImage gameScore]];
        }
        
        [game_ layoutGameComponents];
    }
    return YES;
}

-(IBAction) onNewGame: (id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: NSLocalizedString(@"Yes", @"Yes")];
    [alert addButtonWithTitle: NSLocalizedString(@"Cancel", @"Cancel")];
    [alert setMessageText: NSLocalizedString(@"New game", @"New game")];
    [alert setInformativeText: NSLocalizedString(@"RestartQuestion", @"Restart question")];
    [alert setAlertStyle: NSAlertStyleWarning];
 
    [alert beginSheetModalForWindow:self.window completionHandler:
     ^(NSInteger result)
    {
        if (result == NSAlertFirstButtonReturn)
            [self newGame];
    }];
}

-(IBAction) onRestartGame: (id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: NSLocalizedString(@"Yes", @"Yes")];
    [alert addButtonWithTitle: NSLocalizedString(@"Cancel", @"Cancel")];
    [alert setMessageText: NSLocalizedString(@"Restart game", @"Restart game")];
    [alert setInformativeText: NSLocalizedString(@"ReloadQuestion", @"Reload question")];
    [alert setAlertStyle: NSAlertStyleWarning];
    
    [alert beginSheetModalForWindow:self.window completionHandler:
     ^(NSInteger result)
    {
         if (result == NSAlertFirstButtonReturn)
             [self restartGame];
    }];
}

-(IBAction) onSaveGame: (id)sender
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setTitle: NSLocalizedString(@"Save Game", @"Save Game")];
    [savePanel setExtensionHidden: YES];
    if (@available(macOS 11.0, *)) {
        savePanel.allowedContentTypes = @[[UTType exportedTypeWithIdentifier:@"fontaine.Solitaire2.saveGame"]];
    } else {
        [savePanel setAllowedFileTypes: @[@"fontaine.Solitaire2.saveGame"]];
    }

    [savePanel beginSheetModalForWindow:self.window completionHandler:
	 ^(NSModalResponse result)
    {
        if (result == NSModalResponseOK)
		 {
             NSURL *url = [savePanel URL];
             NSError *err;
             if (![self saveGameToURL:url error:&err]) {
                 [NSApp presentError:err];
             }
		 }
    }];
}

-(IBAction) onOpenGame: (id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle: NSLocalizedString(@"Open Game", @"Open Game")];
    [openPanel setExtensionHidden: YES];
    [openPanel setCanChooseFiles: YES];
    [openPanel setCanChooseDirectories: NO];
    [openPanel setAllowsMultipleSelection: NO];
    if (@available(macOS 11.0, *)) {
        openPanel.allowedContentTypes = @[[UTType exportedTypeWithIdentifier:@"fontaine.Solitaire2.saveGame"]];
    } else {
        [openPanel setAllowedFileTypes: @[@"fontaine.Solitaire2.saveGame"]];
    }

    [openPanel beginSheetModalForWindow:self.window completionHandler:
     	^(NSModalResponse result)
    {
        if (result == NSModalResponseOK)
	    {
            NSURL *url = [openPanel URL];
            NSError *err;
            if (![self openGameFromURL:url error:&err]) {
                [NSApp presentError:err];
            }
	    }
    }];
}

-(IBAction) onPreferences: (id)sender
{
    [preferences data2Controls];

    [self.window beginSheet:self.preferences.preferencesPanel completionHandler:^(NSModalResponse returnCode)
    {
        if (returnCode == NSModalResponseOK)
        {
            NSColor *color = [self.preferences selectedColor];
            [self.view setTableBackground: color];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:NULL];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"backgroundColor"];
            
            NSString *cardBack = [self.preferences selectedCardBack];
            if (![cardBack isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"cardBack"]])
            {
                [[NSUserDefaults standardUserDefaults] setObject:cardBack forKey:@"cardBack"];
                LoadFlippedCardImage(YES);
                
                NSArray *sprites = [[self view] sprites];
                for (SolitaireSprite *sprite in sprites)
                    [sprite setNeedsDisplay];
            }
            [self.view.layer setNeedsDisplay];
        }
    }];
}

-(IBAction) onChooseGame: (id)sender {
    NSArray* games = [self availableGames];

    // Create a matrix of radio buttons
    NSButtonCell *prototype = [[NSButtonCell alloc] init];
    [prototype setTitle: NSLocalizedString(@"ChooseGame", @"Choose Game")];
    [prototype setButtonType: NSButtonTypeRadio];
    NSRect matrixRect = NSMakeRect(0.0, 0.0, 300.0, 240.0);
    NSMatrix* matrix = [[NSMatrix alloc] initWithFrame: matrixRect
                                                    mode: NSRadioModeMatrix
                                               prototype: (NSCell*)prototype
                                            numberOfRows: [games count]
                                         numberOfColumns: 1];
    NSSize cellSize = [matrix cellSize];
    cellSize.width = 200;
    [matrix setCellSize: cellSize];
                                                                              
    NSInteger index = 0;
    NSArray *cellArray = [matrix cells];
    for(SolitaireGame* game in games) {
        NSCell* cell = [cellArray objectAtIndex: index];
        [cell setTitle: [game localizedName]];
        if(game == game_) [matrix selectCellAtRow: index column: 0];
        index++;
    }

    // Create an alert sheet.
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: NSLocalizedString(@"Play this game", @"Play this game")];
    [alert addButtonWithTitle: NSLocalizedString(@"Cancel", @"Cancel")];
    [alert setMessageText: NSLocalizedString(@"ChooseDifferent", @"Choose Different")];
    [alert setInformativeText: NSLocalizedString(@"RestartQuestion", @"Restart question")];
    [alert setAccessoryView: matrix];
    [alert setAlertStyle: NSAlertStyleInformational];
    
    [alert beginSheetModalForWindow:self.window completionHandler:
     ^(NSInteger result)
    {
         if (result == NSAlertFirstButtonReturn)
         {
             NSInteger index = [matrix selectedRow];
             [self selectGameWithRegistryIndex: index];
             [self newGame];
         }
    }];
}

-(IBAction) onAbout: (id)sender {
	
	NSString * rtfFilePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"rtf"];
	[infoView_ readRTFDFromFile:rtfFilePath];
	
	[aboutWindow_ makeKeyAndOrderFront: self];
}

-(IBAction) onGameSelected: (NSMenuItem*)sender {
    // Uncheck current game item.
    NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu* gameMenu = [[mainMenu itemWithTitle: NSLocalizedStringWithDefaultValue(@"377.title", @"MainMenu", [NSBundle mainBundle], @"Game", @"Class = \"NSMenuItem\"; title = \"Game\"; ObjectID = \"377\";")] submenu];
    
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

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    if ([[filename pathExtension] compare:@"sgh" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
        return NO;
    }
    
    [self application:sender openURLs:@[[NSURL fileURLWithPath:filename]]];
    return YES;
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls
{
    for (NSURL *url in urls) {
        if (!url.fileURL) {
            continue;
        }
        // Only load one url passed in.
        NSError *err;
        if (![self openGameFromURL:url error:&err]) {
            [NSApp presentError:err];
        } else {
            break;
        }
    }
}

@synthesize game=game_;

// Toolbar delegate methods

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar {
    return @[
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
        NSToolbarSeparatorItemIdentifier];
}

-(NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar *)toolbar {
    return @[
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
        SolitaireInstructionsToolbarItemIdentifier];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar
    itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier
willBeInsertedIntoToolbar: (BOOL)flag
{
    NSToolbarItem* toolbarItem = nil;
    if([itemIdentifier isEqualToString: SolitaireNewGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"New game", @"New game")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Start a new game", @"Start a new game")];
        [toolbarItem setImage: [NSImage imageNamed:NSImageNameApplicationIcon]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onNewGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if([itemIdentifier isEqualToString: SolitaireRestartGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"Restart game", @"Restart game")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Restart this game", @"Restart this game")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameRestartIcon]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onRestartGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if([itemIdentifier isEqualToString: SolitaireSaveGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"Save game", @"Save game")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Save your current game", @"Save your current game")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameSaveIcon]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onSaveGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if([itemIdentifier isEqualToString: SolitaireOpenGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"Open game", @"Open game")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Open a previous game", @"Open a previous game")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameOpenIcon]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onOpenGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualToString: SolitairePreferencesToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"Preferences", @"Preferences")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Change game preferences", @"Change game preferences")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameSettingsIcon]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onPreferences:)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualToString: SolitaireChooseGameToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"Choose game", @"Choose game")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Choose a different game to play", @"Choose a different game to play")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameChooseGame]];;
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onChooseGame:)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualToString: SolitaireAutoToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"Auto finish", @"Auto finish")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Auto finish this game", @"Auto finish this game")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameAutoIcon]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onAutoFinish:)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualToString: SolitaireUndoToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"Undo", @"Undo")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Undo last move", @"Undo last move")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameUndoIcon]];
        [toolbarItem setTarget: [self.view undoManager]];
        [toolbarItem setAction: @selector(undo)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualToString: SolitaireRedoToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"Redo", @"Redo")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Redo move", @"Redo move")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameRedoIcon]];
        [toolbarItem setTarget: [self.view undoManager]];
        [toolbarItem setAction: @selector(redo)];
        [toolbarItem setEnabled: YES];
    }
    else if ([itemIdentifier isEqualToString: SolitaireInstructionsToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [toolbarItem setLabel: NSLocalizedString(@"How to play", @"How to play")];
        [toolbarItem setPaletteLabel: [toolbarItem label]];
        [toolbarItem setToolTip: NSLocalizedString(@"Instructions on how to play this game", @"Instructions on how to play this game")];
        [toolbarItem setImage: [NSImage imageNamed: ACImageNameHelpIcon]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(onInstructions:)];
        [toolbarItem setEnabled: YES];
    }
    return toolbarItem;
}

-(BOOL) validateToolbarItem:(NSToolbarItem *) item {
    if([[item itemIdentifier] isEqualToString:SolitaireAutoToolbarItemIdentifier]) {
        if(![game_ supportsAutoFinish]) return NO;
    }
    return YES;
}

-(BOOL) validateMenuItem: (NSMenuItem*)menuItem {
	if ([menuItem action] == @selector(onAutoFinish:)
	&& ![game_ supportsAutoFinish])
		return NO;
    return YES;
}

// Private methods

-(void) requestDonation {
    NSData* dateAsData = [[NSUserDefaults standardUserDefaults] objectForKey: @"lastDonateDate"];
    NSDate* lastDonateDate;
    if ([dateAsData isKindOfClass:[NSDate class]]) {
        lastDonateDate = (NSDate*)dateAsData;
    } else {
        lastDonateDate = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDate class] fromData:dateAsData error:NULL];
        [[NSUserDefaults standardUserDefaults] setValue:lastDonateDate forKey:@"lastDonateDate"];
    }
    NSDate* todaysDate = [NSDate date];
    const NSTimeInterval secsInWeek = 604800;
    
    // Ask for donation once every four weeks.
    if([todaysDate timeIntervalSinceDate: lastDonateDate] > 4 * secsInWeek) {
        NSAlert *donateAlert = [[NSAlert alloc] init];
        donateAlert.messageText = NSLocalizedString(@"Support this Software", @"Support this Software");
        donateAlert.informativeText = NSLocalizedString(@"A great deal of effort goes into creating free software. If you enjoy Solitaire Greatest Hits then please support its continued development by making a small donation through Paypal. Thanks.", @"Please donate");
        [donateAlert addButtonWithTitle:NSLocalizedString(@"Donate", @"Donate")];
        [donateAlert addButtonWithTitle:NSLocalizedString(@"No Thanks", @"No Thanks")];
        NSInteger clickedButton = [donateAlert runModal];
        if(clickedButton == NSAlertFirstButtonReturn)
            [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6662868"]];
            
        // Let defaults know we requested donation today.
        [[NSUserDefaults standardUserDefaults] setObject: todaysDate forKey: @"lastDonateDate"];
    }
}

-(void) selectGameWithRegistryIndex: (NSInteger)index {
    NSMenu* mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu* gameMenu = [[mainMenu itemWithTitle: NSLocalizedStringWithDefaultValue(@"377.title", @"MainMenu", [NSBundle mainBundle], @"Game", @"Class = \"NSMenuItem\"; title = \"Game\"; ObjectID = \"377\";")] submenu];
    
    // Clear the check from the old game.
    if(game_ != nil) {
        NSMenuItem* currentGameItem = [gameMenu itemWithTitle: [game_ localizedName]];
        [currentGameItem setState: NSControlStateValueOff];
    }
    
    // Set the new game as the active game.
    NSMenuItem* newGameItem = [gameMenu itemAtIndex: index];
    [newGameItem setState: NSControlStateValueOn];

    game_ = [gameRegistry_ objectAtIndex: index];
    
    // Register game with defaults
    [[NSUserDefaults standardUserDefaults] setInteger: index forKey: @"selectedGameIndex"];
    
    // Put the name of the game in the title of the window.
    if (@available(macOS 11.0, *)) {
        self.window.subtitle = [game_ localizedName];
    } else {
        [self.window setTitle: [NSString stringWithFormat: @"Solitaire Greatest Hits: %@", [game_ localizedName]]];
    }
}


@end
