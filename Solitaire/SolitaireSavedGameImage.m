//
//  SolitaireSavedGameImage.m
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

#import "SolitaireSavedGameImage.h"
#import "SolitaireFoundation.h"
#import "SolitaireStock.h"

@implementation SolitaireSavedGameImage

-(id) initWithGameName: (NSString*)name {
    if (self = [super init]) {
        gameName_ = [name copy];
        gameData_ = [[NSMutableDictionary alloc] initWithCapacity: 32];
        gameScore_ = 0;
        gameTime_ = 0;
    }
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

-(id) initWithCoder: (NSCoder*) decoder {
    if (self = [super init]) {
        gameName_ = [decoder decodeObjectOfClass:[NSString class] forKey:@"gameName_"];
        gameData_ = [decoder decodeObjectForKey: @"gameData_"];
        gameScore_ = [decoder decodeIntegerForKey: @"gameScore_"];
        gameTime_ = [decoder decodeIntegerForKey: @"gameTime_"];
        gameSeed_ = [decoder decodeIntegerForKey: @"gameSeed_"];
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) encoder {
    [encoder encodeObject: gameName_ forKey: @"gameName_"];
    [encoder encodeObject: gameData_ forKey: @"gameData_"];
    [encoder encodeInteger: gameScore_ forKey: @"gameScore_"];
    [encoder encodeInteger: gameTime_ forKey: @"gameTime_"];
    [encoder encodeInteger: gameSeed_ forKey: @"gameSeed_"];
}

@synthesize gameName=gameName_;

-(void) archiveGameScore: (NSInteger)value {
    gameScore_ = value;
}

-(NSInteger) unarchiveGameScore {
    return gameScore_;
}

-(void) archiveGameTime: (NSInteger)time {
    gameTime_ = time;
}

-(NSInteger) unarchiveGameTime {
    return gameTime_;
}

-(void) archiveGameSeed: (NSInteger)seed {
    gameSeed_ = seed;
}

-(NSInteger) unarchiveGameSeed {
    return gameSeed_;
}

-(void) archiveGameObject: (id)obj forKey: (NSString*)key {
    [gameData_ setObject: obj forKey: key];
}

-(id) unarchiveGameObjectForKey: (NSString*)key {
    return [gameData_ objectForKey: key];
}

- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString*)key
{
    [gameData_ setObject: obj forKey: key];
}

- (nullable id)objectForKeyedSubscript:(NSString*)key
{
    return [gameData_ objectForKey: key];
}

@end
