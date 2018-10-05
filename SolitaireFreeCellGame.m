//
//  SolitaireFreeCellGame.m
//  Solitaire
//
//  Created by Daniel Fontaine on 7/13/08.
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

#import "SolitaireFreeCellGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireCell.h"
#import "SolitaireStock.h"

@implementation SolitaireFreeCellGame

-(id) initWithController: (SolitaireController*)gameController {
    if((self = [super initWithController: gameController]) != nil) {
        [self reset];
    }
    return self;
}

-(void) initializeGame {
    // Init Stock
    stock_ = [[SolitaireStock alloc] init];
    [stock_ onAddedToView: [self view]]; // Called explicitly since we don't actually add the stock to the view,
                                         // but we still want its cards added to the view.
    
    // Init Foundations
    int i;
    for(i = 3; i >= 0; i--) {
        foundation_[i] = [[SolitaireFoundation alloc] init];
        foundation_[i].text = @"A";
        [[self view] addSprite: foundation_[i]];
    }
    
    // Init Cells

    for(i = 3; i >= 0; i--) {
        cell_[i] = [[SolitaireCell alloc] init];
        [[self view] addSprite: cell_[i]];
    }
    
    // Init Tableau
    for(i = 0; i < 8; i++) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        [[self view] addSprite: tableau_[i]];
    }
}

-(NSString*) name {
    return @"Free Cell";
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [self view].frame.size.width;
    if(viewWidth < 9.0f * kCardWidth) viewWidth = 9.0f * kCardWidth;
    
    CGFloat viewHeight = [self view].frame.size.height;

    // Layout Foundations
    int i;
    CGFloat foundationX = viewWidth - kCardWidth - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - kCardHeight) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        foundation_[i].position = CGPointMake(foundationX - i * (5.0f / 4.0f * kCardWidth), foundationY);
    }
    
    // Layout Cells
    CGFloat cellX = viewWidth / 25.0f;
    CGFloat cellY = (viewHeight - kCardHeight) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        cell_[i].position = CGPointMake(cellX + i * (5.0f / 4.0f * kCardWidth), cellY);
    }
    
    // Layout Tableau
    CGFloat tableauX = viewWidth / 25.0f;
    CGFloat tableauY = foundationY - (5.0f / 4.0f * kCardHeight);
    CGFloat tableauSpacing = (viewWidth - 8 * kCardWidth - 2 * (viewWidth / 25.0f)) / 7.0f;

    for(i = 0; i < 8; i++) {
        tableau_[i].position = CGPointMake(tableauX + i * (kCardWidth + tableauSpacing), tableauY);
    }
}

-(BOOL) didWin {
    int i;
    for(i = 3; i >= 0; i--) {
        if(![foundation_[i] isFilled]) return NO;
    }
    return YES;
}

-(BOOL) didLose {
    return NO;
}

-(void) reset {
    stock_ = nil;

    int i;
    for(i = 3; i >= 0; i--) foundation_[i] = nil;
    for(i = 3; i >= 0; i--) cell_[i] = nil;
    for(i = 0; i < 8; i++) tableau_[i] = nil; 
}

-(NSInteger) cardsInPlay {
    return 0;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [super generateSavedGameImage]; 
            
    // Archive Stock
    [gameImage archiveGameObject: stock_ forKey: @"stock_"];
    
    // Archive Foundations
    int i;
    for(i = 0; i < 4; i++) {
        [gameImage archiveGameObject: foundation_[i] forKey: [NSString stringWithFormat: @"foundation_%i", i]];
    }
    
    // Archive Tableau
    for(i = 0; i < 8; i++) {
        [gameImage archiveGameObject: tableau_[i] forKey: [NSString stringWithFormat: @"tableau_%i", i]];
    }
    
    // Archive Cells
    for(i = 0; i < 4; i++) {
        [gameImage archiveGameObject: cell_[i] forKey: [NSString stringWithFormat: @"cell_%i", i]];
    }
    
    return gameImage;
}

-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage {
    [super loadSavedGameImage: gameImage];

    // Unarchive Stock
    stock_ = [gameImage unarchiveGameObjectForKey: @"stock_"];
    [[self view] addSprite: stock_];
        
    // Unarchive Foundations
    int i;
    for(i = 0; i < 4; i++) {
        foundation_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"foundation_%i", i]];
        [[self view] addSprite: foundation_[i]];
    }
    
    // Unarchive Tableau
    for(i = 0; i < 8; i++) {
        tableau_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"tableau_%i", i]];
        [[self view] addSprite: tableau_[i]];
    }
    
    // Unarchive Cells
    for(i = 0; i < 4; i++) {
        cell_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"cell_%i", i]];
        [[self view] addSprite: cell_[i]];
    }
}

