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

@implementation SolitaireSavedGameImage

-(id) initWithGameName: (NSString*)name {
    if((self = [super init]) != nil) {
        gameName_ = name;
        gameData_ = [[NSMutableDictionary alloc] initWithCapacity: 32];
        gameScore_ = 0;
        gameTime_ = 0;
    }
    return self;
}

-(id) initWithCoder: (NSCoder*) decoder {
    if((self = [super init]) != nil) {
        gameName_ = [decoder decodeObjectForKey: @"gameName_"];
        gameData_ = [decoder decodeObjectForKey: @"gameData_"];
        gameScore_ = [decoder decodeIntForKey: @"gameScore_"];
        gameTime_ = [decoder decodeIntForKey: @"gameTime_"];
        gameSeed_ = [decoder decodeIntForKey: @"gameSeed_"];
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) encoder {
    [encoder encodeObject: gameName_ forKey: @"gameName_"];
    [encoder encodeObject: gameData_ forKey: @"gameData_"];
    [encoder encodeInt: gameScore_ forKey: @"gameScore_"];
    [encoder encodeInt: gameTime_ forKey: @"gameTime_"];
    [encoder encodeInt: gameSeed_ forKey: @"gameSeed_"];
}

-(NSString*) gameName {
    return gameName_;
}

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

@end
