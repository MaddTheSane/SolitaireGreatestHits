//
//  SolitaireFreeCellGame2.swift
//  Solitaire
//
//  Created by C.W. Betts on 1/19/19.
//

import Cocoa

private var SolitaireFreeCellTableus: Int {
    return 8
}
private var SolitaireFreeCellFoundations: Int {
    return 4
}
private var SolitaireFreeCellCells: Int {
    return 4
}


class SolitaireFreeCellGame2: SolitaireGame {
    private var stock: SolitaireStock?
    private var tableus = [SolitaireTableau]()
    private var foundations = [SolitaireFoundation]()
    private var cells = [SolitaireCell]()
    
    override init(controller gameController: SolitaireController) {
        super.init(controller: gameController)
        reset()
    }
    
    override func initializeGame() {
        // Init Stock
        stock = SolitaireStock()
        stock?.onAdded(to: view!) // Called explicitly since we don't actually add the stock to the view,
        // but we still want its cards added to the view.
        
        // Init Foundations
        for _ in 0 ..< SolitaireFreeCellFoundations {
            let aFoundation = SolitaireFoundation()
            aFoundation.text = "A"
            view?.addSprite(aFoundation)
            foundations.append(aFoundation)
        }
        
        // Init Cells
        for _ in 0 ..< SolitaireFreeCellCells {
            let aCell = SolitaireCell()
            view?.addSprite(aCell)
            cells.append(aCell)
        }
        
        // Init Tableau
        for _ in 0 ..< SolitaireFreeCellTableus {
            let tableu = SolitaireTableau()
            view?.addSprite(tableu)
            tableus.append(tableu)
        }
    }
    
    override var name: String {
        return "Free Cell"
    }
    
    override func layoutGameComponents() {
        var viewWidth = view!.frame.width
        if viewWidth < CGFloat(9 * kCardWidth) {
            viewWidth = CGFloat(9 * kCardWidth)
        }
        let viewHeight = view!.frame.height

        // Layout Foundations
        let foundationX = viewWidth - CGFloat(kCardWidth) - viewWidth / 25.0;
        let foundationY = (viewHeight - CGFloat(kCardHeight)) - viewHeight / 25.0;

        for (i, found) in foundations.enumerated() {
            found.position = CGPoint(x: foundationX - CGFloat(i) * (5.0 / 4.0 * CGFloat(kCardWidth)), y: foundationY)
        }
        
        // Layout Cells
        let cellX = viewWidth / 25.0;
        let cellY = (viewHeight - CGFloat(kCardHeight)) - viewHeight / 25.0;

        for (i, cell) in cells.enumerated() {
            cell.position = CGPoint(x: cellX + CGFloat(i) * (5.0 / 4.0 * CGFloat(kCardWidth)), y: cellY)
        }
        
        // Layout Tableau
        let tableauX = viewWidth / 25.0;
        let tableauY = foundationY - (5.0 / 4.0 * CGFloat(kCardHeight));
        let tableauSpacing = (viewWidth - 8 * CGFloat(kCardWidth) - 2 * (viewWidth / 25.0)) / 7.0;

        for (i, tab) in tableus.enumerated() {
            tab.position = CGPoint(x: tableauX + CGFloat(i) * (CGFloat(kCardWidth) + tableauSpacing), y: tableauY)
        }
    }

    override var didWin: Bool {
        for found in foundations {
            if !found.isFilled {
                return false
            }
        }
        return true
    }
    
    override var didLose: Bool {
        for cell in cells {
            if cell.topCard == nil {
                return false
            }
        }
        for currentCell in cells {
            guard let card = currentCell.topCard else {
                continue
            }
            
            for currentFoundation in foundations {
                if canDrop(card, in: currentFoundation) {
                    return false
                }
            }
            
            for currentTableu in tableus {
                if canDrop(card, in: currentTableu) {
                    return false
                }
            }
        }
        
        for currentTableu in tableus {
            guard let card = currentTableu.topCard else {
                continue
            }
            
            for currentFoundation in foundations {
                if canDrop(card, in: currentFoundation) {
                    return false
                }
            }
            
            for otherTableu in tableus {
                if canDrop(card, in: otherTableu) {
                    return false
                }
            }
        }
        
        return true
    }

    override func reset() {
        stock = nil
        
        foundations.removeAll(keepingCapacity: true)
        cells.removeAll(keepingCapacity: true)
        tableus.removeAll(keepingCapacity: true)
    }
    
    override var cardsInPlay: Int {
        return 0
    }
    
    // Saving and loading game
    override func generateSavedGameImage() -> SolitaireSavedGameImage {
        let gameImage = super.generateSavedGameImage()
        
        // Archive Stock
        gameImage.archiveGameObject(stock, forKey: "stock_")
        
        for (i, found) in foundations.enumerated() {
            gameImage.archiveGameObject(found, forKey: "foundation_\(i)")
        }
        
        // Archive Tableau
        for (i, found) in tableus.enumerated() {
            gameImage.archiveGameObject(found, forKey: "tableau_\(i)")
        }
        
        // Archive Cells
        for (i, found) in cells.enumerated() {
            gameImage.archiveGameObject(found, forKey: "cell_\(i)")
        }
        
        return gameImage
    }
    