// Auto-finish
-(BOOL) supportsAutoFinish {
    return YES;
}

-(void) autoFinishGame {
    int i;
    // Tableau
    for(i = 0; i < 8; i++) {
        SolitaireCard* card = [tableau_[i] topCard];
        if(card == nil) continue;
        SolitaireFoundation* foundation = [self findFoundationForCard: card];
        if(foundation != nil) {
            [self dropCard: card inContainer: foundation];
            [self performSelector: @selector(autoFinishGame) withObject: nil afterDelay: 0.2f];
            return;
        }
    }
    
    // Cells
    for(i = 0; i < 4; i++) {
        SolitaireCard* card = [cell_[i] topCard];
        if(card == nil) continue;
        SolitaireFoundation* foundation = [self findFoundationForCard: card];
        if(foundation != nil) {
            [self dropCard: card inContainer: foundation];
            [self performSelector: @selector(autoFinishGame) withObject: nil afterDelay: 0.2f];
            return;
        }
    }
}

-(void) dealNewGame {
    int pos = 0;
    while(![stock_ isEmpty]) {
        [stock_ dealCardToTableau: tableau_[pos] faceDown: NO];
        pos++;
        if(pos > 7) pos = 0;
    }
    
    int i;
    for(i = 0; i < 8; i++) {
        int pos = [tableau_[i] count] - 2;
        while(pos >= 0) {
            SolitaireCard* card = [tableau_[i] cardAtPosition: pos];
            if(([card.nextCard faceValue] != [card faceValue] - 1) ||
               ([card.nextCard suitColor] == [card suitColor]) ||
               !card.nextCard.draggable) card.draggable = NO;
            pos--;
        }
    }
}

-(NSInteger) freeCellCount {
    int i;
    NSInteger count = 0;
    for(i = 3; i >= 0; i--) {
        if([cell_[i] isEmpty]) count++;
    }
    return count;
}

-(NSInteger) freeTableauCount {
    int i;
    NSInteger count = 0;
    for(i = 0; i < 8; i++) {
        if([tableau_[i] isEmpty]) count++;
    }
    return count;
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([card countCardsStackedOnTop] > [self freeCellCount] + [self freeTableauCount]) return NO;
    else if([tableau isEmpty] && [card countCardsStackedOnTop] > [self freeCellCount] + [self freeTableauCount] - 1) return NO;

    if([tableau count] == 0) return YES;
    
    SolitaireCard* topCard = [tableau topCard];
    if(topCard.flipped) return NO;

    if(([card faceValue] == [topCard faceValue] - 1) && ([card suitColor] != [topCard suitColor]))
        return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    if([card countCardsStackedOnTop] > 0) return NO;

    if([foundation count] == 0) {
        if([card faceValue] == SolitaireValueAce) return YES;
        return NO;
    }
    
    SolitaireCard* topCard = [foundation topCard];
    if([card suit] == [topCard suit] && [card faceValue] == [topCard faceValue] + 1) return YES;
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell {
    if([cell isEmpty] && card.nextCard == nil) return YES;
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    [super dropCard: card inTableau: tableau];
        
    int pos = [tableau count] - 2;
    while(pos >= 0) {
        SolitaireCard* card = [tableau cardAtPosition: pos];
        if(([card.nextCard faceValue] == [card faceValue] - 1) &&
            ([card.nextCard suitColor] != [card suitColor]) && card.nextCard.draggable) card.draggable = YES;
        else card.draggable = NO;
        pos--;
    }

}

-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau {
    int pos = [tableau count] - 2;
    while(pos >= 0) {
        SolitaireCard* card = [tableau cardAtPosition: pos];
        if(([card.nextCard faceValue] == [card faceValue] - 1) &&
            ([card.nextCard suitColor] != [card suitColor]) && card.nextCard.draggable) card.draggable = YES;
        else card.draggable = NO;
        pos--;
    }
}

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card {
    if (card == nil) return nil;

    int i;
    for(i = 3; i >= 0; i--)
        if(card.container == foundation_[i]) break;
        else if([self canDropCard: card inFoundation: foundation_[i]])
            return foundation_[i];
    return nil;
}

@end
