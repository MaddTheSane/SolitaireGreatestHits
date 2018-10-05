//
//  SolitaireCanfieldGame.m
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

#import "SolitaireCanfieldGame.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireStock.h"
#import "SolitaireWaste.h"
#import "SolitaireFoundation.h"
#import "SolitaireTableau.h"
#import "SolitaireScoreKeeper.h"

@implementation SolitaireCanfieldGame

-(id) initWithController: (SolitaireController*)gameController {
    if((self = [super initWithController: gameController]) != nil) {
        [self reset];
    }
    return self;
}

-(void) initializeGame {    
    // Init Stock
    stock_ = [[SolitaireStock alloc] init];
    [[self view] addSprite: stock_];
    
    // Init Waste
    waste_ = [[SolitaireMultiCardWaste alloc] initWithDrawCount: 3];
    [stock_ setDelegate: waste_];
    [[self view] addSprite: waste_];
    
    // Init Foundations
    int i;
    for(i = 3; i >= 0; i--) {
        foundation_[i] = [[SolitaireFoundation alloc] init];
        [[self view] addSprite: foundation_[i]];
    }
    
    // Init Tableau
    for(i = 3; i >= 0; i--) {
        tableau_[i] = [[SolitaireTableau alloc] init];
        [[self view] addSprite: tableau_[i]];
    }
    
    // Init Reserve
    reserve_ = [[SolitaireFoundation alloc] init];
    [[self view] addSprite: reserve_];
}

-(NSString*) name {
    return @"Canfield";
}

-(void) layoutGameComponents {
    CGFloat viewWidth = [self view].layer.frame.size.width;
    CGFloat viewHeight = [self view].layer.frame.size.height;
    
    // Layout Stock
    stock_.position = CGPointMake(viewWidth / 25.0f, (viewHeight - kCardHeight) - viewHeight / 25.0f);
    
    // Layout Waste
    waste_.position = CGPointMake(stock_.frame.origin.x + 2.0f * kCardWidth, stock_.frame.origin.y);
    
    // Layout Foundations
    int i;
    CGFloat foundationX = viewWidth - kCardWidth - viewWidth / 25.0f;
    CGFloat foundationY = (viewHeight - kCardHeight) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        foundation_[i].position = CGPointMake(foundationX - i * (3.0f / 2.0f * kCardWidth), foundationY);
    }
    
    // Layout Tableau
    CGFloat tableauX = foundationX;
    CGFloat tableauY = (foundationY - kCardHeight) - viewHeight / 25.0f;

    for(i = 3; i >= 0; i--) {
        tableau_[i].position = CGPointMake(tableauX - i * (3.0f / 2.0f * kCardWidth), tableauY);
    }
    
    // Layout Reserve
    reserve_.position = CGPointMake(viewWidth / 25.0f, tableauY);
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
    waste_ = nil;
    reserve_ = nil;
    
    int i;
    for(i = 3; i >= 0; i--) foundation_[i] = nil;
    for(i = 3; i >= 0; i--) tableau_[i] = nil;
}

-(BOOL) keepsScore {
    return YES;
}

-(NSInteger) initialScore {
    return -45;
}

-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer {

    if((![fromContainer isKindOfClass: [SolitaireFoundation class]] || fromContainer == reserve_) 
        && [toContainer isKindOfClass: [SolitaireFoundation class]]) return 5;
    if([fromContainer isKindOfClass: [SolitaireFoundation class]] && fromContainer != reserve_ &&
        ![toContainer isKindOfClass: [SolitaireFoundation class]]) return -5;
    
    return 0;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [super generateSavedGameImage]; 
         
    int i;
    // Archive Stock
    [gameImage archiveGameObject: stock_ forKey: @"stock_"];
    
    // Archive Waste
    [gameImage archiveGameObject: waste_ forKey: @"waste_"];
    
    // Archive Foundations
    for(i = 0; i < 4; i++) {
        [gameImage archiveGameObject: foundation_[i] forKey: [NSString stringWithFormat: @"foundation_%i", i]];
    }
    
    // Archive Tableau
    for(i = 0; i < 4; i++) {
        [gameImage archiveGameObject: tableau_[i] forKey: [NSString stringWithFormat: @"tableau_%i", i]];
    }
    
    // Archive Reserve 
    [gameImage archiveGameObject: reserve_ forKey: @"reserve_"];
    
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
    for(i = 0; i < 4; i++) {
        foundation_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"foundation_%i", i]];
        [[self view] addSprite: foundation_[i]];
    }
    
    // Unarchive Tableau
    for(i = 0; i < 4; i++) {
        tableau_[i] = [gameImage unarchiveGameObjectForKey: [NSString stringWithFormat: @"tableau_%i", i]];
        [[self view] addSprite: tableau_[i]];
    }
    
    // Unarchive Reserve
    reserve_ = [gameImage unarchiveGameObjectForKey: @"reserve_"];
    [[self view] addSprite: reserve_];
}

