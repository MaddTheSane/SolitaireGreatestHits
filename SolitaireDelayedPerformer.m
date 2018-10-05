//
//  SolitaireDelayedPerformer.m
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

#import "SolitaireDelayedPerformer.h"

@implementation SolitaireDelayedPerformer

- (id) initWithTarget: (id)target {
    if((self = [super init]) != nil) {
        target_ = target;
    }
    return self;
}

- (void) dealloc {
    [target_ release];
    target_ = nil;
    [super dealloc];
}

-(void)forwardInvocation: (NSInvocation*)invocation {
    invocation_ = invocation;
}

-(BOOL) respondsToSelector: (SEL)aSelector {
    if(![super respondsToSelector: aSelector])
        return [target_ respondsToSelector: aSelector];
    return NO;
}

-(NSMethodSignature*) methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature* result = [super methodSignatureForSelector: aSelector];
    if(!result) result = [target_ methodSignatureForSelector: aSelector];
    return result;
}


-(void)performDelayed {
    [invocation_ invokeWithTarget: target_];
    invocation_ = nil;
}

@end


@implementation NSObject (NSObject_DelayedInvocation)

-(id) performAfterDelay:(NSTimeInterval)delay {
    SolitaireDelayedPerformer* delayedPerformer = [[SolitaireDelayedPerformer alloc] initWithTarget: self];
    [delayedPerformer performSelector: @selector(performDelayed) withObject: nil afterDelay: delay];
    return delayedPerformer;
}

@end
