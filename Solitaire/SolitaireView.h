//
//  SolitaireView.h
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
#import <QuartzCore/QuartzCore.h>

#import "SolitaireController.h"

NS_ASSUME_NONNULL_BEGIN

#define DRAGGING_LAYER 100

@class SolitaireSprite;
@class SolitaireCard;
@class SolitaireCardContainer;
@class SolitaireGame;

@interface SolitaireView : NSView <CALayerDelegate> {
@private
    NSImage* backgroundImage_;
    NSColor* currentBackgroundColor_;
    SolitaireCard* selectedCard_;
}

@property (weak) IBOutlet SolitaireController* controller;

-(void) reset;
-(void) setTableBackground: (NSColor*)color;
-(void) addSprite: (SolitaireSprite*)sprite;
-(void) removeSprite: (SolitaireSprite*)sprite;
@property (readonly, copy) NSArray<SolitaireCardContainer*> *containers;
@property (readonly, copy) NSArray<SolitaireCard*> *cards;
@property (readonly, copy) NSArray<SolitaireSprite*> *sprites;
@property (readonly, strong, nullable) SolitaireGame *game;
-(void) showWinSheet;
-(void) showLostSheet;

-(nullable SolitaireCardContainer*) findContainerIntersectingCard: (SolitaireCard*)card NS_SWIFT_NAME(findContainer(intersecting:));

@end

NS_ASSUME_NONNULL_END
