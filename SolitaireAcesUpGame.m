//
//  SolitaireAcesUpGame.m
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

#import "SolitaireAcesUpGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireStock.h"

// Private Methods
@interface SolitaireAcesUpGame(NSObject)
-(void) dealMoreCardsFromStock: (SolitaireStock*)stock animated: (BOOL)animate;
-(void) returnCards: (NSArray*)cards toStock: (SolitaireStock*)stock;
@end

@implementation SolitaireAcesUpGame

-(id) initWithController: (SolitaireController*)gameController {
    if((self = [super initWithController: gameController]) != nil) {
        [self reset];
    }
    return self;
}

-(void) initializeGame {
    // Init Stock
    stock_ = [[SolitaireStock alloc] init];
    stock_.reclickDelay = 1.0;
    [stock_ setDelegate: self];
    [[self view] addSprite: stock_];
    
    // Init Foundation
    foundation_ = [[SolitaireFoundation alloc] init];
    [[self view] addSprite: foundation_];
    
    // Init Tableau
    int i;
    for(i = 0; i < 4; i++) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        [[self view] addSprite: tableau_[i]];
    }
}

-(NSString*) name {
    return @"Aces Up";
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [[self view] frame].size.width;
    CGFloat viewHeight = [[self view] frame].size.height;
    CGFloat cardSpacing = (viewWidth - 8 * kCardWidth - 2 * (viewWidth / 25.0f)) / 7.0f;

    // Layout Stock
    stock_.position = CGPointMake((viewWidth - 6 * kCardWidth - 5 * cardSpacing) / 2.0, (viewHeight - 1.25 * kCardHeight));

    // Layout Foundation
    int i;
    CGFloat foundationX = stock_.position.x;
    CGFloat foundationY = stock_.position.y - 1.25 * kCardHeight;

    foundation_.position = CGPointMake(foundationX, foundationY);
    
    // Layout Tableau
    CGFloat tableauX = stock_.position.x;
    CGFloat tableauY = stock_.position.y;

    for(i = 0; i < 4; i++) {
        tableau_[i].position = CGPointMake(tableauX + (i + 2) * (kCardWidth + cardSpacing), tableauY);
    }
}

-(BOOL) didWin {
    if([foundation_ count] == 48) return YES;
    return NO;
}

-(BOOL) didLose {
    return NO;
}

-(void) reset {
    stock_ = nil;
    foundation_ = nil;

    int i;
    for(i = 0; i < 4; i++) tableau_[i] = nil; 
}

-(BOOL) keepsScore {
    return YES;
}

-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer {
    if([toContainer isKindOfClass: [SolitaireFoundation class]]) return 5;
    return 0;
}
    
-(NSInteger) scoreForCardFlipped: (SolitaireCard*)card {
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
    for(i = 0; i < 4; i++) {
        [gameImage archiveGameObject: tableau_[i] forKey: [NSString stringWithFormat: @"tableau_%i", i]];
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
    printf("%f, %f\n", foundation_.position.x, foundation_.position.y);
    
    // Unarchive Tableau
    int i;
    for(i = 0; i < 4; i++) {
        tableau_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"tableau_%i", i]];
        [[self view] addSprite: tableau_[i]];
    }
}

-(void) dealNewGame {
    int i;
    for(i = 0; i < 4; i++) {
        [stock_ dealCardToTableau: tableau_[i] faceDown: NO];
    }
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([tableau isEmpty]) return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    int i;
    for(i = 0; i < 4; i++) {
        SolitaireCard* topCard = [tableau_[i] topCard];
        if(card == topCard || [card faceValue] == SolitaireValueAce) continue;
        if([card suit] == [topCard suit] && 
            ([card faceValue] < [topCard faceValue] || [topCard faceValue] == SolitaireValueAce)) return YES;
    }
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    [tableau topCard].draggable = NO;
    [super dropCard: card inTableau: tableau];
}

-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau {

}

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card {
    if(card && [self canDropCard: card inFoundation: foundation_]) return foundation_;
    return nil;
}

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount {
    [self dealMoreCardsFromStock: stock animated: YES];
}

-(BOOL) canRefillStock {
    return NO;
}

// Private Methods
-(void) dealMoreCardsFromStock: (SolitaireStock*)stock animated: (BOOL)animate {
    NSArray* stockCards = [stock cards];
    NSArray* topCards;
    
    if([stockCards count] <= 4) topCards = stockCards;
    else topCards = [stockCards objectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange([stockCards count] - 4, 4)]];

    // Tell the undo manager how to undo this operation.
    [[[self.view undoManager] prepareWithInvocationTarget: self] returnCards: topCards toStock: stock_];
    
    // Deal the cards
    int i;
    for(i = 0; i < 4; i++) {
        if(![stock_ isEmpty]) { 
            if(animate) {
                [stock performSelector: @selector(animateCardToTableau:) withObject: tableau_[i] afterDelay: 0.25 * i];
            }
            else {
                SolitaireCard* card = [stock dealCard];
                
                [CATransaction begin];
                [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
                card.position = [tableau_[i] nextLocation];
                [CATransaction commit];
                [CATransaction flush];
                
                [self dropCard: card inTableau: tableau_[i]];
                card.hidden = NO;
            }
        }
    }
}

-(void) returnCards: (NSArray*)cards toStock: (SolitaireStock*)stock {
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithFloat: 1.0f] forKey: kCATransactionAnimationDuration];
    for(SolitaireCard* card in cards) {
        [stock_ addCard: card];
    }
    [CATransaction commit];
    [stock_ setNeedsDisplay];
    
    // Tell the undo manager how to undo this operation.
    [[[self.view undoManager] prepareWithInvocationTarget: self] dealMoreCardsFromStock: stock animated: NO];
}

@end
