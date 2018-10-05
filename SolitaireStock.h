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

@interface SolitaireStock : SolitaireSprite {
NSString* text;

@private
    NSMutableArray* deck_;
    NSInteger deckCount_;
    id delegate_;
}

@property(readwrite, copy) NSString* text;

-(id) initWithView: (SolitaireView*)gameView;
-(id) initWithView: (SolitaireView*)gameView withDeckCount: (NSInteger)deckCount;
-(id) delegate;
-(void) setDelegate: (id)delegate;
-(BOOL) isEmpty;
-(NSInteger) count;
-(NSArray*) cards;
-(void) reset;
-(void) shuffle;
-(void) restock;
-(void) addCard: (SolitaireCard*)card;
-(void) drawSprite;
-(void) spriteClicked: (NSUInteger)clickCount;

-(SolitaireCard*) dealCard;
-(void) dealCardToTableau: (SolitaireTableau*) tableau faceDown: (BOOL) flipped;
-(void) animateCardToTableau: (SolitaireTableau*) tableau;

@end
