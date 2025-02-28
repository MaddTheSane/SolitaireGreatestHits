//
//  SolitairePreferencesController.m
//  Solitaire
//
//  Created by Daniel Fontaine on 5/30/09.
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

#import "SolitairePreferencesController.h"
#import "GeneratedAssetSymbols.h"

@implementation SolitairePreferencesController

@synthesize preferencesPanel;
@synthesize colorWell;

-(void) awakeFromNib
{
    cardBackFiles_ = [[NSArray alloc] initWithObjects:
                      ACImageNameCardBack1,
                      ACImageNameCardBack2,
        nil];
    
    [_backgroundPopup removeAllItems];
    int index = 0;
    for (NSString *filename in cardBackFiles_)
    {
        [_backgroundPopup addItemWithTitle:@""];
        NSImage *image = [NSImage imageNamed:filename];
        [_backgroundPopup itemAtIndex:index].image = image;
        ++index;
    }
    
    NSRect frame = [_backgroundPopup frame];
    frame.origin.y -= 140 - frame.size.height;
    frame.size.height = 140;
    [_backgroundPopup setFrame:frame];

    [[_backgroundPopup cell] setImagePosition:NSImageOnly];
    [[_backgroundPopup cell] setArrowPosition:NSPopUpArrowAtBottom];
    [[_backgroundPopup cell] setBordered:NO];
}

-(void) data2Controls
{
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    NSData *colorAsData         = [defaults dataForKey:@"backgroundColor"];
    NSColor *color              = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorAsData error:nil];
    NSString *cardBack          = [defaults objectForKey:@"cardBack"];
    
    [colorWell setColor:color];
    NSInteger index = [cardBackFiles_ indexOfObject:cardBack];
    [_backgroundPopup selectItemAtIndex:index];
}

-(IBAction) onOkayClicked: (id)sender {
    [[preferencesPanel sheetParent] endSheet:preferencesPanel returnCode:NSModalResponseOK];
}

-(IBAction) onCancelClicked: (id)sender {
    [[preferencesPanel sheetParent] endSheet:preferencesPanel returnCode:NSModalResponseCancel];
}

-(IBAction) onDefaultClicked: (id)sender {
    [colorWell setColor:[NSColor colorNamed:ACColorNameDefaultFeltBackground]];
    [_backgroundPopup selectItemAtIndex:0];
}

-(NSColor*) selectedColor
{
    return [colorWell color];
}

-(NSString*) selectedCardBack
{
    return [cardBackFiles_ objectAtIndex:[_backgroundPopup indexOfSelectedItem]];
}

@end