// Auto-finish
-(BOOL) supportsAutoFinish {
    return YES;
}

-(void) autoFinishGame {
    int i;
    // Tableau
    for(i = 0; i < 4; i++) {
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
    
    // Reserve
    card = [reserve_ topCard];
    foundation = [self findFoundationForCard: card];
    if(foundation != nil) {
        [self dropCard: card inContainer: foundation];
        [self performSelector: @selector(autoFinishGame) withObject: nil afterDelay: 0.2f];
        return;
    }
}

-(NSInteger) cardsInPlay {
    NSInteger sum = 0;
    
    sum += [stock_ count];
    sum += [waste_ count];
    sum += [reserve_ count];
    
    int i;
    for(i = 0; i < 4; i++) sum += [tableau_[i] count];
    for(i = 0; i < 4; i++) sum += [foundation_[i] count];
    
    return sum;
}

-(void) dealNewGame {
    int i;
    
    // Deal cards to the reserve.
    for(i = 0; i < 13; i++) {
        SolitaireCard* card = [stock_ dealCard];
        card.hidden = NO;
        card.flipped = NO;
        card.position = [reserve_ nextLocation];
        [card setNeedsDisplay];
        [reserve_ addCard: card];
    }
    
    // Deal card to foundation
    SolitaireCard* foundationCard = [stock_ dealCard];
    foundationCard.hidden = NO;
    foundationCard.flipped = NO;
    foundationCard.position = [foundation_[3] nextLocation];
    [foundationCard setNeedsDisplay];
    [foundation_[3] addCard: foundationCard];
    foundationStartingValue_ = [foundationCard faceValue];
    
    // Set the foundation text
    for(i = 0; i < 4; i++) {
        foundation_[i].text = [foundationCard faceValueAbbreviation];
        [foundation_[i] setNeedsDisplay];
    }
    
    // Deal Cards to Tableau
    for(i = 0; i < 4; i++) [stock_ dealCardToTableau: tableau_[i] faceDown: NO];
}


-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([tableau count] == 0) return YES;
    
    SolitaireCard* topCard = [tableau topCard];
    if(([card suitColor] != [topCard suitColor])) {
        if(([card faceValue] == [topCard faceValue] - 1)) return YES;
        else if([topCard faceValue] == SolitaireValueAce && [card faceValue] == SolitaireValueKing) return YES;
    }
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    if([card countCardsStackedOnTop] > 0) return NO;
    
    if([foundation count] == 0) {
        if([card faceValue] == foundationStartingValue_) return YES;
        return NO;
    }
    
    SolitaireCard* topCard = [foundation topCard];
    if([card suit] == [topCard suit]) {
        if([card faceValue] == [topCard faceValue] + 1) return YES;
        else if([topCard faceValue] == SolitaireValueKing && [card faceValue] == SolitaireValueAce) return YES;
    }
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    if([tableau count] > 1) [tableau topCard].draggable = NO;
    [super dropCard: card inTableau: tableau];
}

-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau {
    if([[self.view undoManager] isUndoing]) return;
    
    if([tableau isEmpty]) {
        SolitaireCard* card = [reserve_ topCard];
         if(card != nil) [self dropCard: card inContainer: tableau];
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
