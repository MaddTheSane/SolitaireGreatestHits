//
//  SolitaireCardPickupGame.swift
//  Solitaire
//
//  Created by C.W. Betts on 10/6/18.
//

import Cocoa

class SolitaireCardPickupGame: SolitaireGame {
    private var stock: SolitaireStock?
    private var foundation: SolitaireFoundation?
    private var tableus = [SolitaireTableau]()
    
    override init(controller gameController: SolitaireController) {
        super.init(controller: gameController)
        reset()
    }
    
    override var name: String {
        return "52-card pickup"
    }
    
#if false
    override var localizedName: String {
        return NSLocalizedString("52-card pickup", value: "52-card Pick-Up", comment: "52-card pickup")
    }
#endif
    
    override func initializeGame() {
        stock = SolitaireStock()
        // Called explicitly since we don't actually add the stock to the view,
        // but we still want its cards added to the view.
        stock?.onAdded(to: view!)
        
        // Init Foundations
        foundation = SolitaireFoundation()
        view?.addSprite(foundation!)
        
        // no cells
        
        // Init Tableau
        tableus.reserveCapacity(52)
        for _ in 0 ..< 52 {
            tableus.append(SolitaireTableau())
        }
    }
    
    override var didLose: Bool {
        return false
    }
    
    override var didWin: Bool {
        if let aCount = foundation?.cards.count {
            return aCount == 52
        }
        return false
    }
    
    override func layoutGameComponents() {
        var viewWidth = view!.frame.size.width;
        if viewWidth < 9.0 * CGFloat(kCardWidth) {
            viewWidth = 9.0 * CGFloat(kCardWidth)
        }
        
        let viewHeight = view!.frame.size.height;
        
        // Layout Foundations
        let foundationX = viewWidth - CGFloat(kCardWidth) - viewWidth / 25.0;
        let foundationY = (viewHeight - CGFloat(kCardHeight)) - viewHeight / 25.0;
        foundation?.position = CGPoint(x: foundationX, y: foundationY)
        
        for tableu in tableus {
            let yPos = Int(randSwiftWrap()) % Int(viewHeight - CGFloat(kCardHeight))
            let xPos = Int(randSwiftWrap()) % Int(viewWidth - CGFloat(kCardWidth))
            tableu.position = CGPoint(x: xPos, y: yPos)
        }
    }
    
    override var supportsAutoFinish: Bool {
        return true
    }
    
    override func autoFinish() {
        for tableu in tableus {
            guard let card = tableu.topCard else {
                continue
            }
            drop(card, in: foundation)
            perform(#selector(SolitaireCardPickupGame.autoFinish), with: nil, afterDelay: 0.2)
            return
        }
    }
    
    override func reset() {
        
    }
    
    override func generateSavedGameImage() -> SolitaireSavedGameImage {
        let saveGame = super.generateSavedGameImage()
        saveGame["stock_"] = stock
        saveGame["foundation_"] = foundation
        
        for (i, tableu) in tableus.enumerated() {
            saveGame["tableu_\(i)"] = tableu
        }
        return saveGame
    }
    
    override func load(_ gameImage: SolitaireSavedGameImage) {
        super.load(gameImage)
        stock = (gameImage["stock_"] as! SolitaireStock)
        self.view?.addSprite(stock!)
        
        foundation = (gameImage["foundation_"] as! SolitaireFoundation)
        view?.addSprite(foundation!)
        
        tableus.removeAll(keepingCapacity: true)
        
        for i in 0 ..< 52 {
            let tableu = gameImage["tableu_\(i)"] as! SolitaireTableau
            tableus.append(tableu)
            view?.addSprite(tableu)
        }
    }
    
    override func canDrop(_ card: SolitaireCard, in foundation: SolitaireFoundation) -> Bool {
        return true
    }
    
    override func dealNewGame() {
        for i in 0 ..< 52 {
            stock?.dealCard(to: tableus[i], faceDown: false)
        }
    }
    
    override func findFoundation(for card: SolitaireCard?) -> SolitaireFoundation? {
        if card == nil {
            return nil
        }
        return foundation
    }
    
    /// Override so that the cards aren't thrown everywhere, defeating
    /// the purpose of picking them up.
    override func onGameWon() {
        controller?.timer?.stop()
        view?.showWinSheet()
    }
}
