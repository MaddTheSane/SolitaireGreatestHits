//
//  SolitaireCardPickupGame.swift
//  Solitaire
//
//  Created by C.W. Betts on 10/6/18.
//

import Cocoa

class SolitaireCardPickupGame: SolitaireGame {
    override init(controller gameController: SolitaireController) {
        
        super.init(controller: gameController)
    }
    
    override var name: String {
        return "52-card pickup"
    }
    
    override func initializeGame() {
        
    }
    
    override func layoutGameComponents() {
        
    }
}
