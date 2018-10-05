//
//  SolitaireGame.h
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
#import "SolitaireCardContainer.h"

@class SolitaireView;
@class SolitaireCard;
@class SolitaireTableau;
@class SolitaireFoundation;
@class SolitaireCell;
@class SolitaireWaste;
@class SolitaireStock;

@interface SolitaireGame : NSObject {
@private
    SolitaireView* view_;
}

-(id) initWithView: (SolitaireView*)view;
-(SolitaireView*) view;
-(void) initializeGame;
-(void) startGame;
-(void) viewResized:(NSSize)size;
-(BOOL) didWin;
-(BOOL) didLose;
-(void) reset;
-(NSInteger) cardsInPlay;

-(BOOL) canDropCard: (SolitaireCard*) card inContainer: (SolitaireCardContainer*) container;
-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation;
-(BOOL) canDropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell;

-(void) dropCard: (SolitaireCard*) card inContainer: (SolitaireCardContainer*) container;
-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(void) dropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation;
-(void) dropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell;

-(void) dropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste; // Used by the undo manager.
-(void) dropCard: (SolitaireCard*) card inStock: (SolitaireStock*) stock; // Used by the undo manager.

-(void) onCard: (SolitaireCard*) card removedFromContainer: (SolitaireCardContainer*) container;
-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau;
-(void) onCard: (SolitaireCard*) card removedFromFoundation: (SolitaireFoundation*) foundation;
-(void) onCard: (SolitaireCard*) card removedFromCell: (SolitaireCell*) cell; 

-(void) onGameWon;

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card;

@end
