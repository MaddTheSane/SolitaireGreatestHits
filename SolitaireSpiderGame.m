//
//  SolitaireSpiderGame.m
//  Solitaire
//
//  Created by Daniel Fontaine on 7/26/08.
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

#import "SolitaireSpiderGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireStock.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireScoreKeeper.h"

// Private Methods
@interface SolitaireSpiderGame(NSObject)
-(void) dealMoreCardsFromStock: (SolitaireStock*)stock animated: (BOOL)animate;
-(void) returnCards: (NSArray*)cards toStock: (SolitaireStock*)stock;
@end

@implementation SolitaireSpiderGame

-(id) initWithController: (SolitaireController*)gameController {
    if((self = [super initWithController: gameController]) != nil) {
        [self reset];
    }
    return self;
}

-(void) initializeGame {    
    // Init Stock
    stock_ = [[SolitaireStock alloc] initWithDeckCount: 2];
    stock_.reclickDelay = 2.5f;
    [stock_ setDelegate: self];
    [[self view] addSprite: stock_];
    
    // Init Foundations
    int i;
    for(i = 7; i >= 0; i--) {
        foundation_[i] = [[SolitaireFoundation alloc] init];
        [[self view] addSprite: foundation_[i]];
    }
    
    // Init Tableau
    for(i = 0; i < 10; i++) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        tableau_[i].delegate = self;
        [[self view] addSprite: tableau_[i]];
    }
}

-(NSString*) name {
    return @"Spider";
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [self view].frame.size.width;
    if(viewWidth < 11.0f * kCardWidth) viewWidth = 11.0f * kCardWidth;
    
    CGFloat viewHeight = [self view].frame.size.height;
    
    // Layout Stock
    stock_.position = CGPointMake(viewWidth / 25.0f, (viewHeight - kCardHeight) - viewHeight / 25.0f);
    
    // Layout Foundations
    int i;
    CGFloat foundationX = viewWidth - kCardWidth - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - kCardHeight) - viewHeight / 25.0f;

    for(i = 7; i >= 0; i--) {
        foundation_[i].position = CGPointMake(foundationX - i * (8.0f / 7.0f * kCardWidth), foundationY);
    }
    
    // Layout Tableau
    CGFloat tableauX = viewWidth / 75.0f;
    CGFloat tableauY = foundationY - (5.0f / 4.0f * kCardHeight);
    CGFloat tableauSpacing = (viewWidth - 10 * kCardWidth - 2 * (viewWidth / 75.0f)) / 9.0f;

    for(i = 0; i < 10; i++) {
        tableau_[i].position = CGPointMake(tableauX + i * (kCardWidth + tableauSpacing), tableauY);
    }
}

-(BOOL) didWin {
    int i;
    for(i = 7; i >= 0; i--) {
        if(![foundation_[i] isFilled]) return NO;
    }
    return YES;
}

-(BOOL) didLose {
    return NO;
}

-(void) reset {
    stock_ = nil;
    
    int i;
    for(i = 7; i >= 0; i--) foundation_[i] = nil;
    for(i = 0; i < 10; i++) tableau_[i] = nil;
}

-(BOOL) keepsScore {
    return YES;
}

-(NSInteger) initialScore {
    return 500;
}

-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer {
    
    if([toContainer isKindOfClass: [SolitaireFoundation class]] && [card faceValue] == SolitaireValueKing) return 100;
    return -1;
}
    
-(NSInteger) scoreForCardFlipped: (SolitaireCard*)card {
    return 0;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [super generateSavedGameImage];        

    int i;
    // Archive Stock
    [gameImage archiveGameObject: stock_ forKey: @"stock_"];
    
    // Archive Foundations
    for(i = 0; i < 8; i++) {
        [gameImage archiveGameObject: foundation_[i] forKey: [NSString stringWithFormat: @"foundation_%i", i]];
    }
    
    // Archive Tableau
    for(i = 0; i < 10; i++) {
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
    
    // Unarchive Foundations
    int i;
    for(i = 0; i < 8; i++) {
        foundation_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"foundation_%i", i]];
        [[self view] addSprite: foundation_[i]];
    }
    
    // Unarchive Tableau
    for(i = 0; i < 10; i++) {
        tableau_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"tableau_%i", i]];
        [[self view] addSprite: tableau_[i]];
    }
}

-(void) dealNewGame {
    NSInteger cardsToDeal = 54;
    int pos = 0;
    while(cardsToDeal > 0) {
        if(cardsToDeal > 10) [stock_ dealCardToTableau: tableau_[pos] faceDown: YES];
        else [stock_ dealCardToTableau: tableau_[pos] faceDown: NO];
        pos = (pos + 1) % 10;
        cardsToDeal--;
    }
}

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount {
    [self dealMoreCardsFromStock: stock animated: YES];
}

-(BOOL) canRefillStock {
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([card.container isKindOfClass: [SolitaireFoundation class]]) return NO;
    else if([tableau count] == 0) return YES;
    
    SolitaireCard* topCard = [tableau topCard];
    if(topCard.flipped) return NO;

    if([card faceValue] == [topCard faceValue] - 1)
        return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    if([card countCardsStackedOnTop] == 12) return YES;
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    card.hidden = NO;
    [super dropCard: card inTableau: tableau];
    
    int pos = [tableau count] - 2;
    while(pos >= 0) {
        SolitaireCard* card = [tableau cardAtPosition: pos];
        if(([card.nextCard faceValue] != [card faceValue] - 1)  ||
           ([card.nextCard suit] != [card suit]) || !card.nextCard.draggable || card.flipped)
            card.draggable = NO;
        pos--;
    }
}

-(void) dropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    SolitaireCard* nextCard = card.nextCard;
    card.nextCard = nil;
    [super dropCard: card inFoundation: foundation];
    if(nextCard != nil) [self dropCard: nextCard inContainer: foundation];
}

-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau {
    int pos = [tableau count] - 2;
    while(pos >= 0) {
        SolitaireCard* stackedCard = [tableau cardAtPosition: pos];
        if(([stackedCard.nextCard faceValue] == [stackedCard faceValue] - 1) &&
            ([stackedCard.nextCard suit] == [stackedCard suit]) && stackedCard.nextCard.draggable)
            stackedCard.draggable = YES;
        pos--;
    }
}

// Private Methods
-(void) dealMoreCardsFromStock: (SolitaireStock*)stock animated: (BOOL)animate {
    NSArray* stockCards = [stock cards];
    NSArray* topCards;
    
    if([stockCards count] <= 10) topCards = stockCards;
    else topCards = [stockCards objectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange([stockCards count] - 10, 10)]];

    // Tell the undo manager how to undo this operation.
    [[[self.view undoManager] prepareWithInvocationTarget: self] returnCards: topCards toStock: stock_];
    
    // Deal the cards
    int i;
    for(i = 0; i < 10; i++) {
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
