//
//  SolitaireWaste.h
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

#import <Cocoa/Cocoa.h>
#import "SolitaireCardContainer.h"
#import "SolitaireView.h"
#import "SolitaireStock.h"

@class SolitaireCard;

// Abstract base class
@interface SolitaireWaste : SolitaireCardContainer <SolitaireStockDelegate> {
    BOOL acceptsDroppedCards;
}

@property(readwrite) BOOL acceptsDroppedCards;

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount;
-(void) onRefillStock: (SolitaireStock*)stock;
-(BOOL) canRefillStock;

@end

// Simple Waste is a single card waste.
@interface SolitaireSimpleWaste : SolitaireWaste

-(void) addCard: (SolitaireCard*) card;
-(void) removeCard: (SolitaireCard*) card;
-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount;
-(void) onRefillStock: (SolitaireStock*)stock;

@end

// Multi-Card Waste draws multiple cards but hides previously visible cards.
@interface SolitaireMultiCardWaste : SolitaireWaste {    
@public
    NSMutableArray* visibleCards;
    
@private
    NSInteger drawCount_;
    NSInteger currentPos_;
}

@property(copy, readonly) NSMutableArray* visibleCards;

-(id) initWithDrawCount: (NSInteger)drawCount;
-(id) initWithCoder: (NSCoder*) decoder;
-(void) encodeWithCoder: (NSCoder*) encoder;

-(CGPoint) topLocation;
-(CGPoint) nextLocation;
-(void) addCard: (SolitaireCard*) card;
-(void) removeCard: (SolitaireCard*) card;
-(CGFloat) cardHorizSpacing;

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount;
-(void) onRefillStock: (SolitaireStock*)stock;

@end
