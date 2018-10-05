//
//  SolitaireGolfGame.m
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

#import "SolitaireGolfGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireStock.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireScoreKeeper.h"

// Private Methods
@interface SolitaireGolfGame(NSObject)
-(void) dealCardFromStock: (SolitaireStock*)stock;
-(void) returnCard: (SolitaireCard*)card toStock: (SolitaireStock*)stock;
@end

@implementation SolitaireGolfGame

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
    [stock_ setDelegate: self];
    [[self view] addSprite: stock_];
    
    // Init Foundation
    foundation_ = [[SolitaireFoundation alloc] init];
    [[self view] addSprite: foundation_];
    
    // Init Tableau
    int i;
    for(i = 0; i < 7; i++) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        [[self view] addSprite: tableau_[i]];
    }
}

-(NSString*) name {
    return @"Golf";
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [self view].layer.frame.size.width;
    CGFloat viewHeight = [self view].layer.frame.size.height;
    
    // Layout Stock
    stock_.position = CGPointMake(viewWidth / 25.0f, viewHeight / 25.0f);
    
    // Layout Foundation
    foundation_.position = CGPointMake(viewWidth / 25.0f + 2 * kCardWidth, viewHeight / 25.0f);
    
    // Layout Tableau
    int i;
    CGFloat tableauX = viewWidth / 25.0f;
    CGFloat tableauY = viewHeight - 4.0f/ 3.0f * kCardHeight;
    CGFloat tableauSpacing = (viewWidth - 7 * kCardWidth - 2 * (viewWidth / 25.0f)) / 6.0f;

    for(i = 0; i < 7; i++) {
        tableau_[i].position = CGPointMake(tableauX + i * (kCardWidth + tableauSpacing), tableauY);
    }
}

-(BOOL) didWin {
    int i;
    for(i = 0; i < 7; i++) {
        if(![tableau_[i] isEmpty]) return NO;
    }
    return YES;
}

-(BOOL) didLose {
    return NO;
}

-(void) reset {
    stock_ = nil;
    foundation_ = nil;
    
    int i;
    for(i = 0; i < 7; i++) tableau_[i] = nil;
}

-(BOOL) keepsScore {
    return YES;
}

-(NSInteger) initialScore {
    return 35;
}

-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer {
    if([toContainer isKindOfClass: [SolitaireFoundation class]]) return -1;
    return 0;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [super generateSavedGameImage]; 
         
    int i;
    // Archive Stock
    [gameImage archiveGameObject: stock_ forKey: @"stock_"];
        
    // Archive Foundation
    [gameImage archiveGameObject: foundation_ forKey: @"foundation_"];
    
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
    
    // Unarchive Foundations
    foundation_ = [gameImage unarchiveGameObjectForKey: @"foundation_"];
    [[self view] addSprite: foundation_];
    
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
    sum += [foundation_ count];
    
    int i;
    for(i = 0; i < 7; i++) sum += [tableau_[i] count];
    
    return sum;
}

-(void) dealNewGame {
    int i, j;
    for(j = 0; j < 7; j++)
        for(i = 0; i < 5; i++) {
            [stock_ dealCardToTableau: tableau_[j] faceDown: NO];
            if(i != 4) [[tableau_[j] topCard] setDraggable: NO];
        }
}

-(void) onStock: (SolitaireStock*) stock clicked: (NSInteger)clickCount {
    [self dealCardFromStock: stock];
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    if([foundation count] == 0) return YES;
    
    NSInteger valuePlusOne = [card faceValue] + 1;    
    NSInteger valueMinusOne = [card faceValue] - 1;
    
    SolitaireCard* topCard = [foundation topCard];
    if([topCard faceValue] == SolitaireValueKing) return NO;
    else if(valuePlusOne == [topCard faceValue] || valueMinusOne == [topCard faceValue]) return YES;
    
    return NO;
}

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card {
    if(card && [self canDropCard: card inFoundation: foundation_]) return foundation_;
    return nil;
}

// Private Methods
-(void) dealCardFromStock: (SolitaireStock*)stock {
    SolitaireCard* card = [stock dealCard];
    
    if(card) {
        [CATransaction begin];
        [CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
        card.position = stock.position;
        card.hidden = NO;
        [CATransaction commit];
        [CATransaction flush];
        
        [foundation_ addCard: card];
        card.position = card.homeLocation;
    }

    // Tell the undo manager how to undo this operation.
    [[[self.view undoManager] prepareWithInvocationTarget: self] returnCard: card toStock: stock];
}

-(void) returnCard: (SolitaireCard*)card toStock: (SolitaireStock*)stock {
    [CATransaction begin];
    [CATransaction setValue: [NSNumber numberWithFloat: 1.0f] forKey: kCATransactionAnimationDuration];
    [stock addCard: card];
    [CATransaction commit];
    [stock setNeedsDisplay];
    
    // Tell the undo manager how to undo this operation.
    [[[self.view undoManager] prepareWithInvocationTarget: self] dealCardFromStock: stock];
}

@end
