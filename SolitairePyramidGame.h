//
//  SolitairePyramidGame.h
//  Solitaire
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
@class SolitaireWaste;
@class SolitaireTableau;
@class SolitaireFoundation;

@interface SolitairePyramidGame : SolitaireGame {
@protected
    SolitaireStock* stock_;
    SolitaireWaste* waste_[2];
    SolitaireTableau* tableau_[28];
    SolitaireFoundation* foundation_;
    
    BOOL playerDroppingCardInWaste_;
}

-(id) initWithController: (SolitaireController*)gameController;
-(void) initializeGame;
-(NSString*) name;
-(void) layoutGameComponents;
-(BOOL) didWin;
-(BOOL) didLose;
-(void) reset;
-(NSInteger) cardsInPlay;

// Scoring
-(BOOL) keepsScore;
-(NSInteger) initialScore;
-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer;

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage;
-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage;

-(void) dealNewGame;

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation;
-(BOOL) canDropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste;

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau;
-(void) dropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation;
-(void) dropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste;

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card;

@end
