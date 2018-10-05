//
//  SolitairePyramidGame.m
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

#import "SolitairePyramidGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireStock.h"
#import "SolitaireWaste.h"

// Private methods
@interface SolitairePyramidGame(NSObject)
-(NSInteger) rowForCard: (SolitaireCard*)card;
-(NSArray*) cardsInRow: (NSInteger)row;
-(NSArray*) cardsCoveringCard: (SolitaireCard*)card;
-(NSArray*) cardsCoveredByCard: (SolitaireCard*)card;
@end

@implementation SolitairePyramidGame

-(id) initWithController: (SolitaireController*)gameController {
    if((self = [super initWithController: gameController]) != nil) {
        [self reset];
    }
    return self;
}

-(void) initializeGame {
    // Init Stock
    stock_ = [[SolitaireStock alloc] init];
    stock_.disableRestock = YES;
    [[self view] addSprite: stock_];
    
    // Init Wastes
    waste_[0] = [[SolitaireSimpleWaste alloc] init];
    waste_[0].acceptsDroppedCards = YES;
    [stock_ setDelegate: self];
    [[self view] addSprite: waste_[0]];
    
    waste_[1] = [[SolitaireSimpleWaste alloc] init];
    waste_[1].acceptsDroppedCards = YES;
    [[self view] addSprite: waste_[1]];
    
    // Init Foundation
    foundation_ = [[SolitaireFoundation alloc] init];
    [[self view] addSprite: foundation_];
        
    // Init Tableau
    int i, j;
    int index = 0;
    for(j = 1; j <= 7; j++) {
        for(i = 0; i < j; i++) {
            tableau_[index] = [[SolitaireTableau alloc] init];
            tableau_[index].hidden = YES;
            [[self view] addSprite: tableau_[index]];
            index++;
        }
    }
    
    playerDroppingCardInWaste_ = NO;
}

-(NSString*) name {
    return @"Pyramid";
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [[self view] frame].size.width;
    CGFloat viewHeight = [[self view] frame].size.height;

    // Layout Stock
    stock_.position = CGPointMake(kCardWidth / 3.0f, kCardHeight / 3.0f);
    
    // Layout Wastes
    waste_[0].position = CGPointMake(stock_.position.x + 2.0f * kCardWidth, stock_.position.y);
    waste_[1].position = CGPointMake(stock_.position.x + 3.5f * kCardWidth, stock_.position.y);
    
    // Layout Foundation
    foundation_.position = CGPointMake(viewWidth - 1.333 * kCardWidth, kCardHeight / 3.0f);
        
    // Layout Tableau
    CGFloat tableauX = viewWidth / 2.0f - kCardWidth / 2.0f;
    CGFloat tableauY = viewHeight - 5.0f / 4.0f * kCardHeight;

    int i, j;
    int index = 0;
    for(j = 1; j <= 7; j++) {
        for(i = 0; i < j; i++) {
            tableau_[index].position = CGPointMake(tableauX - (j - 1) * (2.0f/ 3.0f * kCardWidth) + i * (4.0f / 3.0f * kCardWidth),
                tableauY - (j - 1) * 1.0f / 3.0f * kCardHeight);
            tableau_[index].zPosition = j;
            index++;
        }
    }
}

-(BOOL) didWin {
    int i;
    for(i = 0; i < 28; i++)
        if(![tableau_[i] isEmpty]) return NO;
    return YES;
}

-(BOOL) didLose {
    return NO;
}

-(void) reset {
    stock_ = nil;
    foundation_ = nil;

    int i;
    for(i = 0; i < 2; i++) waste_[i] = nil;
    for(i = 0; i < 28; i++) tableau_[i] = nil;
}

-(NSInteger) cardsInPlay {
    return 0;
}

// Scoring
-(BOOL) keepsScore {
    return YES;
}

-(NSInteger) initialScore {
    return 140;
}

