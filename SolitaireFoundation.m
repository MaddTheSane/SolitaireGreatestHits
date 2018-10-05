//
//  SolitaireFoundation.m
//  Solitaire
//
//  Created by Daniel Fontaine on 6/21/08.
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

#import "SolitaireFoundation.h"
#import "SolitaireCard.h"

@implementation SolitaireFoundation

-(id) initWithView: (SolitaireView*)gameView {
    if((self = [super initWithView: gameView]) != nil) {
        self.frame = CGRectMake(0.0f, 0.0f, CARD_WIDTH + 4, CARD_HEIGHT + 4);
    }
    return self;
}

-(BOOL) acceptsDroppedCards {
    return YES;
}

-(CGPoint) nextLocation {
    return [self topLocation];
}

-(void) addCard: (SolitaireCard*) card {
    // Hide card below top card.
    NSInteger count = [cards_ count];
    if(count > 1) {
        SolitaireCard* lowerCard = [cards_ objectAtIndex: count - 2]; 
        lowerCard.hidden = YES;
    }
    [super addCard: card];
}

-(void) removeCard: (SolitaireCard*) card {
    [cards_ removeObject: card];

    // Show card below top card.
    NSInteger count = [cards_ count];
    if(count > 1) {
        SolitaireCard* lowerCard = [cards_ objectAtIndex: count - 2]; 
        lowerCard.hidden = NO;
    }

    [super removeCard: card];
}

-(BOOL) isEmpty {
    return [cards_ count] == 0;
}

-(BOOL) isFilled {
    return [cards_ count] == 13;
}

-(void) drawSprite {
        NSRect dstRect = NSRectFromCGRect(CGRectMake(self.bounds.origin.x + 2.0f,
            self.bounds.origin.y + 2.0f, CARD_WIDTH, CARD_HEIGHT));
                
        NSBezierPath* path = [NSBezierPath bezierPath];
        [path setLineWidth: 2.0f];
        [path appendBezierPathWithRoundedRect: dstRect xRadius: 9.0f yRadius: 9.0f];
        
        NSColor* borderColor = [NSColor colorWithCalibratedRed: 0.85f green: 0.85f blue: 0.85f alpha: 0.5f];
        [borderColor setStroke];
        [path stroke];
    
        if(selected) {
            NSColor* backgroundColor = [NSColor colorWithCalibratedRed: 0.85f green: 0.85f blue: 0.85f alpha: 0.15f];
            [backgroundColor setFill];
            [path fill];
        }
    
        NSString* letter = @"A";
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment: NSCenterTextAlignment];
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSFont fontWithName:@"Helvetica" size: 52], NSFontAttributeName,
            borderColor, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    
        CGFloat newHeight = 4.0f * dstRect.size.height / 10.0f;
        dstRect.size.height = newHeight;
        dstRect.origin.y += newHeight;
    
        [letter drawInRect: dstRect withAttributes: attributes];
}

@end
