//
//  SolitaireCardStack.h
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
#import "SolitaireCardContainer.h"

NS_ASSUME_NONNULL_BEGIN

@class SolitaireView; 
@class SolitaireCard;

@interface SolitaireTableau : SolitaireCardContainer {
    BOOL acceptsDroppedCards;
}

@property(readwrite) BOOL acceptsDroppedCards;

-(instancetype) init;
-(nullable instancetype) initWithCoder: (NSCoder*) decoder;
-(void) encodeWithCoder: (NSCoder*) encoder;

@property (readonly) BOOL isEmpty;
@property (readonly) CGPoint topLocation;
@property (readonly) CGPoint nextLocation;
@property (readonly) CGFloat cardVertSpacing;
@property (readonly) CGFloat cardFlippedVertSpacing;

-(SolitaireCard*) cardAtPosition: (NSInteger) index;

@end

NS_ASSUME_NONNULL_END
