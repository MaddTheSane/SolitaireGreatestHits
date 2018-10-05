//
//  SolitaireStock.m
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

#import "SolitaireStock.h"
#import "SolitaireView.h"
#import "SolitaireTableau.h"
#import "SolitaireCard.h"

extern NSImage* flippedCardImage;

// Private methods
@interface SolitaireStock(NSObject)
-(void)unblockReclick;    
@end

// Specify delegate methods
@interface NSObject (SolitaireStockDelegateMethods)
-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount;
-(void) onRefillStock: (SolitaireStock*)stock;
-(BOOL) canRefillStock;
@end

@implementation SolitaireStock

@synthesize disableRestock;
@synthesize reclickDelay;

-(id) init {
    return [self initWithDeckCount: 1];
}

-(id) initWithDeckCount: (NSInteger)deckCount {
    if(flippedCardImage == nil) flippedCardImage =
        [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"SolitaireCardBack" ofType:@"png"]];

    if((self = [super init]) != nil) {
        delegate_ = nil;
        deckCount_ = deckCount;
        deck_ = [[NSMutableArray alloc] initWithCapacity: 52];
        blockReclick_ = NO;
        
        self.disableRestock = NO;
        self.reclickDelay = 0.2f;
        self.hidden = NO;
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth + 8.0f, kCardHeight + 8.0f);
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.shadowRadius = 5.0f;
        self.shadowOpacity = 1.0f;
        [self reset];
        
        // Load images
        reloadImage_ = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Reload" ofType:@"png"]];
        emptyImage_ = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Empty" ofType:@"png"]];
    }
    return self;
}

-(id) initWithCoder: (NSCoder*) decoder {
    // Card image should already exist, so we won't load it.
    if((self = [super init]) != nil) {
        delegate_ = nil;
        deckCount_ = [decoder decodeIntForKey: @"deckCount_"];
        deck_ = [decoder decodeObjectForKey: @"deck_"];
        blockReclick_ = NO;
                
        self.disableRestock = [decoder decodeBoolForKey: @"disableRestock"];
        self.reclickDelay = [decoder decodeFloatForKey: @"reclickDelay"];
        self.hidden = [decoder decodeBoolForKey: @"hidden"];
        self.position = NSPointToCGPoint([decoder decodePointForKey: @"position"]);
        self.bounds = CGRectMake(0.0f, 0.0f, kCardWidth + 8.0f, kCardHeight + 8.0f);
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.shadowRadius = 5.0f;
        self.shadowOpacity = 1.0f;
        
        // Load images
        reloadImage_ = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Reload" ofType:@"png"]];
        emptyImage_ = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Empty" ofType:@"png"]];
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) encoder {
    [encoder encodeInt: deckCount_ forKey: @"deckCount_"];
    [encoder encodeObject: deck_ forKey: @"deck_"];
    [encoder encodeBool: self.disableRestock forKey: @"disableRestock"];
    [encoder encodeFloat: self.reclickDelay forKey: @"reclickDelay"];
    [encoder encodeBool: self.hidden forKey: @"hidden"];
    [encoder encodePoint: NSPointFromCGPoint(self.position) forKey: @"position"];
}

-(id) delegate {
    return delegate_;
}

-(void) setDelegate: (id)delegate {
    delegate_ = delegate;
}

-(NSInteger) count {
    return [deck_ count];
}

-(NSArray*) cards {
    return [deck_ copy];
}

-(BOOL) isEmpty {
    return [self count] == 0;
}

-(void) reset {
    // Load cards into deck.
    [deck_ removeAllObjects];
    
    NSInteger count;
    NSInteger suit;
    NSInteger value;
    
    for(count = 0; count < deckCount_; count++){
        for(suit = 0; suit < 4; suit++) {
            for(value = 0; value < 13; value++) {
                SolitaireCard* card = [[SolitaireCard alloc] initWithSuit: suit faceValue: value];
                [self addCard: card];
            }
        }
    }
    [self shuffle];
}

-(void) shuffle {
    NSInteger count = [deck_ count];
    
    NSInteger i;
    for(i = 0; i < count; i++) {
        [deck_ exchangeObjectAtIndex: i withObjectAtIndex: (NSUInteger)(rand() % count)];
    }
}

-(void) restock {
    if([delegate_ respondsToSelector: @selector(onRefillStock:)] && !self.disableRestock)
        [delegate_ onRefillStock: self];
}

-(void) addCard: (SolitaireCard*)card {
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
    card.position = self.position;
    card.hidden = YES;
    card.nextCard = nil;
    card.selected = NO;
    card.flipped = NO;
    [CATransaction commit];
    [CATransaction flush];

    if(card.container) [card.container removeCard: card];
    card.container = nil;
    card.draggable = YES;
    [deck_ addObject: card];
    
    [self setNeedsDisplay];
}

-(void) removeCard: (SolitaireCard*)card {
    [deck_ removeObject: card];
}

-(void) removeCards: (NSArray*)cards {
    [deck_ removeObjectsInArray: cards];
}

-(void) drawSprite {
    if([self isEmpty]) {
        NSColor* borderColor = [NSColor colorWithCalibratedRed: 0.85f green: 0.85f blue: 0.85f alpha: 0.5f];
        [borderColor setStroke];
        
        NSRect dstRect = NSRectFromCGRect(CGRectMake(self.bounds.origin.x + 2.0f,
            self.bounds.origin.y + 2.0f, kCardWidth, kCardHeight));
                    
        NSBezierPath* path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect: dstRect xRadius: 9.0f yRadius: 9.0f];
        [path setLineWidth: 2.0f];
        [path stroke];
        
        // Draw Image
        if(!self.disableRestock && delegate_ && [delegate_ canRefillStock]) {
            [reloadImage_ drawInRect: NSMakeRect((self.bounds.size.width - 54) / 2.0, (self.bounds.size.height - 54) / 2.0, 50, 50)
                fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0f];
        }
        else {
            [emptyImage_ drawInRect: NSMakeRect((self.bounds.size.width - 54) / 2.0, (self.bounds.size.height - 54) / 2.0, 50, 50)
                fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0f];
        }
    }
    else {
        int i;
        CGFloat dx = -2.0f;
        CGFloat dy = 2.0f;
        NSRect srcRect = NSMakeRect(1.0f, 3.0f, kCardWidth, kCardHeight); 
        
        for(i = 2; i >= 0; i--) {
            NSRect dstRect = NSMakeRect(6.0f - i * dx, (2-i) * dy, kCardWidth, kCardHeight);
            [flippedCardImage drawInRect: dstRect fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0f];
        }
        
        // Draw card count indication.
        if(self.selected) {
            CGFloat ovalRadius = 30;
            NSRect cardCountRect = NSMakeRect(2, 2, ovalRadius, ovalRadius);
        
            NSBezierPath* oval = [NSBezierPath bezierPathWithOvalInRect: cardCountRect];
            [[NSColor whiteColor] setFill];
            [oval fill];
            [[NSColor redColor] setStroke];
            [oval setLineWidth: 2.0];
            [oval stroke];
        
            cardCountRect.size.height -= 5;
            NSString* countString = [NSString stringWithFormat: @"%i", [self count]];
            NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
            [style setAlignment: NSCenterTextAlignment];
            NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSFont fontWithName: @"Helvetica" size: 15], NSFontAttributeName,
                    [NSColor redColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
            [countString drawInRect: cardCountRect withAttributes: attributes];
        }
    }
}

