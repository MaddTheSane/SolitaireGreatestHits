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
@interface SolitaireTimer()
-(void) timerFired:(NSTimer *)timer;
@end

@implementation SolitaireTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        timeFormatter = [[NSDateComponentsFormatter alloc] init];
        //TODO: only show hour place if we're over an hour
        timeFormatter.zeroFormattingBehavior = 0;
        timeFormatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;

    }
    return self;
}

-(void) awakeFromNib {
    timer_ = nil;
    [[timeField_ cell] setBackgroundStyle: NSBackgroundStyleRaised]; 
    [self resetTimer];
}

-(void) startTimer {
    [self resetTimer];
}

-(void) stopTimer {
    if(timer_ != nil) {
        [timer_ invalidate];
        timer_ = nil;
    }
    startTime = nil;
}

-(void) resetTimer {
    secs_ = 0;
    [self stopTimer];
    startTime = [NSDate date];

    timer_ = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(timerFired:) userInfo: nil repeats: YES];
}

-(NSString*) timeString {
    return [timeFormatter stringFromTimeInterval:secs_];
}

@synthesize secondsElapsed=secs_;

-(void) setSecondsElapsed: (NSInteger)secs {
    secs_ = secs;
    [self updateTime];
}

-(void) updateTime {
    [timeField_ setStringValue: [NSString stringWithFormat: NSLocalizedString(@"Time: %@", @"Time: %@"), [self timeString]]];
}

-(void) timerFired:(NSTimer *)timer {
    secs_++;
    [self updateTime];
}

- (NSTimeInterval)accurateSecondsElapsed {
    return [[NSDate date] timeIntervalSinceDate:startTime];
}

@end
