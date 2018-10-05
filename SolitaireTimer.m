//
//  SolitaireTimer.m
//  Solitaire
//
//  Created by Daniel Fontaine on 7/1/09.
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

#import "SolitaireTimer.h"
#import "SolitaireView.h"

// Private methods
@interface SolitaireTimer(NSObject)
-(void) timerFired;
@end



@implementation SolitaireTimer

-(id) initWithView: (SolitaireView*)gameView {
    if((self = [super initWithView: gameView]) != nil) {
        self.anchorPoint = CGPointMake(0.0f, 0.0f);
        self.needsDisplayOnBoundsChange = YES;
        self.bounds = CGRectMake(0, 0, 140, 40);
        self.zPosition = DRAGGING_LAYER + 1;
        self.position = CGPointMake(10, 0);
        
        timer_ = nil;
    }
    return self;
}

-(void) drawSprite {
    NSString* time = [self timeString];
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment: NSLeftTextAlignment];
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSFont fontWithName: @"Papyrus" size: 24], NSFontAttributeName,
        [NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    [time drawInRect: NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height) withAttributes: attributes];
}

-(void) startTimer {
    [self resetTimer];
}

-(void) stopTimer {
    if(timer_ != nil) [timer_ invalidate];
}

-(void) resetTimer {
    sec_ = 0;
    min_ = 0;
    hrs_ = 0;
    [self stopTimer];
    
    timer_ = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(timerFired) userInfo: nil repeats: YES];
}

-(NSString*) timeString {
    NSString* time;
    if(hrs_ == 0) time = [NSString stringWithFormat: @"%d:%02d", min_, sec_];
    else time = [NSString stringWithFormat: @"%d:%02d:%02d", hrs_, min_, sec_];
    return time;  
}

-(void) timerFired {
    sec_++;
    if(sec_ >= 60) {
        sec_ = 0;
        min_++;
    }
    if(min_ >= 60) {
        min_ = 0;
        hrs_++;
    }
    [self setNeedsDisplay];
}

@end
