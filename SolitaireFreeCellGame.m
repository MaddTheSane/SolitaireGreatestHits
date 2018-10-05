//
//  SolitaireFreeCellGame.m
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

#import "SolitaireFreeCellGame.h"
#import "SolitaireView.h"
#import "SolitaireCard.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireCell.h"
#import "SolitaireStock.h"

@implementation SolitaireFreeCellGame

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
    stock_ = [[SolitaireStock alloc] initWithView: [self view]];
    
    // Init Foundations
    int i;
    CGFloat foundationX = viewWidth - CARD_WIDTH - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        foundation_[i] = [[SolitaireFoundation alloc] initWithView: [self view]];
        foundation_[i].position = CGPointMake(foundationX - i * (5.0f / 4.0f * CARD_WIDTH), foundationY);
        [[self view] addSprite: foundation_[i]];
    }
    
    // Init Cells
    CGFloat cellX = viewWidth / 25.0f;
    CGFloat cellY = (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        cell_[i] = [[SolitaireCell alloc] initWithView: [self view]];
        cell_[i].position = CGPointMake(cellX + i * (5.0f / 4.0f * CARD_WIDTH), cellY);
        [[self view] addSprite: cell_[i]];
    }
    
    // Init Tableau
    CGFloat tableauX = viewWidth / 25.0f;
    CGFloat tableauY = foundationY - (3.0f / 2.0f * CARD_HEIGHT) - viewHeight / 25.0f;
    CGFloat tableauSpacing = (viewWidth - 8 * CARD_WIDTH - 2 * (viewWidth / 25.0f)) / 7.0f;

    for(i = 0; i < 8; i++) {
        tableau_[i] = [[SolitaireTableau alloc] initWithView: [self view]];
        tableau_[i].position = CGPointMake(tableauX + i * (CARD_WIDTH + tableauSpacing), tableauY);
        [[self view] addSprite: tableau_[i]];
    }
}

-(void) startGame {
    [self dealCards];
    [[self view] setNeedsDisplay: YES];
}

-(void) viewResized:(NSSize)size {
    CGFloat viewWidth = size.width;
    if(viewWidth < 9.0f * CARD_WIDTH) viewWidth = 9.0f * CARD_WIDTH;
    
    CGFloat viewHeight = size.height;

    // Init Foundations
    int i;
    CGFloat foundationX = viewWidth - CARD_WIDTH - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        foundation_[i].position = CGPointMake(foundationX - i * (5.0f / 4.0f * CARD_WIDTH), foundationY);
    }
    
    // Init Cells
    CGFloat cellX = viewWidth / 25.0f;
    CGFloat cellY = (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        cell_[i].position = CGPointMake(cellX + i * (5.0f / 4.0f * CARD_WIDTH), cellY);
    }
    
    // Init Tableau
    CGFloat tableauX = viewWidth / 25.0f;
    CGFloat tableauY = foundationY - (3.0f / 2.0f * CARD_HEIGHT) - viewHeight / 25.0f;
    CGFloat tableauSpacing = (viewWidth - 8 * CARD_WIDTH - 2 * (viewWidth / 25.0f)) / 7.0f;

    for(i = 0; i < 8; i++) {
        tableau_[i].position = CGPointMake(tableauX + i * (CARD_WIDTH + tableauSpacing), tableauY);
    }
}

-(BOOL) didWin {
    int i;
    for(i = 3; i >= 0; i--) {
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
    for(i = 3; i >= 0; i--) foundation_[i] = nil;
    for(i = 3; i >= 0; i--) cell_[i] = nil;
    for(i = 0; i < 8; i++) tableau_[i] = nil; 
}

-(NSInteger) cardsInPlay {
    return 0;
}

-(void) dealCards {
    int pos = 0;
    while(![stock_ isEmpty]) {
        [stock_ dealCardToTableau: tableau_[pos] faceDown: NO];
        pos++;
        if(pos > 7) pos = 0;
    }
    
    int i;
    for(i = 0; i < 8; i++) {
        int pos = [tableau_[i] count] - 2;
        while(pos >= 0) {
            SolitaireCard* card = [tableau_[i] cardAtPosition: pos];
            if(([card.nextCard faceValue] != [card faceValue] - 1) ||
               ([card.nextCard suitColor] == [card suitColor]) ||
               !card.nextCard.draggable) card.draggable = NO;
            pos--;
        }
    }
}

-(NSInteger) freeCellCount {
    int i;
    NSInteger count = 0;
    for(i = 3; i >= 0; i--) {
        if([cell_[i] isEmpty]) count++;
    }
    return count;
}

-(NSInteger) freeTableauCount {
    int i;
    NSInteger count = 0;
    for(i = 0; i < 8; i++) {
        if([tableau_[i] isEmpty]) count++;
    }
    return count;
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([card countCardsStackedOnTop] > [self freeCellCount] + [self freeTableauCount]) return NO;
    else if([tableau isEmpty] && [card countCardsStackedOnTop] > [self freeCellCount] + [self freeTableauCount] - 1) return NO;

    if([tableau count] == 0) return YES;
    
    SolitaireCard* topCard = [tableau topCard];
    if(topCard.flipped) return NO;

    if(([card faceValue] == [topCard faceValue] - 1) && ([card suitColor] != [topCard suitColor]))
        return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    if([card countCardsStackedOnTop] > [self freeCellCount] + [self freeTableauCount]) return NO;

    if([foundation count] == 0) {
        if([card faceValue] == SolitaireValueAce) return YES;
        return NO;
    }
    
    SolitaireCard* topCard = [foundation topCard];
    if([card suit] == [topCard suit] && [card faceValue] == [topCard faceValue] + 1) return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell {
    if([cell isEmpty] && card.nextCard == nil) return YES;
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    [super dropCard: card inTableau: tableau];
        
    int pos = [tableau count] - 2;
    while(pos >= 0) {
        SolitaireCard* card = [tableau cardAtPosition: pos];
        if(([card.nextCard faceValue] == [card faceValue] - 1) &&
            ([card.nextCard suitColor] != [card suitColor]) && card.nextCard.draggable) card.draggable = YES;
        else card.draggable = NO;
        pos--;
    }

}

-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau {
    int pos = [tableau count] - 2;
    while(pos >= 0) {
        SolitaireCard* card = [tableau cardAtPosition: pos];
        if(([card.nextCard faceValue] == [card faceValue] - 1) &&
            ([card.nextCard suitColor] != [card suitColor]) && card.nextCard.draggable) card.draggable = YES;
        pos--;
    }
}

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card {
    int i;
    for(i = 3; i >= 0; i--)
        if(card.container == foundation_[i]) break;
        else if([self canDropCard: card inFoundation: foundation_[i]])
            return foundation_[i];
    return nil;
}

@end
