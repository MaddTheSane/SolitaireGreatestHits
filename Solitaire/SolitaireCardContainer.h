//
//  SolitaireCardContainer.h
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
#import "SolitaireSprite.h"

NS_ASSUME_NONNULL_BEGIN

@class SolitaireView;
@class SolitaireCard;

@interface SolitaireCardContainer : SolitaireSprite <NSCoding> {
    NSString* text;

@protected
    NSMutableArray* cards_;
}

@property(nonatomic, copy, nullable) NSString* text;

-(instancetype) init NS_DESIGNATED_INITIALIZER;
-(nullable instancetype) initWithCoder: (NSCoder*) decoder;
-(void) encodeWithCoder: (NSCoder*) encoder;

@property (readonly, copy) NSArray<SolitaireCard*> *cards;

@property (readonly) BOOL acceptsDroppedCards;
@property (readonly, nullable) SolitaireCard *topCard;
@property (readonly) CGPoint topLocation;
@property (readonly) CGPoint nextLocation;
@property (readonly) CGRect topRect;
@property (readonly) NSInteger count;
-(void) addCard: (SolitaireCard*) card;
-(void) removeCard: (SolitaireCard*) card;
-(BOOL) containsCard: (SolitaireCard*) card;
@property (readonly) CGFloat cardVertSpacing;
@property (readonly) CGFloat cardHorizSpacing;

-(void) onAddedToView: (SolitaireView*)gameView;

@end

NS_ASSUME_NONNULL_END
