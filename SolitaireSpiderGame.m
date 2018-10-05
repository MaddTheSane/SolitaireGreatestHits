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
#import "SolitaireCard.h"
#import "SolitaireStock.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"

// Private Methods
@interface SolitaireSpiderGame(NSObject)
-(void) returnCards: (NSArray*)cards toStock: (SolitaireStock*)stock;
@end

@implementation SolitaireSpiderGame

-(id) initWithView: (SolitaireView*)view {
    if((self = [super initWithView: view]) != nil) {
        [self reset];
    }
    return self;
}

-(void) initializeGame {    
    CGFloat viewWidth = [[self view] frame].size.width;
    CGFloat viewHeight = [[self view] frame].size.height;
    
    // Init Stock
    stock_ = [[SolitaireStock alloc] initWithView: [self view] withDeckCount: 2];
    stock_.position = CGPointMake(viewWidth / 25.0f, (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f);
    stock_.text = @"Empty";
    stock_.reclickDelay = 2.5;
    [stock_ setDelegate: self];
    [[self view] addSprite: stock_];
    
    // Init Foundations
    int i;
    CGFloat foundationX = viewWidth - CARD_WIDTH - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f;

    for(i = 7; i >= 0; i--) {
        foundation_[i] = [[SolitaireFoundation alloc] initWithView: [self view]];
        foundation_[i].position = CGPointMake(foundationX - i * (8.0f / 7.0f * CARD_WIDTH), foundationY);
        [[self view] addSprite: foundation_[i]];
    }
    
    // Init Tableau
    CGFloat tableauX = viewWidth / 75.0f;
    CGFloat tableauY = foundationY - (3.0f / 2.0f * CARD_HEIGHT) - viewHeight / 75.0f;
    CGFloat tableauSpacing = (viewWidth - 10 * CARD_WIDTH - 2 * (viewWidth / 75.0f)) / 9.0f;

    for(i = 0; i < 10; i++) {
        tableau_[i] = [[SolitaireTableau alloc] initWithView: [self view]];
        tableau_[i].position = CGPointMake(tableauX + i * (CARD_WIDTH + tableauSpacing), tableauY);
        tableau_[i].delegate = self;
        [[self view] addSprite: tableau_[i]];
    }
}

-(void) startGame {
    [self dealCards];
    [[self view] setNeedsDisplay: YES];
}

-(void) viewResized:(NSSize)size {
    CGFloat viewWidth = size.width;
    if(viewWidth < 11.0f * CARD_WIDTH) viewWidth = 11.0f * CARD_WIDTH;
    
    CGFloat viewHeight = size.height;
    
    // Init Stock
    stock_.position = CGPointMake(viewWidth / 25.0f, (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f);
    
    // Init Foundations
    int i;
    CGFloat foundationX = viewWidth - CARD_WIDTH - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f;

    for(i = 7; i >= 0; i--) {
        foundation_[i].position = CGPointMake(foundationX - i * (8.0f / 7.0f * CARD_WIDTH), foundationY);
    }
    
    // Init Tableau
    CGFloat tableauX = viewWidth / 75.0f;
    CGFloat tableauY = foundationY - (3.0f / 2.0f * CARD_HEIGHT) - viewHeight / 75.0f;
    CGFloat tableauSpacing = (viewWidth - 10 * CARD_WIDTH - 2 * (viewWidth / 75.0f)) / 9.0f;

    for(i = 0; i < 10; i++) {
        tableau_[i].position = CGPointMake(tableauX + i * (CARD_WIDTH + tableauSpacing), tableauY);
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

-(void) dealCards {
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
    // Tell the undo manager how to undo this operation.
    NSArray* stockCards = [stock cards];
    NSArray* topCards;
    
    if([stockCards count] <= 10) topCards = stockCards;
    else topCards = [stockCards objectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange([stockCards count] - 10, 10)]];
    [[[[self view] undoManager] prepareWithInvocationTarget: self] returnCards: topCards toStock: stock_];
    
    // Deal the cards
    int i;
    for(i = 0; i < 10; i++) {
        if(![stock_ isEmpty]) { 
            [stock performSelector: @selector(animateCardToTableau:) withObject: tableau_[i] afterDelay: 0.25 * i];
        }
    }
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([tableau count] == 0) return YES;
    
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
    SolitaireCard* stackedCard = card;
    while(stackedCard != nil) {
        SolitaireCard* nextCard = stackedCard.nextCard;
        stackedCard.nextCard = nil;
        stackedCard.draggable = NO;
        //stackedCard.position = foundation.position;
        [super dropCard: stackedCard inFoundation: foundation];
        stackedCard = nextCard;
    }
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
-(void) returnCards: (NSArray*)cards toStock: (SolitaireStock*)stock {
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithFloat: 1.0f] forKey: kCATransactionAnimationDuration];
    for(SolitaireCard* card in cards) {
        [card.container removeCard: card];
        [stock_ addCard: card];
    }
    [CATransaction commit];
    [stock_ setNeedsDisplay];
}

@end