-(void) spriteClicked: (NSUInteger)clickCount {
    if(blockReclick_) return;
    
    if(![self isEmpty]) {
        if([delegate_ respondsToSelector: @selector(onStock:clicked:)])
            [delegate_ onStock: self clicked: clickCount];
    }
    else {
        [self restock];
    }
    [self setNeedsDisplay];
    
    blockReclick_ = YES;
    [self performSelector: @selector(unblockReclick) withObject: nil afterDelay: self.reclickDelay];
}

-(void) onAddedToView: (SolitaireView*)gameView {
    // We need to add our cards to the view.
    for(SolitaireCard* card in deck_) {
        [gameView addSprite: card];
    }
}

-(SolitaireCard*) dealCard {
    SolitaireCard* card = [deck_ lastObject];
    [deck_ removeLastObject];
    return card;
}

-(void) dealCardToTableau: (SolitaireTableau*) tableau faceDown: (BOOL) flipped {
    SolitaireCard* card = [deck_ lastObject];
    [deck_ removeLastObject];
    
    card.hidden = NO;
    card.flipped = flipped;
    card.position = [tableau nextLocation];
    card.draggable = !flipped;
    card.zPosition = 1;
    [card setNeedsDisplay];

    [tableau addCard: card];    
}

-(void) animateCardToTableau: (SolitaireTableau*) tableau {
    SolitaireCard* card = [deck_ lastObject];
    [deck_ removeLastObject];
    
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];            
    card.flipped = NO;
    card.position = self.position;
    card.hidden = NO;
    [card setNeedsDisplay];
    [CATransaction commit];
    [CATransaction flush];

    [[self.view game] dropCard: card inTableau: tableau];
    if([self isEmpty]) [self setNeedsDisplay];
    
    [self setNeedsDisplay];
}

// Private methods

-(void)unblockReclick {
    blockReclick_ = NO;
}

@end
