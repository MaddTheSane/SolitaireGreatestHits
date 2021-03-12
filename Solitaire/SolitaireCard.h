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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, SolitaireSuit) {
    SolitaireSuitDiamonds = 0,
    SolitaireSuitHearts = 1,
    SolitaireSuitSpades = 2,
    SolitaireSuitClubs = 3
} NS_SWIFT_NAME(SolitaireCard.Suit);

typedef NS_ENUM(int, SolitaireFaceValue) {
    SolitaireValueAce NS_SWIFT_NAME(ace) = 0,
    SolitaireValue2 NS_SWIFT_NAME(two) = 1,
    SolitaireValue3 NS_SWIFT_NAME(three) = 2,
    SolitaireValue4 NS_SWIFT_NAME(four) = 3,
    SolitaireValue5 NS_SWIFT_NAME(five) = 4,
    SolitaireValue6 NS_SWIFT_NAME(six) = 5,
    SolitaireValue7 NS_SWIFT_NAME(seven) = 6,
    SolitaireValue8 NS_SWIFT_NAME(eight) = 7,
    SolitaireValue9 NS_SWIFT_NAME(nine) = 8,
    SolitaireValue10 NS_SWIFT_NAME(ten) = 9,
    SolitaireValueJack NS_SWIFT_NAME(jack) = 10,
    SolitaireValueQueen NS_SWIFT_NAME(queen) = 11,
    SolitaireValueKing NS_SWIFT_NAME(king) = 12
} NS_SWIFT_NAME(SolitaireCard.FaceValue);

typedef NS_ENUM(int, SolitaireSuitColor) {
    SolitaireRed = 0,
    SolitaireBlack = 1
} NS_SWIFT_NAME(SolitaireCard.SuitColor);

#define kCardWidth 79
#define kCardHeight 123

void LoadFlippedCardImage(BOOL reload);

@class SolitaireView;
@class SolitaireCardContainer;

@interface SolitaireCard : SolitaireSprite <NSSecureCoding, CAAnimationDelegate, CALayerDelegate> {
@public
    __weak SolitaireCard* nextCard;        // pointer to the card stacked on top of this one.
    BOOL flipped;                   // This variable indicates if the card is flipped to display its back side.
    BOOL draggable;
    BOOL dragging;
    __weak SolitaireCardContainer* container;
    CGPoint homeLocation;

@private
    SolitaireSuit suit_;
    SolitaireFaceValue faceValue_;
    NSImage* frontImage_;
}

//! pointer to the card stacked on top of this one.
@property(readwrite, weak) SolitaireCard* nextCard;
//! This variable indicates if the card is flipped to display its back side.
@property(readwrite, getter=isFlipped) BOOL flipped;
@property(readwrite) BOOL draggable;
@property(readwrite) BOOL dragging;
@property(readwrite, weak) SolitaireCardContainer* container;
@property(readwrite) CGPoint homeLocation;

-(instancetype) initWithSuit: (SolitaireSuit)suit faceValue: (SolitaireFaceValue)faceValue;
-(nullable instancetype) initWithCoder: (NSCoder*) decoder;
-(void) encodeWithCoder: (NSCoder*) encoder;

@property (readonly) SolitaireFaceValue faceValue;
@property (readonly) SolitaireSuit suit;
@property (readonly) SolitaireSuitColor suitColor;
//-(NSString*) name;
@property (readonly, copy) NSString *faceValueAbbreviation;

-(void) drawSprite;
-(void) spriteClicked: (NSUInteger)clickCount;
-(void) flipCard;
-(void) animateToPosition: (CGPoint)p afterDelay: (NSTimeInterval)delay;
-(void) animateToPosition: (CGPoint)p andTransform: (CATransform3D)t afterDelay: (NSTimeInterval)delay;
-(NSInteger) countCardsStackedOnTop;
-(NSComparisonResult) compareFaceValue: (SolitaireCard*)card;



@end

NS_ASSUME_NONNULL_END
