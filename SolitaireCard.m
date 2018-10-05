//
//  SolitaireCard.m
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

#import "SolitaireCard.h"
#import "SolitaireView.h"

// Singleton copy of the cards image.
NSImage* cardsImage = nil;
NSImage* flippedCardImage = nil;

id suitStringTable__[] = {@"Diamonds", @"Hearts", @"Spades", @"Clubs"};
id valueStringTable__[] = {@"Ace", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"Jack", @"Queen", @"King"};

@implementation SolitaireCard

-(id) initWithSuit: (SolitaireSuit)suit faceValue: (SolitaireFaceValue)faceValue inView: (SolitaireView*)gameView {
    
    // Load singleton copies of the card images.
    if(cardsImage == nil) cardsImage =
        [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"SolitaireCards" ofType:@"png"]];
        
    if(flippedCardImage == nil) flippedCardImage =
        [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"SolitaireCardBack" ofType:@"png"]];
    
    if((self = [super initWithView: gameView]) != nil) {
        suit_ = suit;
        faceValue_ = faceValue;
        self.nextCard = nil;
        self.flipped = NO;
        self.draggable = YES;
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.needsDisplayOnBoundsChange = YES;
        self.bounds = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
        self.zPosition = 1;
        self.doubleSided = NO;
        self.shadowRadius = 6.0f;
        self.shadowOpacity = 0.75f;
        
         // Create image.
        frontImage_ = [[NSImage alloc] initWithSize: NSMakeSize(CARD_WIDTH, CARD_HEIGHT)];
        [cardsImage lockFocus];
        NSRect srcRect = NSMakeRect(faceValue * CARD_WIDTH, suit * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
        NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect: srcRect];
        [cardsImage unlockFocus];
    
        [frontImage_ addRepresentation: bitmap];
        backImage_ = flippedCardImage;
        
        self.delegate = self;
    }
    return self;
}

-(SolitaireFaceValue) faceValue {
    return faceValue_;
}

-(SolitaireSuit) suit {
    return suit_;
}

-(SolitaireSuitColor) suitColor {
    return (suit_ == SolitaireSuitHearts) || (suit_ == SolitaireSuitDiamonds);
}

-(NSString*) name {
    NSString* cardName = [NSString stringWithFormat: @"%@ of %@", valueStringTable__[(int)[self faceValue]], suitStringTable__[(int)[self suit]]];
    return cardName;
}

-(void) drawSprite {
    NSRect dstRect = NSMakeRect(3, 3, CARD_WIDTH, CARD_HEIGHT);
   
    // Draw Card
    if(!flipped) {
        [frontImage_ drawInRect: dstRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0f];
    }
    else {
        [backImage_ drawInRect: dstRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0f];
    }
    
    // Highlight card.
    if(self.selected && self.draggable) {
        NSBezierPath* path = [NSBezierPath bezierPath];
        [path setLineWidth: 2.0f];
        NSRect highlightRect = NSMakeRect(5, 5, CARD_WIDTH - 4.0f, CARD_HEIGHT - 4.0f);
        [path appendBezierPathWithRoundedRect: highlightRect xRadius: 9.0f yRadius: 9.0f];
        
        NSColor* fillColor = [NSColor colorWithCalibratedRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.25f];
        [fillColor setFill];
        [path fill];
        
        NSColor* borderColor = [NSColor colorWithCalibratedRed: 0.9f green: 0.92f blue: 0.54f alpha: 1.0f];
        [borderColor setStroke];
        [path stroke];
    }
}

-(void) spriteClicked: (NSUInteger)clickCount {
    if(self.flipped && self.nextCard == nil) {
        [[[self.view undoManager] prepareWithInvocationTarget: self] flipCard];
        [self flipCard];
    }
}

-(void) setPosition: (CGPoint)p {
    // We cast x, y coordinates to whole integers to force Core Animation to render the image without any
    // scaling blur.
    CGFloat dx = p.x - self.position.x;
    CGFloat dy = p.y - self.position.y;
    [super setPosition: CGPointMake((int)p.x, (int)p.y)];
    
    if(self.nextCard) {
        CGPoint oldPosition = self.nextCard.position;
        self.nextCard.position = CGPointMake((int)(oldPosition.x + dx), (int)(oldPosition.y + dy));
    }
}

-(void) setZPosition: (CGFloat)value {
    CGFloat delta = value - self.zPosition;
    [super setZPosition: value];
    
    if(self.nextCard) {
        CGFloat oldZPosition = self.nextCard.zPosition;
        self.nextCard.zPosition = oldZPosition + delta;
    }
}

-(void) flipCard {
    self.flipped = !self.flipped;
    self.draggable = !self.flipped;
    
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
    [self setNeedsDisplay];
    [CATransaction commit];
}

-(void) animateToPosition: (CGPoint)p afterDelay: (NSTimeInterval)delay {
    [self animateToPosition: p andTransform: CATransform3DIdentity afterDelay: delay];
}

-(void) animateToPosition: (CGPoint)p andTransform: (CATransform3D)t afterDelay: (NSTimeInterval)delay {
    // Create animation
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"position"];

    // Configure animation
    anim1.fromValue = [NSValue valueWithPoint: NSPointFromCGPoint(self.position)];
    anim1.toValue = [NSValue valueWithPoint: NSPointFromCGPoint(p)];
    anim1.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    anim1.duration = 0.45;
    anim1.removedOnCompletion = NO;
    anim1.fillMode = kCAFillModeForwards;
    anim1.beginTime = CACurrentMediaTime() + delay;
    anim1.delegate = self;

    // Add animation to layer; also triggers the animation
    [self addAnimation: anim1 forKey: @"position"];
    
    if(!CATransform3DIsIdentity(t)) { // Apply the transform animation
        // Create animation
        CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath: @"transform"];

        // Configure animation
        anim2.fromValue = [NSValue valueWithCATransform3D: self.transform];
        anim2.toValue = [NSValue valueWithCATransform3D: t];
        anim2.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        anim2.duration = 0.5;
        anim2.removedOnCompletion = NO;
        anim2.fillMode = kCAFillModeForwards;
        anim2.beginTime = CACurrentMediaTime() + delay;
        anim2.delegate = self;

        // Add animation to layer; also triggers the animation
        [self addAnimation: anim2 forKey: @"transform"];
    }
}

-(NSInteger) countCardsStackedOnTop {
    NSInteger count = 0;
    SolitaireCard* stackedCard = nextCard;
    while(stackedCard != nil) {
        count++;
        stackedCard = stackedCard.nextCard;
    }
    return count;
}

-(NSComparisonResult) compareFaceValue: (SolitaireCard*)card {
    if([self faceValue] < [card faceValue]) return NSOrderedAscending;
    else if([self faceValue] > [card faceValue]) return NSOrderedDescending;
    return NSOrderedSame;
}

-(id<CAAction>) actionForLayer:(CALayer *)layer forKey:(NSString *)key {
    if([key isEqualToString: @"position"]) {
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath: @"position"];
        anim.delegate = self; //to get the animationDidStop:finished: message
        anim.duration = 0.2f;
        return anim;
    }
    return [CABasicAnimation defaultValueForKey: key];
}

-(void) animationDidStart:(CAAnimation *)theAnimation {
    self.zPosition += DRAGGING_LAYER;
}

-(void) animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    self.zPosition -= DRAGGING_LAYER;
}

@synthesize nextCard;
@synthesize flipped;
@synthesize draggable;
@synthesize dragging;
@synthesize container;
@synthesize homeLocation;

@end
