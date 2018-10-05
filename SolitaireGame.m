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
#import "SolitaireView.h"
#import "SolitaireCard.h"
#import "SolitaireTableau.h"
#import "SolitaireFoundation.h"
#import "SolitaireCell.h"
#import "SolitaireWaste.h"
#import "SolitaireTimer.h"

// Private methods
@interface SolitaireGame(NSObject)
-(void) victoryAnimationForCard: (SolitaireCard*)card;
@end

@implementation SolitaireGame

-(id) initWithView: (SolitaireView*)view {
    if((self = [super init]) != nil) {
        view_ = view;
    }
    return self;
}

-(SolitaireView*) view {
    return view_;
}

-(void) initializeGame {}
-(void) startGame {}
-(void) viewResized: (NSSize)size {}

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

-(BOOL) canDropCard: (SolitaireCard*) card inContainer: (SolitaireCardContainer*) container {
    if([container class] == [SolitaireTableau class])
        return [self canDropCard: card inTableau: (SolitaireTableau*)container];
    else if([container class] == [SolitaireFoundation class])
        return [self canDropCard: card inFoundation: (SolitaireFoundation*)container];
    else if([container class] == [SolitaireCell class])
        return [self canDropCard: card inCell: (SolitaireCell*)container];
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inTableau: (SolitaireTableau*) tableau {
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inFoundation: (SolitaireFoundation*) foundation {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

-(BOOL) canDropCard: (SolitaireCard*) card inCell: (SolitaireCell*) cell {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

-(void) dropCard: (SolitaireCard*) card inContainer: (SolitaireCardContainer*) container {
    SolitaireCardContainer* oldContainer = card.container;

    if([container class] == [SolitaireTableau class])
        [self dropCard: card inTableau: (SolitaireTableau*)container];
    else if([container class] == [SolitaireFoundation class])
        [self dropCard: card inFoundation: (SolitaireFoundation*)container];
    else if([container class] == [SolitaireCell class])
        [self dropCard: card inCell: (SolitaireCell*)container];
    else if([container class] == [SolitaireWaste class])
        [self dropCard: card inWaste: (SolitaireWaste*)container];
    
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
    if([container class] == [SolitaireTableau class])
        [self onCard: card removedFromTableau: (SolitaireTableau*)container];
    else if([container class] == [SolitaireFoundation class])
        [self onCard: card removedFromFoundation: (SolitaireFoundation*)container];
    else if([container class] == [SolitaireCell class])
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
    [view_.timer stopTimer];
    
    NSMutableArray* cards = [[view_ cards] mutableCopy];
    [cards sortUsingSelector: @selector(compareFaceValue:)];
    
    NSInteger cardCount = 0;
    for(SolitaireCard* card in [cards reverseObjectEnumerator]) {        
        [self performSelector: @selector(victoryAnimationForCard:) withObject: card afterDelay: cardCount++ * .1];
    }
    [view_ performSelector: @selector(showWinSheet) withObject: nil afterDelay: cardCount * 0.1];
}

-(void) victoryAnimationForCard: (SolitaireCard*)card {
    CGFloat width = view_.layer.bounds.size.width;
    CGFloat height = view_.layer.bounds.size.height;
    
    card.nextCard = nil;
    card.draggable = NO;
    [card.container removeCard: card];
    card.container = nil;

    CGPoint location = CGPointMake(width * rand() / (float)RAND_MAX, height * rand() / (float)RAND_MAX);
    CATransform3D transform = CATransform3DMakeRotation(3.14159 * rand() / (float)RAND_MAX, 0, 0, 1);
    [card animateToPosition: location andTransform: transform afterDelay: 0.2];
}

@end
