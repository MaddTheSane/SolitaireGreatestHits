//
//  SolitaireCell.m
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

#import "SolitaireCell.h"
#import "SolitaireCard.h"

@implementation SolitaireCell

-(id) init {
    if((self = [super init]) != nil) {
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth + 4, kCardHeight + 4);
    }
    return self;
}

-(BOOL) acceptsDroppedCards {
    return [self isEmpty];
}

-(void) addCard: (SolitaireCard*) card {
    [cards_ removeAllObjects];
    
    card.zPosition = 1;
    [card.container removeCard: card];
    card.container = self;
    [super addCard: card];
}

-(void) removeCard: (SolitaireCard*) card {
    [cards_ removeObject: card];
}

-(BOOL) isEmpty {
    return [cards_ count] == 0;
}

@end
