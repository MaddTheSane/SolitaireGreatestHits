//
//  SolitaireWaste.m
//  Solitaire
//
//  Created by Daniel Fontaine on 6/28/08.
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

#import "SolitaireWaste.h"
#import "SolitaireStock.h"
#import "SolitaireCard.h"

// Private Methods
@interface SolitaireWaste(NSObject)
-(void) hideVisibleCards;
-(void) fillWasteFromStock: (SolitaireStock*) stock makeCardsVisible: (NSMutableArray*)cards; // Used for Undo
-(void) returnVisibleCardsToStock: (SolitaireStock*)stock makeCardsVisible: (NSMutableArray*)cards; // Used for Undo
@end

@implementation SolitaireWaste

@synthesize visibleCards;

-(id) initWithView: (SolitaireView*)gameView {
    if((self = [super initWithView: gameView]) != nil) {
        self.frame = CGRectMake(0.0f, 0.0f, CARD_WIDTH, CARD_HEIGHT);
        visibleCards = nil;
    }
    return self;
}

-(BOOL) acceptsDroppedCards {
    return NO;
}

-(void) addCard: (SolitaireCard*) card { // Here we assume addCard is dropping a card into the current visible waste.
    [super addCard: card];
    [cards_ addObject: card];
    
    [[self.visibleCards lastObject] setDraggable: YES];
    [self.visibleCards addObject: card];
    card.draggable = YES;
    [self showCards: self.visibleCards animated: YES];
}

-(void) removeCard: (SolitaireCard*) card {
    [super removeCard: card];
    [cards_ removeObject: card];
    
    if([self.visibleCards containsObject: card]) {
        [self.visibleCards removeObject: card];
        [[self.visibleCards lastObject] setDraggable: YES];
    }
}

-(void) showCards: (NSMutableArray*)cards animated: (BOOL)animated {
    visibleCards = cards;

    [CATransaction begin];
    if(animated) [CATransaction setValue: [NSNumber numberWithFloat: 1.0f] forKey: kCATransactionAnimationDuration];
    else [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];            
    
    int pos = 0;
    for(SolitaireCard* card in self.visibleCards) {
        card.hidden = NO;
        card.draggable = NO;
        
        CGPoint location = self.frame.origin;
        location.x += pos * [self cardHorizSpacing];
        card.homeLocation = location;
        card.position = card.homeLocation;
        card.zPosition = pos + 1;
        pos++;
    }
    [CATransaction commit];
    
    [[self.visibleCards lastObject] setDraggable: YES];
}

-(CGFloat) cardHorizSpacing {
    return CARD_WIDTH / 3.0f;
}

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount {
    
    // Determine the message to be displayed at the bottom of the empty stock.
    if([stock count] <= 3) {
        if([cards_ count] == 0) stock.text = @"Empty";
        else stock.text = @"Reload";
    }
    
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] returnVisibleCardsToStock: stock makeCardsVisible: [self.visibleCards mutableCopy]];
    
    // Deal Cards to Waste.
    NSMutableArray* newCards = [[NSMutableArray alloc] initWithCapacity: 3];
    int i;
    for(i = 0; i < 3 && ![stock isEmpty]; i++) {
        SolitaireCard* card = [stock dealCard];
        if(card) {
            [CATransaction begin];
            [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];            
            card.position = stock.position;
            card.hidden = NO;
            [CATransaction commit];
            [CATransaction flush];
                                            
            [super addCard: card];
            [newCards addObject: card];
        }
    }
    [cards_ addObjectsFromArray: newCards];
    
    [self hideVisibleCards];
    [self showCards: newCards animated: YES];
}

-(void) onRefillStock: (SolitaireStock*)stock {
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] fillWasteFromStock: stock makeCardsVisible: [self.visibleCards mutableCopy]];
        
    // Remove Cards
    while([cards_ count] > 0) {
        SolitaireCard* card = [cards_ lastObject];
        [self removeCard: card];
        card.container = nil;
        [stock addCard: card];
    }
    [stock setNeedsDisplay];
}

-(void) hideVisibleCards {    
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithFloat: 1.0f] forKey: kCATransactionAnimationDuration];
    for(SolitaireCard* card in self.visibleCards) {
        if(card) {
            card.hidden = YES;
            card.draggable = NO;
            card.zPosition--;
        }
    }
    [CATransaction commit];
}

-(void) fillWasteFromStock: (SolitaireStock*) stock makeCardsVisible: (NSMutableArray*)cards {  
    // Fill waste.
    while(![stock isEmpty]) {
        SolitaireCard* card = [stock dealCard];
        [super addCard: card];
        [cards_ addObject: card];
    }
    [stock setNeedsDisplay];
        
    // Make cards visible
    [self showCards: cards animated: NO];
}

-(void) returnVisibleCardsToStock: (SolitaireStock*)stock makeCardsVisible: (NSMutableArray*)cards {
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithFloat: 0.36f] forKey: kCATransactionAnimationDuration];
    
    NSMutableArray* stockArray = self.visibleCards;
    
    // Make cards visible
    [self showCards: cards animated: NO];

    // Move visible cards into the stock    
    for(SolitaireCard* card in [stockArray reverseObjectEnumerator]) {
        if(card) {
            card.hidden = YES;
            card.draggable = NO;
            
            [self removeCard: card];
            [stock addCard: card];
        }
    }
    [stock setNeedsDisplay];
    
    [CATransaction commit];
}


@end
