//
//  SolitaireFreeCellGame.h
//  Solitaire
//
//  Created by Daniel Fontaine on 7/13/08.
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
@class SolitaireCell;

@interface SolitaireFreeCellGame : SolitaireGame {
@protected
    SolitaireStock* stock_;
    SolitaireTableau* tableau_[8];
    SolitaireFoundation* foundation_[4];
    SolitaireCell* cell_[4];
}

-(id) initWithController: (SolitaireController*)gameController;
-(void) initializeGame;
-(NSString*) name;
-(void) layoutGameComponents;
-(BOOL) didWin;
-(BOOL) didLose;
-(void) reset;
-(NSInteger) cardsInPlay;

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage;
-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage;

// Auto-finish
-(BOOL) supportsAutoFinish;
-(void) autoFinishGame;

-(void) dealNewGame;
-(NSInteger) freeCellCount;
-(NSInteger) freeTableauCount;

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation;
-(BOOL) canDropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell;

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau;

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card;

@end
