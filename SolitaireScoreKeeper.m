//
//  SolitaireScoreKeeper.m
//  Solitaire
//
//  Created by Daniel Fontaine on 7/11/09.
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

#import "SolitaireScoreKeeper.h"
#import "SolitaireView.h"

@implementation SolitaireScoreKeeper

-(void) awakeFromNib {
    [[scoreField_ cell] setBackgroundStyle: NSBackgroundStyleRaised]; 
    hideScore_ = NO;
    [self setInitialScore: 0];
}

-(void) setInitialScore: (NSInteger)value {
    score = value;
    [self updateScore];
}

-(void) hideScore: (BOOL)value {
    hideScore_ = value;
    if(hideScore_) [scoreField_ setStringValue: @""];
    else [self updateScore];
}

-(void) updateScore {
    if(!hideScore_) [scoreField_ setStringValue: [NSString stringWithFormat: @"Score: %i", score]];
}

// Custom setter and getter method for score
-(void) setScore: (NSInteger)value {
    [[[view_ undoManager] prepareWithInvocationTarget: self] setScore: score];
    score = value;
    [self updateScore];
}

-(NSInteger) score {
    return score;
}

@end
