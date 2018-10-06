//
//  SolitaireController.h
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

#import <Cocoa/Cocoa.h>
#import "SolitaireGame.h"

@class SolitaireView;
@class SolitairePreferencesController;
@class SolitaireTimer;
@class SolitaireScoreKeeper;

@interface SolitaireController : NSObject <NSApplicationDelegate, NSToolbarDelegate>
{
@private
	IBOutlet NSWindow* aboutWindow_;
	IBOutlet NSTextView *infoView_;

    NSMutableArray<__kindof SolitaireGame*>* gameRegistry_;
    NSMutableDictionary<NSString*,__kindof SolitaireGame*>* gameDictionary_;
    SolitaireGame* game_;
}

@property (weak) IBOutlet NSWindow* window;
@property (strong) IBOutlet SolitairePreferencesController* preferences;
@property (weak) IBOutlet SolitaireView* view;
@property (weak) IBOutlet SolitaireTimer* timer;
@property (weak) IBOutlet SolitaireScoreKeeper* scoreKeeper;

-(void) registerGames;
-(void) registerGame: (SolitaireGame*)game; 
@property (readonly, copy) NSArray<__kindof SolitaireGame*> *availableGames;

-(void) newGame;
-(void) restartGame;
-(BOOL) saveGameToURL:(NSURL*)filename error:(NSError**)error;
-(BOOL) openGameFromURL:(NSURL*)filename error:(NSError**)error;

-(IBAction) onNewGame: (id)sender;
-(IBAction) onRestartGame: (id)sender;
-(IBAction) onSaveGame: (id)sender;
-(IBAction) onOpenGame: (id)sender;
-(IBAction) onPreferences: (id)sender;
-(IBAction) onChooseGame: (id)sender;
-(IBAction) onAbout: (id)sender;
-(IBAction) onGameSelected: (NSMenuItem*)sender;
-(IBAction) onInstructions: (id)sender;
-(IBAction) onAutoFinish: (id)sender;

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;

@property (readonly, strong) SolitaireGame *game;

@end
