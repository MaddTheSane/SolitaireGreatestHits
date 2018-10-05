//
//  SolitaireFoundation.m
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

#import "SolitaireFoundation.h"
#import "SolitaireCard.h"

@implementation SolitaireFoundation

-(id) init {
    if((self = [super init]) != nil) {
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth + 4, kCardHeight + 4);
    }
    return self;
}

-(BOOL) acceptsDroppedCards {
    return YES;
}

-(CGPoint) nextLocation {
    return [self topLocation];
}

-(void) addCard: (SolitaireCard*) card {
    // Hide card below top card.
    NSInteger count = [cards_ count];
    if(count > 1) {
        SolitaireCard* lowerCard = [cards_ objectAtIndex: count - 2]; 
        lowerCard.hidden = YES;
    }
    [super addCard: card];
}

-(void) removeCard: (SolitaireCard*) card {
    [cards_ removeObject: card];

    // Show card below top card.
    NSInteger count = [cards_ count];
    if(count > 1) {
        SolitaireCard* lowerCard = [cards_ objectAtIndex: count - 2]; 
        lowerCard.hidden = NO;
    }

    [super removeCard: card];
}

-(BOOL) isEmpty {
    return [cards_ count] == 0;
}

-(BOOL) isFilled {
    return [cards_ count] == 13;
}

@end