-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer {

    if ([fromContainer class] == [SolitaireTableau class] && [toContainer class] == [SolitaireFoundation class])
        return -5;

    return 0;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [super generateSavedGameImage]; 
         
    // Archive Stock
    [gameImage archiveGameObject: stock_ forKey: @"stock_"];
    
    // Archive Foundation
    [gameImage archiveGameObject: foundation_ forKey: @"foundation_"];
    
    // Archive Tableau
    int i;
    for(i = 0; i < 28; i++) {
        [gameImage archiveGameObject: tableau_[i] forKey: [NSString stringWithFormat: @"tableau_%i", i]];
    }
    
    // Archive waste
     for(i = 0; i < 2; i++) {
        [gameImage archiveGameObject: waste_[i] forKey: [NSString stringWithFormat: @"waste_%i", i]];
    }
    
    return gameImage;
}

-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage {
    [super loadSavedGameImage: gameImage];

    // Unarchive Stock
    stock_ = [gameImage unarchiveGameObjectForKey: @"stock_"];
    [stock_ setDelegate: self];
    [[self view] addSprite: stock_];
        
    // Unarchive Foundation
    foundation_ = [gameImage unarchiveGameObjectForKey: @"foundation_"];
    [[self view] addSprite: foundation_];
    
    // Unarchive Tableau
    int i;
    for(i = 0; i < 28; i++) {
        tableau_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"tableau_%i", i]];
        [[self view] addSprite: tableau_[i]];
    }
    
    // Unarchive waste
    for(i = 0; i < 2; i++) {
        waste_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"waste_%i", i]];
        [[self view] addSprite: waste_[i]];
    }
}

