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
@end

@implementation SolitaireStock

@synthesize text;
@synthesize disableRestock;
@synthesize reclickDelay;

-(id) initWithView: (SolitaireView*) gameView {
    return [self initWithView: gameView withDeckCount: 1];
}

-(id) initWithView: (SolitaireView*)gameView withDeckCount: (NSInteger)deckCount {
    if(flippedCardImage == nil) flippedCardImage =
        [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"SolitaireCardBack" ofType:@"png"]];

    if((self = [super initWithView: gameView]) != nil) {
        delegate_ = nil;
        deckCount_ = deckCount;
        deck_ = [[NSMutableArray alloc] initWithCapacity: 52];
        blockReclick_ = NO;
        
        self.text = @"";
        self.disableRestock = NO;
        self.reclickDelay = 0.2f;
        self.bounds = CGRectMake(0.0f, 0.0f, CARD_WIDTH + 8.0f, CARD_HEIGHT + 8.0f);
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.shadowRadius = 5.0f;
        self.shadowOpacity = 1.0f;
        [self reset];

    }
    return self;
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
                SolitaireCard* card = [[SolitaireCard alloc] initWithSuit: suit faceValue: value inView: self.view];
                card.bounds = self.bounds;
                [self addCard: card];
                [self.view addSprite: card];
                [card setNeedsDisplay];
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
            self.bounds.origin.y + 2.0f, CARD_WIDTH, CARD_HEIGHT));
                    
        NSBezierPath* path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect: dstRect xRadius: 9.0f yRadius: 9.0f];
        [path setLineWidth: 2.0f];
        [path stroke];
        
        // Write text
        if(![self.text isEqualToString: @""]) {
            NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
            [style setAlignment: NSCenterTextAlignment];
            NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSFont fontWithName:@"Helvetica" size: 22], NSFontAttributeName,
                borderColor, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    
            CGFloat newHeight = 4.0f * dstRect.size.height / 10.0f;
            dstRect.size.height = newHeight;
            dstRect.origin.y += (self.bounds.size.height - newHeight) / 2.5;
        
            [self.text drawInRect: dstRect withAttributes: attributes];
        }
    }
    else {
        int i;
        CGFloat dx = -2.0f;
        CGFloat dy = 2.0f;
        NSRect srcRect = NSMakeRect(1.0f, 3.0f, CARD_WIDTH, CARD_HEIGHT); 
        
        for(i = 2; i >= 0; i--) {
            NSRect dstRect = NSMakeRect(6.0f - i * dx, (2-i) * dy, CARD_WIDTH, CARD_HEIGHT);
            [flippedCardImage drawInRect: dstRect fromRect: srcRect operation: NSCompositeSourceOver fraction: 1.0f];
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

    //[[self.view game] dropCard: card inTableau: tableau];
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
}

// Private methods

-(void)unblockReclick {
    blockReclick_ = NO;
}

@end
