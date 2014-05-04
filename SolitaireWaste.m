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

@implementation SolitaireWaste

@synthesize acceptsDroppedCards;

-(id) init {
    if((self = [super init]) != nil) {
        self.acceptsDroppedCards = NO;
    }
    return self;
}

-(void) drawSprite {}

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount { [self doesNotRecognizeSelector: _cmd]; }
-(void) onRefillStock: (SolitaireStock*)stock { [self doesNotRecognizeSelector: _cmd]; }

-(BOOL) canRefillStock {
    [self doesNotRecognizeSelector: _cmd];
    return NO;
}


@end

// Private Methods
@interface SolitaireSimpleWaste(NSObject)
-(void) dealCardFromStock: (SolitaireStock*)stock;
-(void) returnCard: (SolitaireCard*)card toStock: (SolitaireStock*)stock;
-(void) fillStock: (SolitaireStock*)stock;
-(void) fillWasteFromStock:(SolitaireStock*)stock;
@end

@implementation SolitaireSimpleWaste

-(void) addCard: (SolitaireCard*) card {
    NSInteger count = [cards_ count];
    if(count > 1) {
        SolitaireCard* hiddenCard = [cards_ objectAtIndex: count - 2];
        hiddenCard.hidden = YES;
    }
    [super addCard: card];
}

-(void) removeCard: (SolitaireCard*) card {
    [super removeCard: card];
    NSInteger count = [cards_ count];
    if(count > 1) {
        SolitaireCard* hiddenCard = [cards_ objectAtIndex: count - 2];
        hiddenCard.hidden = NO;
    }
}

// Stock delegate methods
-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount {
        [self dealCardFromStock: stock];
}

-(BOOL) canRefillStock {
    return [self count] > 1;
}

-(void) onRefillStock: (SolitaireStock*)stock {    
    [self fillStock: stock];
}

// Private Methods
-(void) dealCardFromStock: (SolitaireStock*)stock {
    SolitaireCard* card = [stock dealCard];
    
    if(card) {
        [CATransaction begin];
        [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
        card.position = stock.position;
        card.hidden = NO;
        [CATransaction commit];
        [CATransaction flush];
        
        [self addCard: card];
        card.position = card.homeLocation;
    
        // Tell the undo manager how to undo this move.
        [[[self.view undoManager] prepareWithInvocationTarget: self] returnCard: card toStock: stock];
    }
}

-(void) returnCard: (SolitaireCard*)card toStock: (SolitaireStock*)stock {
    [stock addCard: card];
    
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] dealCardFromStock: stock];
}

-(void) fillStock: (SolitaireStock*)stock {        
    // Remove Cards
    while([cards_ count] > 0) {
        SolitaireCard* card = [cards_ lastObject];        
        [super removeCard: card];
        [stock addCard: card];
    }
    [stock setNeedsDisplay];
    
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] fillWasteFromStock: stock];
}

-(void) fillWasteFromStock:(SolitaireStock*)stock {
    while([stock count] > 0) {
        SolitaireCard* card = [stock dealCard];
        [self addCard: card];
        [CATransaction begin];
        [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
        card.position = card.homeLocation;
        [CATransaction commit];
        if([stock count] <= 2) card.hidden = NO;
    }
    [stock setNeedsDisplay];
    
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] fillStock: stock];
}

@end

// Private Methods
@interface SolitaireMultiCardWaste(NSObject)
-(void) hideVisibleCards;
-(void) reorderCardSet: (NSArray*)cards;
-(void) dealCardsFromStock: (SolitaireStock*)stock;
-(void) returnVisibleCardsToStock: (SolitaireStock*)stock makeCardsVisible: (NSArray*)cards;
-(void) fillStock: (SolitaireStock*)stock;
-(void) fillWasteFromStock: (SolitaireStock*) stock makeCardsVisible: (NSArray*)cards;
@end

@implementation SolitaireMultiCardWaste

@synthesize visibleCards;

-(id) initWithDrawCount: (NSInteger)drawCount; {
    if((self = [super init]) != nil) {
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth, kCardHeight);
        
        drawCount_ = drawCount;
        currentPos_ = -1;
        visibleCards = [[NSMutableArray alloc] initWithCapacity: drawCount];
    }
    return self;
}

-(id) initWithCoder: (NSCoder*) decoder {
    if((self = [super initWithCoder: decoder]) != nil) {
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth, kCardHeight);

        drawCount_ = [decoder decodeIntForKey: @"drawCount_"];
        currentPos_ = [decoder decodeIntForKey: @"currentPos"];
        visibleCards = [decoder decodeObjectForKey: @"visibleCards"];
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) encoder {
    [super encodeWithCoder: encoder];
    [encoder encodeInt: drawCount_ forKey: @"drawCount_"];
    [encoder encodeInt: currentPos_ forKey: @"currentPos_"];
    [encoder encodeObject: self.visibleCards forKey: @"visibleCards"];
}

