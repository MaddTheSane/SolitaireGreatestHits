//
//  SolitaireCard.h
//  Solitaire
//
//  Created by Daniel Fontaine on 8/3/08.
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
#import <QuartzCore/CALayer.h>

#import "SolitaireSprite.h"

typedef NS_ENUM(int, SolitaireSuit) {
    SolitaireSuitDiamonds = 0,
    SolitaireSuitHearts = 1,
    SolitaireSuitSpades = 2,
    SolitaireSuitClubs = 3
};

typedef NS_ENUM(int, SolitaireFaceValue) {
    SolitaireValueAce = 0,
    SolitaireValue2 = 1,
    SolitaireValue3 = 2,
    SolitaireValue4 = 3,
    SolitaireValue5 = 4,
    SolitaireValue6 = 5,
    SolitaireValue7 = 6,
    SolitaireValue8 = 7,
    SolitaireValue9 = 8,
    SolitaireValue10 = 9,
    SolitaireValueJack = 10,
    SolitaireValueQueen = 11,
    SolitaireValueKing = 12
};

typedef NS_ENUM(int, SolitaireSuitColor) {
    SolitaireRed = 0,
    SolitaireBlack = 1
};

#define kCardWidth 79
#define kCardHeight 123

@class SolitaireView;
@class SolitaireCardContainer;

@interface SolitaireCard : SolitaireSprite <NSCoding, CAAnimationDelegate, CALayerDelegate> {
@public
    __unsafe_unretained SolitaireCard* nextCard;        // pointer to the card stacked on top of this one.
    BOOL flipped;                   // This variable indicates if the card is flipped to display its back side.
    BOOL draggable;
    BOOL dragging;
    __unsafe_unretained SolitaireCardContainer* container;
    CGPoint homeLocation;

@private
    SolitaireSuit suit_;
    SolitaireFaceValue faceValue_;
    NSImage* frontImage_;
    NSImage* backImage_;
}

@property(readwrite, assign) SolitaireCard* nextCard;
@property(readwrite) BOOL flipped;
@property(readwrite) BOOL draggable;
@property(readwrite) BOOL dragging;
@property(readwrite, assign) SolitaireCardContainer* container;
@property(readwrite) CGPoint homeLocation;

-(id) initWithSuit: (SolitaireSuit)suit faceValue: (SolitaireFaceValue)faceValue;
-(id) initWithCoder: (NSCoder*) decoder;
-(void) encodeWithCoder: (NSCoder*) encoder;

-(SolitaireFaceValue) faceValue;
-(SolitaireSuit) suit;
-(SolitaireSuitColor) suitColor;
-(NSString*) name;
-(NSString*) faceValueAbbreviation;

-(void) drawSprite;
-(void) spriteClicked: (NSUInteger)clickCount;
-(void) flipCard;
-(void) animateToPosition: (CGPoint)p afterDelay: (NSTimeInterval)delay;
-(void) animateToPosition: (CGPoint)p andTransform: (CATransform3D)t afterDelay: (NSTimeInterval)delay;
-(NSInteger) countCardsStackedOnTop;
-(NSComparisonResult) compareFaceValue: (SolitaireCard*)card;



@end
