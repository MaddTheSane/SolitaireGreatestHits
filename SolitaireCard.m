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
#import "SolitaireScoreKeeper.h"

// Singleton copy of the cards image.
NSImage* cardsImage = nil;
NSImage* flippedCardImage = nil;

id suitStringTable__[] = {@"Diamonds", @"Hearts", @"Spades", @"Clubs"};
id valueStringTable__[] = {@"Ace", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"Jack", @"Queen", @"King"};

@implementation SolitaireCard

@synthesize nextCard;
@synthesize flipped;
@synthesize draggable;
@synthesize dragging;
@synthesize container;
@synthesize homeLocation;

-(id) initWithSuit: (SolitaireSuit)suit faceValue: (SolitaireFaceValue)faceValue {
    
    // Load singleton copies of the card images.
    if(cardsImage == nil) cardsImage =
        [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"SolitaireCards" ofType:@"png"]];
        
    if(flippedCardImage == nil) flippedCardImage =
        [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"SolitaireCardBack" ofType:@"png"]];
    
    if((self = [super init]) != nil) {
        suit_ = suit;
        faceValue_ = faceValue;
        self.homeLocation = CGPointMake(0.0f, 0.0f);
        self.position = homeLocation;
        self.flipped = NO;
        self.draggable = YES;
        self.container = nil;
        self.zPosition = 1;
        self.hidden = NO;
        self.nextCard = nil;
        
        self.dragging = NO;
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.needsDisplayOnBoundsChange = YES;
        self.bounds = CGRectMake(0, 0, kCardWidth, kCardHeight);
        self.doubleSided = NO;
        self.shadowRadius = 6.0f;
        self.shadowOpacity = 0.75f;
        
         // Create image.
        frontImage_ = [[NSImage alloc] initWithSize: NSMakeSize(kCardWidth, kCardHeight)];
        [cardsImage lockFocus];
        NSRect srcRect = NSMakeRect(faceValue_ * kCardWidth, suit_ * kCardHeight, kCardWidth, kCardHeight);
        NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect: srcRect];
        [cardsImage unlockFocus];
    
        [frontImage_ addRepresentation: bitmap];
        backImage_ = flippedCardImage;
        
        self.delegate = self;
    }
    return self;
}

-(id) initWithCoder: (NSCoder*) decoder {

    // Card images should already be loaded.

    if((self = [super init]) != nil) {
        suit_ = [decoder decodeIntForKey: @"suit_"];
        faceValue_ = [decoder decodeIntForKey: @"faceValue_"];
        self.homeLocation = NSPointToCGPoint([decoder decodePointForKey: @"homeLocation"]);
        self.position = self.homeLocation;
        self.flipped = [decoder decodeBoolForKey: @"flipped"];
        self.draggable = [decoder decodeBoolForKey: @"draggable"];
        self.container = [decoder decodeObjectForKey: @"container"];
        self.zPosition = [decoder decodeIntForKey: @"zPosition"];
        self.hidden = [decoder decodeBoolForKey: @"hidden"];
        self.nextCard = [decoder decodeObjectForKey: @"nextCard"];
        
        self.dragging = NO;
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.needsDisplayOnBoundsChange = YES;
        self.bounds = CGRectMake(0, 0, kCardWidth, kCardHeight);
        self.doubleSided = NO;
        self.shadowRadius = 6.0f;
        self.shadowOpacity = 0.75f;
        
         // Create image.
        frontImage_ = [[NSImage alloc] initWithSize: NSMakeSize(kCardWidth, kCardHeight)];
        [cardsImage lockFocus];
        NSRect srcRect = NSMakeRect(faceValue_ * kCardWidth, suit_ * kCardHeight, kCardWidth, kCardHeight);
        NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect: srcRect];
        [cardsImage unlockFocus];
    
        [frontImage_ addRepresentation: bitmap];
        backImage_ = flippedCardImage;
        
        self.delegate = self;
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) encoder {
    [encoder encodeInt: suit_ forKey: @"suit_"];
    [encoder encodeInt: faceValue_ forKey: @"faceValue_"];
    [encoder encodeBool: self.flipped forKey: @"flipped"];
    [encoder encodeBool: self.draggable forKey: @"draggable"];
    [encoder encodeConditionalObject: self.container forKey: @"container"];
    [encoder encodeInt: self.zPosition forKey: @"zPosition"];
    [encoder encodeBool: self.hidden forKey: @"hidden"];
    [encoder encodePoint: NSPointFromCGPoint(self.homeLocation) forKey: @"homeLocation"];
    [encoder encodeConditionalObject: self.nextCard forKey: @"nextCard"];    
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

-(NSString*) faceValueAbbreviation {
    switch([self faceValue]) {
        case SolitaireValueAce: return @"A";
        case SolitaireValue2: return @"2";
        case SolitaireValue3: return @"3";
        case SolitaireValue4: return @"4";
        case SolitaireValue5: return @"5";
        case SolitaireValue6: return @"6";
        case SolitaireValue7: return @"7";
        case SolitaireValue8: return @"8";
        case SolitaireValue9: return @"9";
        case SolitaireValue10: return @"10";
        case SolitaireValueJack: return @"J";
        case SolitaireValueQueen: return @"Q";
        case SolitaireValueKing: return @"K";
    }
    return nil;
}

-(void) drawSprite {
    NSRect dstRect = NSRectFromCGRect(self.bounds);
   
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
        [path setLineWidth: 3.0f];
        NSRect highlightRect = NSMakeRect(self.bounds.origin.x, self.bounds.origin.x, self.bounds.size.width, self.bounds.size.height);//NSMakeRect(5, 5, kCardWidth - 4.0f, kCardHeight - 4.0f);
        [path appendBezierPathWithRoundedRect: highlightRect xRadius: 12.0f yRadius: 12.0f];
        
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
        [self flipCard];
    }
}

-(void) flipCard {
    self.flipped = !self.flipped;
    self.draggable = !self.flipped;
    
    // Tell the undo manager how to undo this operation.
    [[self.view undoManager] beginUndoGrouping];
    [[[self.view undoManager] prepareWithInvocationTarget: self] flipCard];

    // Keep score
    if(![[self.view undoManager] isUndoing]) {
        SolitaireGame* game = [self.view.controller game];
        if([game keepsScore]) self.view.controller.scoreKeeper.score +=
            [game scoreForCardFlipped: self];
    }
    [[self.view undoManager] endUndoGrouping];
    
    [self setNeedsDisplay];
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

// Override default setPosition
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

// Override defauly setZPosition
-(void) setZPosition: (CGFloat)value {
    CGFloat delta = value - self.zPosition;
    [super setZPosition: value];
    
    if(self.nextCard) {
        CGFloat oldZPosition = self.nextCard.zPosition;
        self.nextCard.zPosition = oldZPosition + delta;
    }
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
    if(self.zPosition >= DRAGGING_LAYER) self.zPosition -= DRAGGING_LAYER;
}

@end
