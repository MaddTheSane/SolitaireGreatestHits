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
#import "SolitaireController.h"

// Private methods
@interface SolitaireTimer(NSObject)
-(void) timerFired;
@end

@implementation SolitaireTimer

-(void) awakeFromNib {
    timer_ = nil;
    [[timeField_ cell] setBackgroundStyle: NSBackgroundStyleRaised]; 
    [self resetTimer];
}

-(void) startTimer {
    [self resetTimer];
}

-(void) stopTimer {
    if(timer_ != nil) [timer_ invalidate];
}

-(void) resetTimer {
    secs_ = 0;
    [self stopTimer];
    
    timer_ = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(timerFired) userInfo: nil repeats: YES];
}

-(NSString*) timeString {
    NSInteger hrs = secs_ / 3600;
    NSInteger mins = (secs_ - hrs * 3600) / 60;
    NSInteger secs = secs_ - hrs * 3600 - mins * 60;
    
    NSString* time;
    if(hrs == 0) time = [NSString stringWithFormat: @"%d:%02d", mins, secs];
    else time = [NSString stringWithFormat: @"%d:%02d:%02d", hrs, mins, secs];
    return time;  
}

-(NSInteger) secondsEllapsed {
    return secs_;
}

-(void) setSecondsEllapsed: (NSInteger)secs {
    secs_ = secs;
    [self updateTime];
}

-(void) updateTime {
    [timeField_ setStringValue: [NSString stringWithFormat: @"Time: %@", [self timeString]]];
}

-(void) timerFired {
    secs_++;
    [self updateTime];
}

@end
