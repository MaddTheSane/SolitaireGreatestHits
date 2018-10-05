//
//  SolitaireYukonGame.m
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

#import "SolitaireYukonGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireStock.h"
#import "SolitaireWaste.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireScoreKeeper.h"

@implementation SolitaireYukonGame


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
    
    // Init Tableau
    for(i = 0; i < 7; i++) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        tableau_[i].text = @"K";
        [[self view] addSprite: tableau_[i]];
    }
}

-(NSString*) name {
    return @"Yukon";
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [self view].layer.frame.size.width;
    CGFloat viewHeight = [self view].layer.frame.size.height;
    
    // Layout Foundations
    int i;
    CGFloat foundationX = viewWidth - kCardWidth - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - kCardHeight) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        foundation_[i].position = CGPointMake(foundationX - i * (3.0f / 2.0f * kCardWidth), foundationY);
    }
    
    // Layout Tableau
    CGFloat tableauX = viewWidth / 25.0f;
    CGFloat tableauY = foundationY - (5.0f / 4.0f * kCardHeight);
    CGFloat tableauSpacing = (viewWidth - 7 * kCardWidth - 2 * (viewWidth / 25.0f)) / 6.0f;
    
    for(i = 0; i < 7; i++) {
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
    for(i = 0; i < 7; i++) tableau_[i] = nil;
}

// Scoring
-(BOOL) keepsScore {
    return YES;
}

-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer {

    if([toContainer isKindOfClass: [SolitaireFoundation class]]) return 10;
    else if([fromContainer isKindOfClass: [SolitaireFoundation class]]) return -15;

    return 0;
}

-(NSInteger) scoreForCardFlipped: (SolitaireCard*)card {
    return 5;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [super generateSavedGameImage]; 
         
    int i;
    // Archive Stock
    [gameImage archiveGameObject: stock_ forKey: @"stock_"];
        
    // Archive Foundations
    for(i = 0; i < 4; i++) {
        [gameImage archiveGameObject: foundation_[i] forKey: [NSString stringWithFormat: @"foundation_%i", i]];
    }
    
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
    [[self view] addSprite: stock_];
    
    // Unarchive Foundations
    int i;
    for(i = 0; i < 4; i++) {
        foundation_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"foundation_%i", i]];
        [[self view] addSprite: foundation_[i]];
    }
    
    // Unarchive Tableau
    for(i = 0; i < 7; i++) {
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
    for(i = 0; i < 7; i++) {
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
}

-(NSInteger) cardsInPlay {
    NSInteger sum = 0;
    
    sum += [stock_ count];
    
    int i;
    for(i = 0; i < 7; i++) sum += [tableau_[i] count];
    for(i = 0; i < 4; i++) sum += [foundation_[i] count];
    
    return sum;
}

-(void) dealNewGame {
    [stock_ dealCardToTableau: tableau_[0] faceDown: NO];

    int i, j;
    for(j = 1; j < 7; j++)
        for(i = 0; i < j + 5; i++) {
            if(i < j) [stock_ dealCardToTableau: tableau_[j] faceDown: YES];
            else [stock_ dealCardToTableau: tableau_[j] faceDown: NO];
        }
}


-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {

    if([tableau count] == 0) {
        if([card faceValue] == SolitaireValueKing) return YES;
        return NO;
    }
    
    SolitaireCard* topCard = [tableau topCard];
    if(topCard.flipped) return NO;

    if(([card faceValue] == [topCard faceValue] - 1) && ([card suit] != [topCard suit]))
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
