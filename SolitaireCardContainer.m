//
//  SolitaireCardContainer.m
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

#import "SolitaireCardContainer.h"
#import "SolitaireCard.h"

// Specify delegate methods
@interface NSObject (SolitaireCardContainerDelegateMethods)
    -(void) onCard: (SolitaireCard*)card addedToContainer: (SolitaireCardContainer*) container;
    -(void) onCard: (SolitaireCard*)card removedFromContainer: (SolitaireCardContainer*) container;
@end

@implementation SolitaireCardContainer

-(id) initWithView: (SolitaireView*)gameView {
    if((self = [super initWithView: gameView]) != nil) {
        cards_ = [[NSMutableArray alloc] initWithCapacity: 16];
        delegate_ = nil;
        self.frame = CGRectMake(0.0f, 0.0f, CARD_WIDTH, CARD_HEIGHT);
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.zPosition = 0;
    }
    return self;
}

-(id) delegate {
    return delegate_;
}

-(void) setDelegate: (id)delegate {
    delegate_ = delegate;
}

-(BOOL) acceptsDroppedCards {
    return NO;
}

-(SolitaireCard*) topCard {
    return [cards_ lastObject];
}

-(CGPoint) topLocation {
    return self.position;
}

-(CGPoint) nextLocation {
    return [self topLocation];
}

-(CGRect) topRect {
    if([self topCard]) return [self topCard].frame;
    return self.frame;
}

-(NSInteger) count {
    return [cards_ count];
}

-(void) addCard: (SolitaireCard*) card {
    // Remove card from previous container.
    if(card.container) [card.container removeCard: card];
    
    if([self topCard] != nil) [self topCard].nextCard = card;
    card.zPosition = [cards_ count] + 1;
    card.homeLocation = [self nextLocation];
    card.container = self;
    [cards_ addObject: card];
    
    if([delegate_ respondsToSelector:@selector(onCard:addedToContainer:)])
        [delegate_ onCard: card addedToContainer: self];
        
    if(card.nextCard) [self addCard: card.nextCard];
}

-(void) removeCard: (SolitaireCard*) card {
    SolitaireCard* stackedCard = card;
    while(stackedCard != nil) {
        [cards_ removeObject: stackedCard];
        stackedCard = stackedCard.nextCard;
    }
    
    if([self topCard]) {
        [self topCard].nextCard = nil;
        if(![self topCard].flipped) [self topCard].draggable = YES;
    }

    if([delegate_ respondsToSelector:@selector(onCard:removedFromContainer:)])
        [delegate_ onCard: card removedFromContainer: self];
}

-(BOOL) containsCard: (SolitaireCard*) card {
    return [cards_ containsObject: card];
}

-(CGFloat) cardVertSpacing {
    return 0.0;
}

-(CGFloat) cardHorizSpacing {
    return 0.0;
}

// Force cards to move when the container moves.
-(void) setPosition: (CGPoint)p {
    // We cast x, y coordinates to whole integers to force Core Animation to render the image without any
    // scaling blur.
    CGFloat dx = p.x - self.position.x;
    CGFloat dy = p.y - self.position.y;
    [super setPosition: CGPointMake((int)p.x, (int)p.y)];
    
    if([cards_ count] > 0) {
        SolitaireCard* bottomCard = [cards_ objectAtIndex: 0];
        CGPoint oldPosition = bottomCard.position;
        bottomCard.position = CGPointMake((int)(oldPosition.x + dx), (int)(oldPosition.y + dy));
    }
    
    for(SolitaireCard* card in cards_) {
        card.homeLocation = CGPointMake((int)(card.homeLocation.x + dx), (int)(card.homeLocation.y + dy));
    }
}

@end
