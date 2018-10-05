//
//  SolitaireView.m
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

#import "SolitaireView.h"
#import "SolitaireSprite.h"
#import "SolitaireCard.h"
#import "SolitaireCardContainer.h"
#import "SolitaireFoundation.h"
#import "SolitaireTimer.h"
#import "SolitaireScoreKeeper.h"

@implementation SolitaireView

@synthesize controller;

-(void) awakeFromNib {
    [[self window] makeFirstResponder:self];
    [[self window] setAcceptsMouseMovedEvents: YES];
    
    backgroundImage_ = nil;
    currentBackgroundColor_ = nil;
    selectedCard_ = nil;
        
    self.wantsLayer = YES;
    self.layer.frame = NSRectToCGRect(self.bounds);
    self.layer.delegate = self;
    self.layer.needsDisplayOnBoundsChange = YES;
        
    NSData* colorAsData = [[NSUserDefaults standardUserDefaults] objectForKey: @"backgroundColor"];
    NSColor* backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData: colorAsData];
    [self setTableBackground: backgroundColor];
    
    [self.layer setNeedsDisplay];
}

-(void) reset {
    self.layer = [CALayer layer];
    self.layer.frame = NSRectToCGRect(self.bounds);
    self.layer.delegate = self;
    self.layer.needsDisplayOnBoundsChange = YES;
    [[self undoManager] removeAllActions];    
    [self.layer setNeedsDisplay];
}

-(void) setTableBackground: (NSColor*)color {    
    if([currentBackgroundColor_ isEqual: color]) return;
    
    backgroundImage_ = [[NSImage alloc] initWithSize: NSSizeFromCGSize(self.layer.bounds.size)];
    [backgroundImage_ lockFocus];
    
    NSRect rect = NSMakeRect(0.0f, 0.0f, [backgroundImage_ size].width, [backgroundImage_ size].height);
    [color set];
    [NSBezierPath fillRect: rect];
    
    // Paint table grains
    const int grainCount = 80000;
    int w = backgroundImage_.size.width;
    int h = backgroundImage_.size.height;
    
    int k;
    for(k = 0; k < grainCount; k++) {
        // Set grain color
        float r = 1.0 + (0.1 - 0.2 * (float)rand()/RAND_MAX); // Color variation
        [[NSColor colorWithCalibratedRed: color.redComponent * r green: color.greenComponent * r blue: color.blueComponent * r alpha: 1.0f] set];
        
        // Pick grain position
        int grainX = (int)((float)rand()/RAND_MAX * w);
        int grainY = (int)((float)rand()/RAND_MAX * h);
        NSBezierPath* path = [NSBezierPath bezierPath];
        NSRect bounds = NSMakeRect(grainX, grainY, (float)rand()/RAND_MAX * 5, (float)rand()/RAND_MAX * 5);
        [path appendBezierPathWithOvalInRect: bounds];
        [path fill];
    }
    
    // Paint Gradient
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor: [NSColor colorWithCalibratedRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.5f]
        endingColor: [NSColor colorWithCalibratedRed: 0.0f green: 0.0f blue: 0.0f alpha: 0.5f]];
    [gradient drawInRect: rect relativeCenterPosition: NSMakePoint(0.0f, 0.0f)];
    
    [backgroundImage_ unlockFocus];
    
    currentBackgroundColor_ = color;
}

-(void) addSprite: (SolitaireSprite*)sprite {
    if(![[self.layer sublayers] containsObject: sprite]) {
        [self.layer addSublayer: sprite];
        sprite.view = self;
        [sprite onAddedToView: self];
        [sprite setNeedsDisplay];
    }
    else {
        NSLog(@"Warning: Tried to add existing sublayer.");
    }
}

-(void) removeSprite: (SolitaireSprite*)sprite {
    [sprite removeFromSuperlayer];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
    if(layer == self.layer) { // draw background
        [backgroundImage_ drawInRect: NSRectFromCGRect(CGContextGetClipBoundingBox(context)) fromRect: NSZeroRect operation: NSCompositeCopy fraction:1.0];
    }
    [NSGraphicsContext restoreGraphicsState];
}

- (void)setFrameSize: (NSSize)newSize {
    [super setFrameSize: newSize];
    
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
    [[self game] layoutGameComponents];
    [CATransaction commit];
}

-(NSArray*) cards {
    NSMutableArray* cards = [[NSMutableArray alloc] initWithCapacity: 64];
    for(CALayer* layer in self.layer.sublayers) {
        if([layer isKindOfClass: [SolitaireCard class]]) [cards addObject: layer];
    }
    return cards;
}

-(SolitaireGame*) game {
    return [self.controller game];
}

