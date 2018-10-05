//
//  SolitaireSingleCardKlondikeGame.m
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

#import "SolitaireSingleCardKlondikeGame.h"
#import "SolitaireView.h"
#import "SolitaireCard.h"
#import "SolitaireStock.h"
#import "SolitaireWaste.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireCell.h"

@implementation SolitaireSingleCardKlondikeGame

-(void) initializeGame {        
    // Init Stock
    stock_ = [[SolitaireStock alloc] init];
    [[self view] addSprite: stock_];
    
    // Init Waste
    waste_ = [[SolitaireSimpleWaste alloc] init];
    [stock_ setDelegate: waste_];
    [[self view] addSprite: waste_];
    
    // Init Foundations
    int i;
    for(i = 3; i >= 0; i--) {
        foundation_[i] = [[SolitaireFoundation alloc] init];
        foundation_[i].text = @"A";
        [[self view] addSprite: foundation_[i]];
    }
    
    // Init Tableau
    for(i = 0; i < 7; i++) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        tableau_[i].text = @"K";
        [[self view] addSprite: tableau_[i]];
    }
}

-(NSString*) name {
    return @"Single Card Klondike";
}

@end
