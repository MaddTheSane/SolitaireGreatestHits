//
//  SolitaireScorpianGame.m
//  Solitaire
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

#import "SolitaireScorpianGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireStock.h"
#import "SolitaireTableau.h"
#import "SolitaireScoreKeeper.h"

// Private Methods
@interface SolitaireScorpianGame(NSObject)
-(void) dealMoreCardsFromStock: (SolitaireStock*)stock animated: (BOOL)animate;
-(void) returnCards: (NSArray*)cards toStock: (SolitaireStock*)stock;
@end

@implementation SolitaireScorpianGame

-(id) initWithController: (SolitaireController*)gameController {
    if((self = [super initWithController: gameController]) != nil) {
        [self reset];
    }
    return self;
}

-(void) initializeGame {    
    // Init Stock
    stock_ = [[SolitaireStock alloc] init];
    stock_.disableRestock = YES;
    stock_.reclickDelay = 1.5f;
    [stock_ setDelegate: self];
    [[self view] addSprite: stock_];
        
    // Init Tableau
    int i;
    for(i = 0; i < 7; i++) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        tableau_[i].text = @"K";
        [[self view] addSprite: tableau_[i]];
    }
}

-(NSString*) name {
    return @"Scorpian";
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [self view].layer.frame.size.width;
    CGFloat viewHeight = [self view].layer.frame.size.height;
    
    // Layout Stock
    stock_.position = CGPointMake(viewWidth / 25.0f, viewHeight / 25.0f);
        
    int i;
    CGFloat tableauX = viewWidth / 75.0f;
    CGFloat tableauY = viewHeight - 4.0f/ 3.0f * kCardHeight;
    CGFloat tableauSpacing = (viewWidth - 8 * kCardWidth - 2 * (viewWidth / 75.0f)) / 7.0f;

    // Layout Stock
    stock_.position = CGPointMake(tableauX, tableauY);

    // Layout Tableau
    for(i = 0; i < 7; i++) {
        tableau_[i].position = CGPointMake(tableauX + (i + 1) * (kCardWidth + tableauSpacing), tableauY);
    }
}

-(BOOL) didWin {
    NSInteger correctStacks = 0;
    int i, j;
    for(j = 0; j < 7; j++) {
        // Check tableau j
        if([tableau_[j] count] != 13) continue;
        BOOL isCorrect = YES;
        for(i = 0; i < 12; i++) {
            SolitaireCard* card = [tableau_[j] cardAtPosition: i];
            SolitaireCard* stackedCard = [tableau_[j] cardAtPosition: i + 1];
            if([stackedCard faceValue] != [card faceValue] - 1 || [stackedCard suit] != [card suit]) {
                isCorrect = NO;
                break;
            }
        }
        if(isCorrect) correctStacks++;
    }
    
    if(correctStacks == 4) return YES;
    return NO;
}

-(BOOL) didLose {
    return NO;
}

-(void) reset {
    stock_ = nil;
    
    int i;
    for(i = 0; i < 7; i++) tableau_[i] = nil;
}

-(BOOL) keepsScore {
    return NO;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [super generateSavedGameImage]; 
         
    int i;
    // Archive Stock
    [gameImage archiveGameObject: stock_ forKey: @"stock_"];
        
    // Archive Tableau
    for(i = 0; i < 7; i++) {
        [gameImage archiveGameObject: tableau_[i] forKey: [NSString stringWithFormat: @"tableau_%i", i]];
    }
    
    return gameImage;
}

-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage {
    [super loadSavedGameImage: gameImage];

    // Unarchive Stock
    stock_ = [gameImage unarchiveGameObjectForKey: @"stock_"];
    [stock_ setDelegate: self];
    [[self view] addSprite: stock_];
        
    // Unarchive Tableau
    int i;
    for(i = 0; i < 7; i++) {
        tableau_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"tableau_%i", i]];
        [[self view] addSprite: tableau_[i]];
    }
}

-(NSInteger) cardsInPlay {
    NSInteger sum = 0;
    
    sum += [stock_ count];
    
    int i;
    for(i = 0; i < 7; i++) sum += [tableau_[i] count];
    
    return sum;
}

-(void) dealNewGame {
    int i, j;
    for(j = 0; j < 7; j++)
        for(i = 0; i < 7; i++) {
            if(j < 4 && i < 2) [stock_ dealCardToTableau: tableau_[j] faceDown: YES];
            else [stock_ dealCardToTableau: tableau_[j] faceDown: NO];
        }
}

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount {
    [self dealMoreCardsFromStock: stock animated: YES];
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([tableau isEmpty] && [card faceValue] == SolitaireValueKing) return YES;
    SolitaireCard* topCard = [tableau topCard];
    if(!topCard.flipped && [card faceValue] == [topCard faceValue] - 1 && [card suit] == [topCard suit]) return YES;
    return NO;
}

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card {
    return nil;
}

// Private Methods
-(void) dealMoreCardsFromStock: (SolitaireStock*)stock animated: (BOOL)animate {
    NSArray* stockCards = [stock cards];
    
    // Tell the undo manager how to undo this operation.
    [[[self.view undoManager] prepareWithInvocationTarget: self] returnCards: stockCards toStock: stock_];
    
    // Deal the cards
    int i;
    for(i = 0; i < 3; i++) {
        if(![stock_ isEmpty]) { 
            if(animate) {
                [stock performSelector: @selector(animateCardToTableau:) withObject: tableau_[i] afterDelay: 0.25 * i];
            }
            else {
                SolitaireCard* card = [stock dealCard];
                
                [CATransaction begin];
                [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
                card.position = [tableau_[i] nextLocation];
                [CATransaction commit];
                [CATransaction flush];
                
                [self dropCard: card inTableau: tableau_[i]];
                card.hidden = NO;
            }
        }
    }
}

-(void) returnCards: (NSArray*)cards toStock: (SolitaireStock*)stock {
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithFloat: 1.0f] forKey: kCATransactionAnimationDuration];
    for(SolitaireCard* card in cards) {
        [stock_ addCard: card];
    }
    [CATransaction commit];
    [stock_ setNeedsDisplay];
    
    // Tell the undo manager how to undo this operation.
    [[[self.view undoManager] prepareWithInvocationTarget: self] dealMoreCardsFromStock: stock animated: NO];
}

@end