-(void) dealNewGame {
    int i;
    for(i = 0; i < 28; i++) {
        [stock_ dealCardToTableau: tableau_[i] faceDown: NO];
        if(i < 21) {
            [tableau_[i] topCard].draggable = NO;
            [tableau_[i] setAcceptsDroppedCards: NO];
        }
    }
}

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount {
    if([waste_[0] count] > 0) {
        SolitaireCard* topCardOnWaste = [waste_[0] topCard];
        [self dropCard: topCardOnWaste inContainer: waste_[1]];
        topCardOnWaste.position = topCardOnWaste.homeLocation;
    }
    
    [waste_[0] onStock: stock clicked: clickCount];
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([card.container isKindOfClass: [SolitaireFoundation class]]) return NO;

    if(![tableau isEmpty]) {
        if([[tableau topCard] faceValue] + [card faceValue] == 11)
            return YES;
    }
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    if([card faceValue] == SolitaireValueKing) return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste {
    if([card.container isKindOfClass: [SolitaireFoundation class]]) return NO;
    
    if([waste count] > 0) {
        if([[waste topCard] faceValue] + [card faceValue] == 11) {
            playerDroppingCardInWaste_ = YES;
            return YES;
        }
    }
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {    
    if([tableau isEmpty]) { // This will be called by the undo manager.
        card.draggable = YES;
        [super dropCard: card inTableau: tableau];
        [tableau setAcceptsDroppedCards: YES];
        
        // Disable covered cards.
        NSArray* coveredCards = [self cardsCoveredByCard: card];
        for(SolitaireCard* coveredCard in coveredCards) {
            SolitaireTableau* coveredTableau = (SolitaireTableau*)coveredCard.container;
            [coveredTableau setAcceptsDroppedCards: NO];
            coveredCard.draggable = NO;
        }
        
        [foundation_ topCard].draggable = NO;
    }
    else {
        // Place cards into the foundation.
        SolitaireCard* topCard = [tableau topCard]; 
        [self dropCard: topCard inContainer: foundation_]; // 'topCard' is dropped in container so it is counted with the
        [self dropCard: card inFoundation: foundation_]; // undo manager. 'card' has already come through dropCard:inContainer:
    }                                                    // so we drop it directly in the foundation.
}

-(void) dropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    // Find cards that are covered by the two cards that will be removed.
    NSArray* coveredCards = [self cardsCoveredByCard: card];
    
    if([card.container isKindOfClass: [SolitaireTableau class]])
        [(SolitaireTableau*)card.container setAcceptsDroppedCards: NO];
    
    // Place cards into the foundation.
    [foundation_ addCard: card];
    card.position = card.homeLocation;
    
    // Enable uncovered cards
    for(SolitaireCard* coveredCard in coveredCards) {
        NSArray* coveringCards = [self cardsCoveringCard: coveredCard];
        if([coveringCards count] == 0) {
            coveredCard.draggable = YES;
            [(SolitaireTableau*)coveredCard.container setAcceptsDroppedCards: YES];
        }
    }    
}

-(void) dropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste {
    card.draggable = YES;
    if(playerDroppingCardInWaste_) {
        // Place cards into the foundation.
        SolitaireCard* topCard = [waste topCard]; 
        [self dropCard: topCard inContainer: foundation_]; // 'topCard' is dropped in container so it is counted with the
        [self dropCard: card inFoundation: foundation_];   // undo manager. 'card' has already come through dropCard:inContainer:
                                                           // so we drop it directly in the foundation.
        playerDroppingCardInWaste_ = NO;
        return;
    }
    [super dropCard: card inWaste: waste];
}

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card {
    if(card && [card faceValue] == SolitaireValueKing) return foundation_;
    return nil;
}

// Private methods
-(NSInteger) rowForCard: (SolitaireCard*)card {
    int i, j;
    int index = 0;
    for(j = 1; j <= 7; j++) {
        for(i = 0; i < j; i++) {
            if(card == [tableau_[index] topCard]) return j - 1;
            index++;
        }
    }
    return -1;
}

-(NSArray*) cardsInRow: (NSInteger)row {
    if(row > 6 || row < 0) return nil;
    
    NSMutableArray* rowCards = [[NSMutableArray alloc] initWithCapacity: 8];
    int i, j;
    int index = 0;
    for(j = 1; j <= 7; j++) {
        for(i = 0; i < j; i++) {
            if(row == j - 1) {
                if(![tableau_[index] isEmpty]) [rowCards addObject: [tableau_[index] topCard]];
                else [rowCards addObject: [NSNull null]];
            } 
            index++;
        }
    }
    return rowCards;
}

-(NSArray*) cardsCoveringCard: (SolitaireCard*)card {
    NSInteger rowNumber = [self rowForCard: card];
    if(rowNumber != -1) {
        if(rowNumber == 6) return [NSArray array];
        NSArray* cardRow = [self cardsInRow: rowNumber];
        NSInteger cardIndex = [cardRow indexOfObject: card];
        NSArray* nextRow = [self cardsInRow: rowNumber + 1];
        
        NSMutableArray* coveringCards = [[NSMutableArray alloc] initWithCapacity: 2];
        if([nextRow objectAtIndex: cardIndex] != [NSNull null]) [coveringCards addObject: [nextRow objectAtIndex: cardIndex]];
        if([nextRow objectAtIndex: cardIndex+1] != [NSNull null]) [coveringCards addObject: [nextRow objectAtIndex: cardIndex+1]];
        return coveringCards;
    }
    return nil;
}

-(NSArray*) cardsCoveredByCard: (SolitaireCard*)card {
    NSInteger rowNumber = [self rowForCard: card];
    if(rowNumber != -1) {
        if(rowNumber == 0) return [NSArray array];
        NSArray* cardRow = [self cardsInRow: rowNumber];
        NSInteger cardIndex = [cardRow indexOfObject: card];
        NSArray* previousRow = [self cardsInRow: rowNumber - 1];
        
        NSMutableArray* coveredCards = [[NSMutableArray alloc] initWithCapacity: 2];
        if(cardIndex > 0 && [previousRow objectAtIndex: cardIndex - 1] != [NSNull null])
            [coveredCards addObject: [previousRow objectAtIndex: cardIndex - 1]];
        if(cardIndex < [previousRow count] && [previousRow objectAtIndex: cardIndex] != [NSNull null]) 
            [coveredCards addObject: [previousRow objectAtIndex: cardIndex]];
        return coveredCards;
    }
    return nil;
}

@end
