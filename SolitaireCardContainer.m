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
#import "SolitaireView.h"

@implementation SolitaireCardContainer

@synthesize text;

-(id) init {
    if((self = [super init]) != nil) {
        self.position = CGPointMake(0.0f, 0.0f);
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth, kCardHeight);
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.zPosition = 0;
        self.hidden = NO;

        cards_ = [[NSMutableArray alloc] initWithCapacity: 16];
        self.text = nil;
    }
    return self;
}

-(id) initWithCoder: (NSCoder*) decoder {
    if((self = [self init]) != nil) {
        self.position = NSPointToCGPoint([decoder decodePointForKey: @"position"]);
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth, kCardHeight);
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.zPosition = [decoder decodeIntForKey: @"zPosition"];
        self.hidden = [decoder decodeIntForKey: @"hidden"];

        cards_ = [decoder decodeObjectForKey: @"cards_"];
        self.text = [decoder decodeObjectForKey: @"text"];
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) encoder {
    [encoder encodeObject: cards_ forKey: @"cards_"];
    [encoder encodeObject: self.text forKey: @"text"];
    [encoder encodePoint: NSPointFromCGPoint(self.position) forKey: @"position"];
    [encoder encodeInt: self.hidden forKey: @"hidden"];
    [encoder encodeInt: self.zPosition forKey: @"zPosition"];
}

-(NSArray*) cards {
    return [cards_ copy];
}

-(void) drawSprite {
        NSRect dstRect = NSRectFromCGRect(CGRectMake(self.bounds.origin.x + 2,
            self.bounds.origin.y + 2, kCardWidth - 2, kCardHeight - 2));
    
        NSBezierPath* path = [NSBezierPath bezierPath];
        [path setLineWidth: 2.0f];
        [path appendBezierPathWithRoundedRect: dstRect xRadius: 9.0f yRadius: 9.0f];
        
        NSColor* borderColor = [NSColor colorWithCalibratedRed: 0.85f green: 0.85f blue: 0.85f alpha: 0.5f];
        [borderColor setStroke];
        [path stroke];
        
        if(self.selected) {
            NSColor* backgroundColor = [NSColor colorWithCalibratedRed: 0.85f green: 0.85f blue: 0.85f alpha: 0.15f];
            [backgroundColor setFill];
            [path fill];
        }
    
        if(self.text != nil) {
            NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
            [style setAlignment: NSCenterTextAlignment];
            NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSFont fontWithName:@"Helvetica" size: 48], NSFontAttributeName,
                borderColor, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    
            CGFloat newHeight = 4.0f * dstRect.size.height / 10.0f;
            dstRect.size.height = newHeight;
            dstRect.origin.y += newHeight;
        
            [self.text drawInRect: dstRect withAttributes: attributes];
        }
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
    
    card.zPosition = self.zPosition + [cards_ count] + 1;
    card.homeLocation = [self nextLocation];
    card.container = self;
    [cards_ addObject: card];
        
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

-(void) onAddedToView: (SolitaireView*)gameView {
    // We need to add our cards to the view.
    for(SolitaireCard* card in cards_) {
        [gameView addSprite: card];
    }
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