-(CGPoint) topLocation {
    if(currentPos_ == -1) return self.position;
    CGPoint location = self.position;
    location.x += currentPos_ * [self cardHorizSpacing];
    return location;
}

-(CGPoint) nextLocation {
    NSInteger nextPos = (currentPos_ + 1) % drawCount_;
    CGPoint location = self.position;
    location.x += nextPos * [self cardHorizSpacing];
    
    return location;
}

-(void) addCard: (SolitaireCard*) card { // Here we assume addCard is dropping a card into the current visible waste.
    if(currentPos_ >= drawCount_ - 1) [self hideVisibleCards];
    
    if([self topCard]) [self topCard].draggable = NO;
    
    [super addCard: card];
    card.draggable = YES;
    [self.visibleCards addObject: card];
    
    currentPos_ = (currentPos_ + 1) % drawCount_;
}

-(void) removeCard: (SolitaireCard*) card {
    [super removeCard: card];
    
    [self topCard].draggable = YES;
    if([self.visibleCards containsObject: card]) {
        [self.visibleCards removeObject: card];
    }
    
    currentPos_--;
    currentPos_ %= drawCount_;
}

-(CGFloat) cardHorizSpacing {
    return kCardWidth / 3.0f;
}

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount {
    [self dealCardsFromStock: stock];
}

-(BOOL) canRefillStock {
    return [self count] > drawCount_;
}

-(void) onRefillStock: (SolitaireStock*)stock {
    [self fillStock: stock];
}

// Private Methods
-(void) hideVisibleCards {
    if([self.visibleCards count] > 0) {
        [CATransaction begin];
        [CATransaction setValue: [NSNumber numberWithFloat: 1.0f] forKey: kCATransactionAnimationDuration];
        for(SolitaireCard* card in self.visibleCards) {
            card.hidden = YES;
            card.draggable = NO;
        }
        [CATransaction commit];
        [self.visibleCards removeAllObjects];
    
        currentPos_ = -1;
    }
}

-(void) reorderCardSet: (NSArray*)cards {
    int i;
    for(i = 0; i < [cards count]; i++) {
        currentPos_ = i - 1;
        SolitaireCard* card = [cards objectAtIndex: i];
        
        if(i == [cards count] - 1) card.draggable = YES;
        else card.draggable = NO;
        
        card.homeLocation = [self nextLocation];
        [CATransaction begin];
        [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
        card.position = card.homeLocation;
        [CATransaction commit];
    }
}

-(void) dealCardsFromStock: (SolitaireStock*)stock {
    NSArray* oldVisibleCards = [self.visibleCards copy];
    [self hideVisibleCards];
    
    int i;
    for(i = 0; i < drawCount_; i++) {
        if([stock isEmpty]) break;
        SolitaireCard* card = [stock dealCard];
        [CATransaction begin];
        [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
        card.position = stock.position;
        card.hidden = NO;
        [CATransaction commit];
        [CATransaction flush];

        [self addCard: card];
        card.position = card.homeLocation;
    }
    [stock display];
    
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] returnVisibleCardsToStock: stock makeCardsVisible: oldVisibleCards];
}

-(void) returnVisibleCardsToStock: (SolitaireStock*)stock makeCardsVisible: (NSArray*)cards {
    // Move visible cards into the stock    
    for(SolitaireCard* card in [self.visibleCards reverseObjectEnumerator]) {
            [self removeCard: card];
            [stock addCard: card];
    }
    [stock setNeedsDisplay];

    [self.visibleCards addObjectsFromArray: cards];
    [self reorderCardSet: self.visibleCards];
    for(SolitaireCard* card in self.visibleCards) card.hidden = NO;
    currentPos_ = [self.visibleCards count] - 1;
    
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] dealCardsFromStock: stock];
}

-(void) fillStock: (SolitaireStock*)stock {
    NSArray* oldVisibleCards = [self.visibleCards copy];
        
    // Remove Cards
    while([cards_ count] > 0) {
        SolitaireCard* card = [cards_ lastObject];
        [self removeCard: card];
        card.container = nil;
        [stock addCard: card];
    }
    [stock setNeedsDisplay];

    currentPos_ = -1;
    
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] fillWasteFromStock: stock makeCardsVisible: oldVisibleCards];
}

-(void) fillWasteFromStock: (SolitaireStock*) stock makeCardsVisible: (NSArray*)cards {  
    // Fill waste.
    while(![stock isEmpty]) {
        SolitaireCard* card = [stock dealCard];
        [super addCard: card];
    }
    [stock setNeedsDisplay];
    
    [self.visibleCards removeAllObjects];
    [self.visibleCards addObjectsFromArray: cards];
    [self reorderCardSet: self.visibleCards];
    for(SolitaireCard* card in self.visibleCards) card.hidden = NO;
    currentPos_ = [self.visibleCards count] - 1;
    
    // Tell the undo manager how to undo this move.
    [[[self.view undoManager] prepareWithInvocationTarget: self] fillStock: stock];
}

@end
