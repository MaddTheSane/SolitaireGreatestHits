//
//  SolitaireFortyThievesGame.m
//  Solitaire
//
//  Created by Daniel Fontaine on 7/9/09.
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

#import "SolitaireFortyThievesGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireStock.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireWaste.h"

@implementation SolitaireFortyThievesGame

-(id) initWithController: (SolitaireController*)gameController {
    if((self = [super initWithController: gameController]) != nil) {
        [self reset];
    }
    return self;
}

-(NSString*) name {
    return @"Forty Thieves";
}

-(void) initializeGame {    
    // Init Foundations
    int i;
    for(i = 0; i < 4; i++) {
        foundation_[i] = [[SolitaireFoundation alloc] init];
        foundation_[i].text = @"A";
        [[self view] addSprite: foundation_[i]];
    }
    
    for(i = 4; i < 8; i++) {
        foundation_[i] = [[SolitaireFoundation alloc] init];
        foundation_[i].text = @"A";
        [[self view] addSprite: foundation_[i]];
    }
    
    // Init Stock
    stock_ = [[SolitaireStock alloc] initWithDeckCount: 2];
    stock_.disableRestock = YES;
    [[self view] addSprite: stock_];
    
    // Init Waste
    waste_ = [[SolitaireSimpleWaste alloc] init];
    [stock_ setDelegate: waste_];
    [[self view] addSprite: waste_];
    
    // Init Tableau
    for(i = 0; i < 10; i++) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        tableau_[i].delegate = self;
        [[self view] addSprite: tableau_[i]];
    }
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [[self view] frame].size.width;
    CGFloat viewHeight = [[self view] frame].size.height;
    
    CGFloat foundationSpacing = (viewWidth - 10 * kCardWidth) / 11.0f;
    
    // Layout Foundations
    int i;
    CGFloat foundationX = foundationSpacing;
    CGFloat foundationY = (viewHeight - kCardHeight) - viewHeight / 25.0f;

    for(i = 0; i < 4; i++) {
        foundation_[i].position = CGPointMake(foundationX + i * (kCardWidth + foundationSpacing), foundationY);
    }
    
    for(i = 4; i < 8; i++) {
        foundation_[i].position = CGPointMake(foundationX + (i + 2) * (kCardWidth + foundationSpacing), foundationY);
    }
    
    // Layout Stock
    stock_.position = CGPointMake(foundationX + 4 * (kCardWidth + foundationSpacing), foundationY);
    
    // Layout Waste
    waste_.position = CGPointMake(foundationX + 5 * (kCardWidth + foundationSpacing), foundationY);

    
    // Layout Tableau
    CGFloat tableauX = viewWidth / 75.0f;
    CGFloat tableauY = foundationY - (5.0f / 4.0f * kCardHeight);
    CGFloat tableauSpacing = (viewWidth - 10 * kCardWidth - 2 * (viewWidth / 75.0f)) / 9.0f;

    for(i = 0; i < 10; i++) {
        tableau_[i].position = CGPointMake(tableauX + i * (kCardWidth + tableauSpacing), tableauY);
    }
}

-(BOOL) didWin {
    int i;
    for(i = 7; i >= 0; i--) {
        if(![foundation_[i] isFilled]) return NO;
    }
    return YES;
}

-(BOOL) didLose {
    return NO;
}

-(void) reset {
    stock_ = nil;
    waste_ = nil;
    
    int i;
    for(i = 7; i >= 0; i--) foundation_[i] = nil;
    for(i = 0; i < 10; i++) tableau_[i] = nil; 
}

// Scoring
-(BOOL) keepsScore {
    return YES;
}

