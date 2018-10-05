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

@interface SolitaireController : NSObject {
@public
    SolitairePreferencesController* preferences;

    IBOutlet NSWindow* window;
    IBOutlet SolitaireView* view;
    IBOutlet SolitaireTimer* timer;
    IBOutlet SolitaireScoreKeeper* scoreKeeper;

@private
    IBOutlet NSWindow* aboutWindow_;

    NSMutableArray* gameRegistry_;
    NSMutableDictionary* gameDictionary_;
    SolitaireGame* game_;
}

@property NSWindow* window;
@property SolitairePreferencesController* preferences;
@property SolitaireView* view;
@property SolitaireTimer* timer;
@property SolitaireScoreKeeper* scoreKeeper;

-(void) registerGames;
-(void) registerGame: (SolitaireGame*)game; 
-(NSArray*) availableGames;

-(void) newGame;
-(void) restartGame;
-(void) saveGameWithFilename: (NSString*)filename;
-(void) openGameWithFilename: (NSString*)filename;

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

-(SolitaireGame*) game;

@end
