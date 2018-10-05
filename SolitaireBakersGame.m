//
//  SolitaireBakersGame.m
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

#import "SolitaireBakersGame.h"
#import "SolitaireView.h"
#import "SolitaireCard.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireCell.h"
#import "SolitaireStock.h"

@implementation SolitaireBakersGame

-(NSString*) name {
    return @"Baker's Game";
}

-(void) dealNewGame {
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
               ([card.nextCard suit] != [card suit]) ||
               !card.nextCard.draggable) card.draggable = NO;
            pos--;
        }
    }
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([card countCardsStackedOnTop] > [self freeCellCount] + [self freeTableauCount]) return NO;
    else if([tableau isEmpty] && [card countCardsStackedOnTop] > [self freeCellCount] + [self freeTableauCount] - 1) return NO;

    if([tableau count] == 0) return YES;
    
    SolitaireCard* topCard = [tableau topCard];
    if(topCard.flipped) return NO;

    if(([card faceValue] == [topCard faceValue] - 1) && ([card suit] == [topCard suit]))
        return YES;
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    [super dropCard: card inTableau: tableau];
        
    int pos = [tableau count] - 2;
    while(pos >= 0) {
        SolitaireCard* card = [tableau cardAtPosition: pos];
        if(([card.nextCard faceValue] == [card faceValue] - 1) &&
            ([card.nextCard suit] == [card suit]) && card.nextCard.draggable) card.draggable = YES;
        else card.draggable = NO;
        pos--;
    }
}

-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau {
    int pos = [tableau count] - 2;
    while(pos >= 0) {
        SolitaireCard* card = [tableau cardAtPosition: pos];
        if(([card.nextCard faceValue] == [card faceValue] - 1) &&
            ([card.nextCard suit] == [card suit]) && card.nextCard.draggable) card.draggable = YES;
        else card.draggable = NO;
        pos--;
    }
}

@end