    override func load(_ gameImage: SolitaireSavedGameImage) {
        super.load(gameImage)
        
        // Unarchive Stock
        stock = gameImage.unarchiveGameObject(forKey: "stock_") as? SolitaireStock
        // Called explicitly since we don't actually add the stock to the view,
        // but we still want its cards added to the view.
        stock?.onAdded(to: view!)
        
        // Unarchive Foundations
        foundations.removeAll(keepingCapacity: true)
        for i in 0 ..< SolitaireFreeCellFoundations {
            if let foundation = gameImage.unarchiveGameObject(forKey: "foundation_\(i)") as? SolitaireFoundation {
                foundations.append(foundation)
                view?.addSprite(foundation)
            }
        }
        
        // Unarchive Tableau
        tableus.removeAll(keepingCapacity: true)
        for i in 0 ..< SolitaireFreeCellTableus {
            if let foundation = gameImage.unarchiveGameObject(forKey: "tableau_\(i)") as? SolitaireTableau {
                tableus.append(foundation)
                view?.addSprite(foundation)
            }
        }
        
        // Unarchive Cells
        cells.removeAll(keepingCapacity: true)
        for i in 0 ..< SolitaireFreeCellTableus {
            if let foundation = gameImage.unarchiveGameObject(forKey: "cell_\(i)") as? SolitaireCell {
                cells.append(foundation)
                view?.addSprite(foundation)
            }
        }

    }
    
    // Auto-finish
    override var supportsAutoFinish: Bool {
        return true
    }
    
    override func autoFinish() {
        // Tableau
        for tabl in tableus {
            guard let card = tabl.topCard else {
                continue
            }
            if let foundation = findFoundation(for: card) {
                drop(card, in: foundation as SolitaireCardContainer)
                self.perform(#selector(SolitaireGame.autoFinish), with: nil, afterDelay: 0.2)
                return
            }
        }
        
        // Cells
        for cell in cells {
            guard let card = cell.topCard else {
                continue
            }
            if let foundation = findFoundation(for: card) {
                drop(card, in: foundation as SolitaireCardContainer)
                self.perform(#selector(SolitaireGame.autoFinish), with: nil, afterDelay: 0.2)
                return
            }
        }
    }
    
    override func dealNewGame() {
        var pos = 0
        while !stock!.isEmpty {
            stock!.dealCard(to: tableus[pos], faceDown: false)
            pos += 1
            //if(pos > 7) pos = 0;
            if pos >= SolitaireFreeCellTableus {
                pos = 0
            }
        }
        
        for tabl in tableus {
            var pos = tabl.count - 2
            while pos >= 0 {
                let card = tabl.card(atPosition: pos)
                if card.next?.faceValue.rawValue != card.faceValue.rawValue - 1 || card.next?.suitColor == card.suitColor || !(card.next?.draggable ?? false) {
                    card.draggable = false
                }
                pos -= 1
            }
        }
    }
    
    private var freeCellCount: Int {
        var count = 0
        for cell in cells {
            if cell.isEmpty {
                count += 1
            }
        }
        
        return count
    }
    
    private var freeTableuCount: Int {
        var count = 0
        for tabl in tableus {
            if tabl.isEmpty {
                count += 1
            }
        }
        
        return count
    }
    
    override func canDrop(_ card: SolitaireCard, in tableau: SolitaireTableau) -> Bool {
        if card.countCardsStackedOnTop() > freeCellCount + freeTableuCount {
            return false
        } else if tableau.isEmpty, card.countCardsStackedOnTop() > freeCellCount + freeTableuCount - 1 {
            return false
        }
        
        if tableau.count == 0 {
            return true
        }
        
        let topCard = tableau.topCard
        if let aTop = topCard, aTop.isFlipped {
            return false
        }
        
        if card.faceValue.rawValue == (topCard?.faceValue.rawValue ?? 0) - 1,
            card.suitColor != topCard?.suitColor {
            return true
        }
        
        return false
    }
    
    override func canDrop(_ card: SolitaireCard, in foundation: SolitaireFoundation) -> Bool {
        if card.countCardsStackedOnTop() > 0 {
            return false
        }
        
        if foundation.count == 0 {
            if card.faceValue == .ace {
                return true
            } else {
                return false
            }
        }
        if let topCard = foundation.topCard,
            card.suit == topCard.suit,
            card.faceValue.rawValue == topCard.faceValue.rawValue + 1 {
            return true
        }
        return false
    }
    
    override func canDrop(_ card: SolitaireCard, in cell: SolitaireCell) -> Bool {
        if cell.isEmpty, card.next == nil {
            return true
        }
        return false
    }
    
    override func drop(_ card: SolitaireCard, in tableau: SolitaireTableau) {
        super.drop(card, in: tableau)
        var pos = tableau.count - 2
        while pos >= 0 {
            let card1 = tableau.card(atPosition: pos)
            if card1.next?.faceValue.rawValue == card1.faceValue.rawValue - 1,
                card1.next?.suitColor != card1.suitColor,
                card1.next?.draggable ?? false {
                card1.draggable = true
            } else {
                card1.draggable = false
            }
            
            pos -= 1
        }
    }
    
    override func onCard(_ card: SolitaireCard, removedFrom tableau: SolitaireTableau) {
        var pos = tableau.count - 2
        while pos >= 0 {
            let card1 = tableau.card(atPosition: pos)
            if card1.next?.faceValue.rawValue == card1.faceValue.rawValue - 1,
                card1.next?.suitColor != card1.suitColor,
                card1.next?.draggable ?? false {
                card1.draggable = true
            } else {
                card1.draggable = false
            }
            
            pos -= 1
        }
    }
    
    override func findFoundation(for card: SolitaireCard?) -> SolitaireFoundation? {
        guard let card = card else {
            return nil
        }
        
        if card.faceValue == .ace {
            let preferredFoundation = foundations[Int(card.suitColor.rawValue)]
            if card.container == preferredFoundation {
                return nil
            }
            if canDrop(card, in: preferredFoundation) {
                return preferredFoundation
            }
        }
        
        for found in foundations {
            if card.container == found {
                break
            } else if canDrop(card, in: found) {
                return found
            }
        }
        
        return nil
    }
}
