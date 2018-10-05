//
//  SolitaireSavedGameImage.h
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

#import <Cocoa/Cocoa.h>

@class SolitaireCardContainer;

@interface SolitaireSavedGameImage : NSObject <NSCoding> {
@private
    NSString* gameName_;
    NSInteger gameSeed_;
    NSInteger gameScore_;
    NSInteger gameTime_;
    NSMutableDictionary* gameData_;
}

-(id) initWithGameName: (NSString*)name;
-(id) initWithCoder: (NSCoder*) decoder;
-(void) encodeWithCoder: (NSCoder*) encoder;

-(NSString*) gameName;

-(void) archiveGameScore: (NSInteger)value;
-(NSInteger) unarchiveGameScore;

-(void) archiveGameTime: (NSInteger)time;
-(NSInteger) unarchiveGameTime;

-(void) archiveGameSeed: (NSInteger)seed;
-(NSInteger) unarchiveGameSeed;

-(void) archiveGameObject: (id)obj forKey: (NSString*)key;
-(id) unarchiveGameObjectForKey: (NSString*)key;

@end
