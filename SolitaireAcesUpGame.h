//
//  SolitaireAcesUpGame.h
//  Solitaire
//
//  Created by Daniel Fontaine on 7/7/09.
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
@class SolitaireCard;
@class SolitaireStock;
@class SolitaireTableau;
@class SolitaireFoundation;

@interface SolitaireAcesUpGame : SolitaireGame {
    SolitaireStock* stock_;
    SolitaireTableau* tableau_[4];
    SolitaireFoundation* foundation_;
}

-(id) initWithController: (SolitaireController*)gameController;
-(NSString*) name;
-(void) initializeGame;
-(void) layoutGameComponents;
-(BOOL) didWin;
-(BOOL) didLose;
-(void) reset;

// Scoring
-(BOOL) keepsScore;
-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer;
-(NSInteger) scoreForCardFlipped: (SolitaireCard*)card;

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage;
-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage;

-(void) dealNewGame;

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation;

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card;

@end
