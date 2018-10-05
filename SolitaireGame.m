//
//  SolitaireGame.m
//  Solitaire
//
//  Created by Daniel Fontaine on 6/21/08.
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

#import "SolitaireGame.h"
#import "SolitaireController.h"
#import "SolitaireView.h"
#import "SolitaireSavedGameImage.h"
#import "SolitaireCard.h"
#import "SolitaireTableau.h"
#import "SolitaireFoundation.h"
#import "SolitaireCell.h"
#import "SolitaireWaste.h"
#import "SolitaireTimer.h"
#import "SolitaireScoreKeeper.h"

// Private methods
@interface SolitaireGame(NSObject)
-(void) victoryAnimationForCard: (SolitaireCard*)card;
@end

@implementation SolitaireGame

@synthesize controller;

-(id) initWithController: (SolitaireController*)gameController {
    if((self = [super init]) != nil) {
        controller = gameController;
    }
    return self;
}

-(SolitaireView*) view {
    return self.controller.view;
}

-(NSString*) name {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSUInteger) gameSeed {
    return gameSeed_;
}

-(void) gameWithSeed: (NSUInteger)seed {
    srand(seed);
    gameSeed_ = seed;
}

-(void) initializeGame {}

-(void) layoutGameComponents {}

-(void) startGame {
    [controller.scoreKeeper setInitialScore: [self initialScore]];
    [self.controller.timer resetTimer];
    
    [self dealNewGame];
    [[self view] setNeedsDisplay: YES];
    
    [self.controller.timer startTimer];
}

-(BOOL) didWin {
    return NO;
}

-(BOOL) didLose {
    return NO;
}

-(void) reset {}

-(NSInteger) cardsInPlay {
    return 0;
}

// Scoring
-(BOOL) keepsScore {
    return NO;
}

-(NSInteger) initialScore {
    return 0;
}

-(NSInteger) scoreForCard: (SolitaireCard*)card movedFromContainer: (SolitaireCardContainer*) fromContainer
    toContainer: (SolitaireCardContainer*)toContainer {
    return 0;
}

-(NSInteger) scoreForCardFlipped: (SolitaireCard*)card {
    return 0;
}

// Saving and loading game
-(SolitaireSavedGameImage*) generateSavedGameImage {
    SolitaireSavedGameImage* gameImage = [[SolitaireSavedGameImage alloc] initWithGameName: [self name]];
    [gameImage archiveGameSeed: [self gameSeed]];
    return gameImage;
}

-(void) loadSavedGameImage: (SolitaireSavedGameImage*)gameImage {
    gameSeed_ = [gameImage unarchiveGameSeed];
}

// Auto-finish
-(BOOL) supportsAutoFinish {
    return NO;
}

-(void) autoFinishGame {}

-(void) dealNewGame {
    [self doesNotRecognizeSelector:_cmd];
}

-(BOOL) canDropCard: (SolitaireCard*) card inContainer: (SolitaireCardContainer*) container {
    if([container isKindOfClass: [SolitaireTableau class]])
        return [self canDropCard: card inTableau: (SolitaireTableau*)container];
    else if([container isKindOfClass: [SolitaireFoundation class]])
        return [self canDropCard: card inFoundation: (SolitaireFoundation*)container];
    else if([container isKindOfClass: [SolitaireCell class]])
        return [self canDropCard: card inCell: (SolitaireCell*)container];
    else if([container isKindOfClass: [SolitaireWaste class]])
        return [self canDropCard: card inWaste: (SolitaireWaste*)container];
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell {
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste {
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inContainer: (SolitaireCardContainer*) container {
    SolitaireCardContainer* oldContainer = card.container;

    if([container isKindOfClass: [SolitaireTableau class]])
        [self dropCard: card inTableau: (SolitaireTableau*)container];
    else if([container isKindOfClass: [SolitaireFoundation class]])
        [self dropCard: card inFoundation: (SolitaireFoundation*)container];
    else if([container isKindOfClass: [SolitaireCell class]])
        [self dropCard: card inCell: (SolitaireCell*)container];
    else if([container isKindOfClass: [SolitaireWaste class]])
        [self dropCard: card inWaste: (SolitaireWaste*)container];
        
    // Tell the undo manager how to undo this operation.
    [[self.view undoManager] beginUndoGrouping];
    [[[self.view undoManager] prepareWithInvocationTarget: self] dropCard: card inContainer: oldContainer];
    
    // Keep score
    if(![[self.view undoManager] isUndoing]) {
        if([self keepsScore] && oldContainer != nil)
            self.controller.scoreKeeper.score +=
                [self scoreForCard: card movedFromContainer: oldContainer toContainer: container];
    }
    [[self.view undoManager] endUndoGrouping];

    
    [self onCard: card removedFromContainer: oldContainer];
    if([self didWin]) [self onGameWon];
}

-(void) dropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    [tableau addCard: card];
    card.position = card.homeLocation;
}

-(void) dropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    [foundation addCard: card];
    card.position = card.homeLocation;
}

-(void) dropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell {
    [cell addCard: card];
    card.position = card.homeLocation;
}

-(void) dropCard: (SolitaireCard*) card inWaste: (SolitaireWaste*) waste {
    [waste addCard: card];
    card.position = card.homeLocation;
}

-(void) dropCard: (SolitaireCard*) card inStock: (SolitaireStock*) stock {
    [stock addCard: card];
    card.position = card.homeLocation;
}

-(void) onCard: (SolitaireCard*) card removedFromContainer: (SolitaireCardContainer*) container {
    if([container isKindOfClass: [SolitaireTableau class]])
        [self onCard: card removedFromTableau: (SolitaireTableau*)container];
    else if([container isKindOfClass: [SolitaireFoundation class]])
        [self onCard: card removedFromFoundation: (SolitaireFoundation*)container];
    else if([container isKindOfClass: [SolitaireCell class]])
        [self onCard: card removedFromCell: (SolitaireCell*)container];
}

-(void) onCard: (SolitaireCard*) card removedFromTableau: (SolitaireTableau*) tableau {}
-(void) onCard: (SolitaireCard*) card removedFromFoundation: (SolitaireFoundation*) foundation {}
-(void) onCard: (SolitaireCard*) card removedFromCell: (SolitaireCell*) cell {}

-(SolitaireFoundation*) findFoundationForCard: (SolitaireCard*) card {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) onGameWon {
    [self.controller.timer stopTimer];
    
    NSArray* containers = [[self view] containers];
    NSInteger cardCount = 0;    
    
    for(SolitaireCardContainer* container in containers) {
        for(SolitaireCard* card in [[container cards] reverseObjectEnumerator]) {
            [self performSelector: @selector(victoryAnimationForCard:) withObject: card afterDelay: cardCount++ * .1];
        }
    }
    [[self view] performSelector: @selector(showWinSheet) withObject: nil afterDelay: (cardCount + 5) * 0.1];
}

-(void) victoryAnimationForCard: (SolitaireCard*)card {
    CGFloat width = [self view].layer.bounds.size.width;
    CGFloat height = [self view].layer.bounds.size.height;
    
    card.nextCard = nil;
    card.draggable = NO;
    [card.container removeCard: card];
    card.container = nil;

    CGPoint location = CGPointMake(width * rand() / (float)RAND_MAX, height * rand() / (float)RAND_MAX);
    CATransform3D transform = CATransform3DMakeRotation(3.14159 * rand() / (float)RAND_MAX, 0, 0, 1);
    [card animateToPosition: location andTransform: transform afterDelay: 0.2];
}

@end
