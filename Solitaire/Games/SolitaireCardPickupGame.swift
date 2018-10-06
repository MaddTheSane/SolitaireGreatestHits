//
//  SolitaireCardPickupGame.swift
//  Solitaire
//
//  Created by C.W. Betts on 10/6/18.
//

import Cocoa

class SolitaireCardPickupGame: SolitaireGame {
    private var stock: SolitaireStock?
    
    override init(controller gameController: SolitaireController) {
        super.init(controller: gameController)
        reset()
    }
    
    override var name: String {
        return "52-card pickup"
    }
    
    override func initializeGame() {
        stock = SolitaireStock()
    }
    
    override func layoutGameComponents() {
        
    }
    
    override var supportsAutoFinish: Bool {
        return true
    }
    
    override func autoFinish() {
        
    }
    
    /// Override so that the cards aren't thrown everywhere, defeating
    /// the purpose of picking them up.
    @objc(victoryAnimationForCard:)
    private func victoryAnimation(for card: SolitaireCard) {
        
    }
}