-(NSArray*) containers {
    NSMutableArray* containers = [[NSMutableArray alloc] initWithCapacity: 16];
    for(CALayer* layer in self.layer.sublayers) {
        if([layer isKindOfClass: [SolitaireCardContainer class]]) [containers addObject: layer];
    }
    return containers;
}

-(void) showWinSheet {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Start New Game"];
    [alert setMessageText:@"You Won!"];
    
    NSString* info = [NSString stringWithFormat: @"Your time was %@", [self.controller.timer timeString]];
    if([[self game] keepsScore]) info = [NSString stringWithFormat: @"%@\nYour score was %i", info, self.controller.scoreKeeper.score];
    
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: [self window] modalDelegate: self.controller
        didEndSelector: @selector(newGame) contextInfo: nil];
}

- (void)mouseDown:(NSEvent *)theEvent {
    selectedCard_ = nil;

    // Find which sprite was clicked.
    NSPoint location = [self convertPoint: [theEvent locationInWindow] fromView: [[self window] contentView]];
    CALayer* layer = [self.layer hitTest: NSPointToCGPoint(location)];
    if([layer isKindOfClass: [SolitaireSprite class]]) {
        SolitaireSprite* sprite = (SolitaireSprite*)layer;
        [sprite spriteClicked: [theEvent clickCount]];
        if([sprite isKindOfClass: [SolitaireCard class]]) {
            SolitaireCard* card = (SolitaireCard*)sprite; 
            if(card.draggable) selectedCard_ = card;
        }
    }
    
    if(selectedCard_ == nil) return;
        
    // If the card is double clicked, move it into a foundation.
    if([theEvent clickCount] == 2 && selectedCard_.nextCard == nil) {
        SolitaireFoundation* foundation = [[self game] findFoundationForCard: selectedCard_];
        if(foundation != nil) {            
            [[self game] dropCard: selectedCard_ inContainer: foundation];
        }
        selectedCard_ = nil;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if(selectedCard_ != nil) {
        if(!selectedCard_.dragging) {
            selectedCard_.dragging = YES;
            selectedCard_.zPosition += DRAGGING_LAYER;
        }
        
        [CATransaction begin];
        [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
        CGPoint delta = [self.layer convertPoint: NSPointToCGPoint(NSMakePoint([theEvent deltaX], [theEvent deltaY])) fromLayer: self.layer];
        selectedCard_.position = CGPointMake(selectedCard_.position.x + delta.x, selectedCard_.position.y - delta.y);
        [CATransaction commit];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    if(selectedCard_.dragging) {
        selectedCard_.dragging = NO;
        selectedCard_.zPosition -= DRAGGING_LAYER;
    
        // See if we are dropping card into a new container.
        SolitaireCardContainer* container = [self findContainerIntersectingCard: selectedCard_];
        if(container != nil && container != selectedCard_.container && [[self game] canDropCard: selectedCard_ inContainer: container]) {                        
            [[self game] dropCard: selectedCard_ inContainer: container];
        }
        else selectedCard_.position = selectedCard_.homeLocation;
    }
    
    selectedCard_ = nil;
    [self setNeedsDisplay: YES];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    static SolitaireSprite* hoveringSprite = nil;
    NSPoint location = [self convertPoint: [theEvent locationInWindow] fromView: [[self window] contentView]];
    CALayer* layer = [self.layer hitTest: NSPointToCGPoint(location)];
    if([layer isKindOfClass: [SolitaireSprite class]]) {
        SolitaireSprite* sprite = (SolitaireSprite*)layer;
        if(sprite == hoveringSprite) return;
        
        if(hoveringSprite) {
            hoveringSprite.selected = NO;
            [hoveringSprite setNeedsDisplay];
        }
        
        hoveringSprite = sprite;
        hoveringSprite.selected = YES;
        [hoveringSprite setNeedsDisplay];
        return;
    }
        
    // If we reach this point, no sprite is selected
    if(hoveringSprite != nil) {
        hoveringSprite.selected = NO;
        [hoveringSprite setNeedsDisplay];
        hoveringSprite = nil;
    }
}

-(SolitaireCardContainer*) findContainerIntersectingCard: (SolitaireCard*)card {
    SolitaireCardContainer* intersectingContainer = nil;
    CGFloat maxDist = 0.0f;
    NSRect cardRect = NSRectFromCGRect(card.frame);

    for(SolitaireCardContainer* container in [self containers]) {
        if(container == card.container || ![container acceptsDroppedCards]) continue;
        NSRect containerRect = NSRectFromCGRect([container topRect]);
        NSRect intersectRect = NSIntersectionRect(cardRect, containerRect);
        if(!NSEqualRects(intersectRect, NSZeroRect)) {
            CGFloat dist = intersectRect.size.width;
            if(dist > maxDist) {
                intersectingContainer = container;
                maxDist = dist;
            }
        }
    }
    return intersectingContainer;
}

@end
