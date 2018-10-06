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

@class SolitaireController;
@class SolitaireView;
@class SolitaireSavedGameImage;
@class SolitaireCard;
@class SolitaireTableau;
@class SolitaireFoundation;
@class SolitaireCell;
@class SolitaireWaste;
@class SolitaireStock;

NS_ASSUME_NONNULL_BEGIN

@interface SolitaireGame : NSObject {
@public
    __weak SolitaireController* controller;
    
@private
    NSUInteger gameSeed_;
}

@property(weak) SolitaireController* controller;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
-(instancetype) initWithController: (SolitaireController*)gameController NS_DESIGNATED_INITIALIZER;
@property (readonly, nullable) SolitaireView *view;
@property (readonly) NSString *name;
@property (readonly) NSString *localizedName;
@property (readonly) NSUInteger gameSeed;
-(void) gameWithSeed: (NSUInteger)seed;
-(void) initializeGame;
-(void) layoutGameComponents;
-(void) startGame;
@property (readonly) BOOL didWin;
@property (readonly) BOOL didLose;
-(void) reset;
@property (readonly) NSInteger cardsInPlay;

// Scoring
@property (readonly) BOOL keepsScore;
@property (readonly) NSInteger initialScore;
-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer;
-(NSInteger) scoreForCardFlipped: (SolitaireCard*)card;

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage NS_REQUIRES_SUPER;
-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage NS_REQUIRES_SUPER;

// Auto-finish
@property (readonly) BOOL supportsAutoFinish;
-(void) autoFinishGame;

-(void) dealNewGame;

-(BOOL) canDropCard: (SolitaireCard*) card inContainer: (SolitaireCardContainer*) container;
-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation;
-(BOOL) canDropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell;
-(BOOL) canDropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste;

-(void) dropCard: (SolitaireCard*) card inContainer: (SolitaireCardContainer*) container;
-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(void) dropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation;
-(void) dropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell;

-(void) dropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste;
-(void) dropCard: (SolitaireCard*) card inStock: (SolitaireStock*) stock;

-(void) onCard: (SolitaireCard*) card removedFromContainer: (nullable SolitaireCardContainer*) container;
-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau;
-(void) onCard: (SolitaireCard*) card removedFromFoundation: (SolitaireFoundation*) foundation;
-(void) onCard: (SolitaireCard*) card removedFromCell: (SolitaireCell*) cell; 

-(void) onGameWon;

-(nullable SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card;

@end

NS_ASSUME_NONNULL_END
