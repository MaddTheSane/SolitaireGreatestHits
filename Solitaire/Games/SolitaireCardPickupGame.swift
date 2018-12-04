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
    
    override var didLose: Bool {
        return false
    }
    
    override var didWin: Bool {
        return false
    }
    
    override func layoutGameComponents() {
        
    }
    
    override var supportsAutoFinish: Bool {
        return true
    }
    
    override func autoFinish() {
        
    }
    
    override func reset() {
        
    }
    
    override func generateSavedGameImage() -> SolitaireSavedGameImage {
        let saveGame = super.generateSavedGameImage()
        
        return saveGame
    }
    
    override func load(_ gameImage: SolitaireSavedGameImage) {
        super.load(gameImage)
        
        
    }
    
    override func canDrop(_ card: SolitaireCard, in foundation: SolitaireFoundation) -> Bool {
        return true
    }
    
    override func onGameWon() {
        controller?.timer?.stop()
        view?.showWinSheet()
    }
    
    /// Override so that the cards aren't thrown everywhere, defeating
    /// the purpose of picking them up.
    @objc(victoryAnimationForCard:)
    private func victoryAnimation(for card: SolitaireCard) {
        
    }
}
