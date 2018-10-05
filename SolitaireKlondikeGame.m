//
//  SolitaireKlondikeGame.m
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

#import "SolitaireKlondikeGame.h"
#import "SolitaireView.h"
#import "SolitaireCard.h"
#import "SolitaireStock.h"
#import "SolitaireWaste.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireCell.h"

@implementation SolitaireKlondikeGame

-(id) initWithView: (SolitaireView*)view {
    if((self = [super initWithView: view]) != nil) {
        [self reset];
    }
    return self;
}

-(void) initializeGame {    
    CGFloat viewWidth = [self view].layer.frame.size.width;
    CGFloat viewHeight = [self view].layer.frame.size.height;
    
    // Init Stock
    stock_ = [[SolitaireStock alloc] initWithView: [self view]];
    stock_.position = CGPointMake(viewWidth / 25.0f, (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f);
    [[self view] addSprite: stock_];
    
    // Init Waste
    waste_ = [[SolitaireWaste alloc] initWithView: [self view]];
    waste_.position = CGPointMake(stock_.frame.origin.x + 2.0f * CARD_WIDTH, stock_.frame.origin.y);
    [stock_ setDelegate: waste_];
    [[self view] addSprite: waste_];
    
    // Init Foundations
    int i;
    CGFloat foundationX = viewWidth - CARD_WIDTH - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        foundation_[i] = [[SolitaireFoundation alloc] initWithView: [self view]];
        foundation_[i].position = CGPointMake(foundationX - i * (3.0f / 2.0f * CARD_WIDTH), foundationY);
        [[self view] addSprite: foundation_[i]];
    }
    
    // Init Tableau
    CGFloat tableauX = viewWidth / 25.0f;
    CGFloat tableauY = foundationY - (3.0f / 2.0f * CARD_HEIGHT) - viewHeight / 25.0f;
    CGFloat tableauSpacing = (viewWidth - 7 * CARD_WIDTH - 2 * (viewWidth / 25.0f)) / 6.0f;

    for(i = 0; i < 7; i++) {
        tableau_[i] = [[SolitaireTableau alloc] initWithView: [self view]];
        tableau_[i].position = CGPointMake(tableauX + i * (CARD_WIDTH + tableauSpacing), tableauY);
        [tableau_[i] setTableauCharacter: 'K'];
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
    
    // Init Stock
    stock_.position = CGPointMake(viewWidth / 25.0f, (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f);
    
    // Init Waste
    waste_.position = CGPointMake(stock_.frame.origin.x + 2.0f * CARD_WIDTH, stock_.frame.origin.y);
    
    // Init Foundations
    int i;
    CGFloat foundationX = viewWidth - CARD_WIDTH - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - CARD_HEIGHT) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        foundation_[i].position = CGPointMake(foundationX - i * (3.0f / 2.0f * CARD_WIDTH), foundationY);
    }
    
    // Init Tableau
    CGFloat tableauX = viewWidth / 25.0f;
    CGFloat tableauY = foundationY - (3.0f / 2.0f * CARD_HEIGHT) - viewHeight / 25.0f;
    CGFloat tableauSpacing = (viewWidth - 7 * CARD_WIDTH - 2 * (viewWidth / 25.0f)) / 6.0f;

    for(i = 0; i < 7; i++) {
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
    //waste_ = nil;
    
    int i;
    //for(i = 3; i >= 0; i--) foundation_[i] = nil;
    for(i = 0; i < 7; i++) tableau_[i] = nil; 
}

-(NSInteger) cardsInPlay {
    NSInteger sum = 0;
    
    sum += [stock_ count];
    sum += [waste_ count];
    
    int i;
    for(i = 0; i < 7; i++) sum += [tableau_[i] count];
    for(i = 0; i < 4; i++) sum += [foundation_[i] count];
    
    return sum;
}

-(void) dealCards {
    int i, j;
    for(j = 1; j < 7; j++)
        for(i = j; i < 7; i++) [stock_ dealCardToTableau: tableau_[i] faceDown: YES];
    for(i = 0; i < 7; i++) [stock_ dealCardToTableau: tableau_[i] faceDown: NO];
}


-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {

    if([tableau count] == 0) {
        if([card faceValue] == SolitaireValueKing) return YES;
        return NO;
    }
    
    SolitaireCard* topCard = [tableau topCard];
    if(topCard.flipped) return NO;

    if(([card faceValue] == [topCard faceValue] - 1) && ([card suitColor] != [topCard suitColor]))
        return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    if([foundation count] == 0) {
        if([card faceValue] == SolitaireValueAce) return YES;
        return NO;
    }
    
    SolitaireCard* topCard = [foundation topCard];
    if([card suit] == [topCard suit] && [card faceValue] == [topCard faceValue] + 1) return YES;
    return NO;
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
