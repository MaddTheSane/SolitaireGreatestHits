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

@interface SolitaireController : NSObject {

SolitairePreferencesController* preferences;

@private
    IBOutlet NSWindow* window_;
    IBOutlet SolitaireView* view_;

    IBOutlet NSMenuItem* klondikeGameItem_;
    IBOutlet NSMenuItem* spiderGameItem_;
    IBOutlet NSMenuItem* freeCellGameItem_;

    SolitaireGame* game_;
}

@property(assign) SolitairePreferencesController* preferences;

-(void) awakeFromNib;
-(void) windowDidBecomeKey: (NSNotification *)notification;
-(void) newGame;
-(IBAction) onNewGame: (id)sender;
-(IBAction) onPreferences: (id)sender;

-(IBAction) onKlondikeGame: (NSMenuItem*)sender;
-(IBAction) onFreeCellGame: (NSMenuItem*)sender;
-(IBAction) onSpiderGame: (NSMenuItem*)sender;

-(SolitaireGame*) game;

@end
