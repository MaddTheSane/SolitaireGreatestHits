//
//  SolitaireStock.h
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

#import <Cocoa/Cocoa.h>
#import "SolitaireSprite.h"

@class SolitaireCard;
@class SolitaireView;
@class SolitaireTableau;
@class SolitaireStock;

@protocol SolitaireStockDelegate
-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount;
-(void) onRefillStock: (SolitaireStock*)stock;
-(BOOL) canRefillStock;
@end

@interface SolitaireStock : SolitaireSprite <NSCoding> {
@public
    BOOL disableRestock;
    NSTimeInterval reclickDelay;

@private
    NSMutableArray* deck_;
    NSInteger deckCount_;
    BOOL blockReclick_;
    id delegate_;
    
    NSImage* reloadImage_;
    NSImage* emptyImage_;
}

@property(readwrite) BOOL disableRestock;
@property(readwrite) NSTimeInterval reclickDelay;

-(id) init;
-(id) initWithDeckCount: (NSInteger)deckCount;
-(id) initWithCoder: (NSCoder*) decoder;
-(void) encodeWithCoder: (NSCoder*) encoder;

-(id) delegate;
-(void) setDelegate: (id)delegate;
-(BOOL) isEmpty;
-(NSInteger) count;
-(NSArray*) cards;
-(void) reset;
-(void) shuffle;
-(void) restock;
-(void) addCard: (SolitaireCard*)card;
-(void) removeCard: (SolitaireCard*)card;
-(void) removeCards: (NSArray*)cards;
-(void) drawSprite;
-(void) spriteClicked: (NSUInteger)clickCount;
-(void) onAddedToView: (SolitaireView*)gameView;

-(SolitaireCard*) dealCard;
-(void) dealCardToTableau: (SolitaireTableau*) tableau faceDown: (BOOL) flipped;
-(void) animateCardToTableau: (SolitaireTableau*) tableau;

@end
