//
//  SolitaireCardStack.m
//  Solitaire
//
//  Created by Daniel Fontaine on 6/20/08.
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

#import "SolitaireTableau.h"
#import "SolitaireView.h"
#import "SolitaireCard.h"

@implementation SolitaireTableau

@synthesize acceptsDroppedCards;

-(id) init {
    if((self = [super init]) != nil) {
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth + 4, kCardHeight + 4);
        self.acceptsDroppedCards = YES;
    }
    return self;
}

-(id) initWithCoder: (NSCoder*) decoder {
    if((self = [super initWithCoder: decoder]) != nil) {
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth + 4, kCardHeight + 4);
        self.acceptsDroppedCards = [decoder decodeBoolForKey: @"acceptsDroppedCards"];
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) encoder {
    [super encodeWithCoder: encoder];
    [encoder encodeBool: self.acceptsDroppedCards forKey: @"acceptsDroppedCards"];
}

-(BOOL) isEmpty {
    return [cards_ count] == 0;
}

-(CGPoint) topLocation {    
    int k;
    CGPoint location = self.position;
    if([self count] < 2) return location;
    
    for(k = 0; k < [self count] - 1; k++) {
        SolitaireCard* card = [cards_ objectAtIndex: k];
        if(card.flipped) location.y -= [self cardFlippedVertSpacing];
        else location.y -= [self cardVertSpacing];
    }
    return location;
}

-(CGPoint) nextLocation {
    CGPoint location = [self topLocation];
    if([self count] > 0) {
        SolitaireCard* card = [self topCard];
        if(card.flipped) location.y -= [self cardFlippedVertSpacing];
        else location.y -= [self cardVertSpacing];
    }
    return location;
}

-(CGFloat) cardVertSpacing {
    CGFloat spacing = kCardHeight / 5.0f;
    return spacing;
}

-(CGFloat) cardFlippedVertSpacing {
    CGFloat spacing = kCardHeight / 7.0f;
    return spacing;
}

-(SolitaireCard*) cardAtPosition: (NSInteger) index {
    return [cards_ objectAtIndex: index];
}

@end
