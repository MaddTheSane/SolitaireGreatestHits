//
//  SolitaireBakersGame2.swift
//  Solitaire
//
//  Created by C.W. Betts on 2/26/25.
//

class SolitaireBakersGame2 : SolitaireFreeCellGame2 {
    override var name: String { "Baker’s Game" }
    
    override var localizedName: String { NSLocalizedString("Baker's Game", comment: "Baker's Game") }
    
    override func dealNewGame() {
        var pos = 0
        while !stock!.isEmpty {
			stock!.dealCard(to: tableaus[pos], faceDown: false)
			pos += 1
			if pos > 7 {
				pos = 0
			}
        }
		
		for i in 0 ..< 8 {
			var pos = tableaus[i].count - 2
			while pos >= 0 {
				let card = tableaus[i].card(atPosition: pos)
				if (card.next?.faceValue.rawValue != card.faceValue.rawValue - 1) ||
				   (card.next?.suit != card.suit) ||
				   !(card.next?.draggable ?? false) {
					card.draggable = false
				}
				pos -= 1
			}
		}
    }
	
	override func canDrop(_ card: SolitaireCard, in tableau: SolitaireTableau) -> Bool {
		if card.countCardsStackedOnTop() > freeCellCount + freeTableauCount {
			return false
		} else if tableau.isEmpty && card.countCardsStackedOnTop() > freeCellCount + freeTableauCount - 1 {
			return false
		}
		
		if tableau.count == 0 {
			return true
		}
		
		let topCard = tableau.topCard!
		if topCard.isFlipped {
			return false
		}
		
		return (card.faceValue.rawValue == topCard.faceValue.rawValue - 1) && (card.suit == topCard.suit)
	}
	
	override func drop(_ card: SolitaireCard, in tableau: SolitaireTableau) {
		super.drop(card, in: tableau)
		
		var pos = tableau.count - 2
		while pos >= 0 {
			let cardToCheck = tableau.card(atPosition: pos)
			cardToCheck.draggable = (cardToCheck.next?.faceValue.rawValue == cardToCheck.faceValue.rawValue - 1) &&
			(cardToCheck.next?.suit == cardToCheck.suit) && (cardToCheck.next?.draggable ?? false)
			pos -= 1
		}
	}
	
	override func onCard(_ card: SolitaireCard, removedFrom tableau: SolitaireTableau) {
		var pos = tableau.count - 2
		while pos >= 0 {
			let cardToCheck = tableau.card(atPosition: pos)
			cardToCheck.draggable = (cardToCheck.next?.faceValue.rawValue == cardToCheck.faceValue.rawValue - 1) && (card.next?.suit == card.suit) && (card.next?.draggable ?? false)
			pos -= 1
		}
	}
}