-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer {

    if([fromContainer class] != [SolitaireFoundation class] && [toContainer class] == [SolitaireFoundation class])
        return 5;
    else if([fromContainer class] == [SolitaireFoundation class] && [toContainer class] != [SolitaireFoundation class])
        return -5;

    return 0;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [super generateSavedGameImage]; 
         
    // Archive Stock
    [gameImage archiveGameObject: stock_ forKey: @"stock_"];
    
    // Archive Waste
    [gameImage archiveGameObject: waste_ forKey: @"waste_"];
    
    // Archive Foundations
    int i;
    for(i = 0; i < 8; i++) {
        [gameImage archiveGameObject: foundation_[i] forKey: [NSString stringWithFormat: @"foundation_%i", i]];
    }
    
    // Archive Tableau
    for(i = 0; i < 10; i++) {
        [gameImage archiveGameObject: tableau_[i] forKey: [NSString stringWithFormat: @"tableau_%i", i]];
    }
    
    return gameImage;
}

-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage {
    [super loadSavedGameImage: gameImage];

    // Unarchive Stock
    stock_ = [gameImage unarchiveGameObjectForKey: @"stock_"];
    [[self view] addSprite: stock_];
    
    // Unarchive Waste
    waste_ = [gameImage unarchiveGameObjectForKey: @"waste_"];
    [stock_ setDelegate: waste_];
    [[self view] addSprite: waste_];
    
    // Unarchive Foundations
    int i;
    for(i = 0; i < 8; i++) {
        foundation_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"foundation_%i", i]];
        [[self view] addSprite: foundation_[i]];
    }
    
    // Unarchive Tableau
    for(i = 0; i < 10; i++) {
        tableau_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"tableau_%i", i]];
        [[self view] addSprite: tableau_[i]];
    }
}

// Auto-finish
-(BOOL) supportsAutoFinish {
    return YES;
}

-(void) autoFinishGame {
    int i;
    // Tableau
    for(i = 0; i < 10; i++) {
        SolitaireCard* card = [tableau_[i] topCard];
        if(card == nil) continue;
        SolitaireFoundation* foundation = [self findFoundationForCard: card];
        if(foundation != nil) {
            if(card.flipped) card.flipped = NO;
            [self dropCard: card inContainer: foundation];
            [self performSelector: @selector(autoFinishGame) withObject: nil afterDelay: 0.2f];
            return;
        }
    }
    
    // Waste
    SolitaireCard* card = [waste_ topCard];
    SolitaireFoundation* foundation = [self findFoundationForCard: card];
    if(foundation != nil) {
        [self dropCard: card inContainer: foundation];
        [self performSelector: @selector(autoFinishGame) withObject: nil afterDelay: 0.2f];
        return;
    }
}

-(void) dealNewGame {
    NSInteger cardsToDeal = 40;
    int pos = 0;
    while(cardsToDeal > 0) {
        [stock_ dealCardToTableau: tableau_[pos] faceDown: NO];
        pos = (pos + 1) % 10;
        cardsToDeal--;
    }
    
    int i;
    for(i = 0; i < 10; i++) {
        [tableau_[i] cardAtPosition: [tableau_[i] count] - 1].draggable = YES;
        int pos = [tableau_[i] count] - 2;
        while(pos >= 0) {
            SolitaireCard* card = [tableau_[i] cardAtPosition: pos];
            card.draggable = NO;
            pos--;
        }
    }
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([tableau count] == 0) return YES;
    
    SolitaireCard* topCard = [tableau topCard];
    if([card faceValue] == [topCard faceValue] - 1 && [card suit] == [topCard suit])
        return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    if([card countCardsStackedOnTop] > 0) return NO;
    if([foundation count] == 0 && [card faceValue] == SolitaireValueAce) return YES;
    
    SolitaireCard* topCard = [foundation topCard];
    if([card faceValue] == [topCard faceValue] + 1 && [card suit] == [topCard suit])
        return YES;
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    SolitaireCard* topCard = [tableau topCard];
    topCard.draggable = NO;
    [super dropCard: card inTableau: tableau];
}

-(void) dropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    card.draggable = NO;
    [super dropCard: card inFoundation: foundation];
}

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card {
    if (card == nil) return nil;
    
    int i;
    for(i = 7; i >= 0; i--)
        if(card.container == foundation_[i]) break;
        else if([self canDropCard: card inFoundation: foundation_[i]])
            return foundation_[i];
    return nil;
}

@end
