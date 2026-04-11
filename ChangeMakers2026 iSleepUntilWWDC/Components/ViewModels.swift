import SwiftUI
import UIKit

@Observable
class HomeViewModel {
    var todayQuests = [
        DailyQuest(title: "Aprender Hiragana", description: "Traza 5 caracteres nuevos.", type: .learning, isCompleted: true),
        DailyQuest(title: "La Taberna", description: "Práctica de saludos sociales.", type: .roleplay, isCompleted: false),
        DailyQuest(title: "La Forja", description: "Revisa tu progreso de campaña.", type: .forge, isCompleted: false)
    ]
    
    func toggleQuest(id: UUID) {
        if let index = todayQuests.firstIndex(where: { $0.id == id }) {
            todayQuests[index].isCompleted.toggle()
        }
    }
    
    func isPrimary(index: Int) -> Bool {
        !todayQuests[index].isCompleted && todayQuests.prefix(index).allSatisfy { $0.isCompleted }
    }
}

@Observable
class DiceViewModel {
    var displayValue = 20
    var isRolling = false
    var shakeDirection: Double = 0
    var diceScale: CGFloat = 1.0
    var rollHistory: [Int] = []
    
    func rollDice() {
        guard !isRolling else { return }
        isRolling = true
        
        let finalValue = Int.random(in: 1...20)
        shakeDirection = -15
        
        withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: true)) {
            shakeDirection = 15
        }
        
        var shuffleCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            shuffleCount += 1
            self.displayValue = Int.random(in: 1...20)
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            if shuffleCount >= 9 {
                timer.invalidate()
                self.displayValue = finalValue
                self.rollHistory.insert(finalValue, at: 0)
                if self.rollHistory.count > 10 {
                    self.rollHistory.removeLast()
                }
                
                self.isRolling = false
                
                self.shakeDirection = 0
                self.diceScale = 1.3
                withAnimation(.spring(response: 0.3, dampingFraction: 0)) {
                    self.shakeDirection = 0
                    self.diceScale = 1.2
                }
                
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        self.diceScale = 1.0
                    }
                }
            }
        }
    }
}

@Observable
class DictionaryViewModel {
    private let speechService = SpeechService()
    
    let kanaAlphabet: [Kana] = [
        // Vocales
        Kana(character: "あ", romaji: "a", group: "Vocales"),
        Kana(character: "い", romaji: "i", group: "Vocales"),
        Kana(character: "う", romaji: "u", group: "Vocales"),
        Kana(character: "え", romaji: "e", group: "Vocales"),
        Kana(character: "お", romaji: "o", group: "Vocales"),
        
        // Fila K
        Kana(character: "か", romaji: "ka", group: "Fila K"),
        Kana(character: "き", romaji: "ki", group: "Fila K"),
        Kana(character: "く", romaji: "ku", group: "Fila K"),
        Kana(character: "け", romaji: "ke", group: "Fila K"),
        Kana(character: "こ", romaji: "ko", group: "Fila K"),
        
        // Fila S
        Kana(character: "さ", romaji: "sa", group: "Fila S"),
        Kana(character: "し", romaji: "shi", group: "Fila S"),
        Kana(character: "す", romaji: "su", group: "Fila S"),
        Kana(character: "せ", romaji: "se", group: "Fila S"),
        Kana(character: "そ", romaji: "so", group: "Fila S"),
        
        // Fila T
        Kana(character: "た", romaji: "ta", group: "Fila T"),
        Kana(character: "ち", romaji: "chi", group: "Fila T"),
        Kana(character: "つ", romaji: "tsu", group: "Fila T"),
        Kana(character: "て", romaji: "te", group: "Fila T"),
        Kana(character: "と", romaji: "to", group: "Fila T"),
        
        // Fila N
        Kana(character: "な", romaji: "na", group: "Fila N"),
        Kana(character: "に", romaji: "ni", group: "Fila N"),
        Kana(character: "ぬ", romaji: "nu", group: "Fila N"),
        Kana(character: "ね", romaji: "ne", group: "Fila N"),
        Kana(character: "の", romaji: "no", group: "Fila N"),
        
        // Fila H
        Kana(character: "は", romaji: "ha", group: "Fila H"),
        Kana(character: "ひ", romaji: "hi", group: "Fila H"),
        Kana(character: "ふ", romaji: "fu", group: "Fila H"),
        Kana(character: "へ", romaji: "he", group: "Fila H"),
        Kana(character: "ほ", romaji: "ho", group: "Fila H"),
        
        // Fila M
        Kana(character: "ま", romaji: "ma", group: "Fila M"),
        Kana(character: "み", romaji: "mi", group: "Fila M"),
        Kana(character: "む", romaji: "mu", group: "Fila M"),
        Kana(character: "め", romaji: "me", group: "Fila M"),
        Kana(character: "も", romaji: "mo", group: "Fila M"),
        
        // Fila Y (Nota los espacios vacíos para mantener la cuadrícula)
        Kana(character: "や", romaji: "ya", group: "Fila Y"),
        Kana(character: "", romaji: "", group: "Fila Y"),
        Kana(character: "ゆ", romaji: "yu", group: "Fila Y"),
        Kana(character: "", romaji: "", group: "Fila Y"),
        Kana(character: "よ", romaji: "yo", group: "Fila Y"),
        
        // Fila R
        Kana(character: "ら", romaji: "ra", group: "Fila R"),
        Kana(character: "り", romaji: "ri", group: "Fila R"),
        Kana(character: "る", romaji: "ru", group: "Fila R"),
        Kana(character: "れ", romaji: "re", group: "Fila R"),
        Kana(character: "ろ", romaji: "ro", group: "Fila R"),
        
        // Fila W y N final
        Kana(character: "わ", romaji: "wa", group: "Fila W"),
        Kana(character: "", romaji: "", group: "Fila W"),
        Kana(character: "", romaji: "", group: "Fila W"),
        Kana(character: "", romaji: "", group: "Fila W"),
        Kana(character: "を", romaji: "wo", group: "Fila W"),
        
        // Singular N (Suele ponerse al final)
        Kana(character: "ん", romaji: "n", group: "Singular"),
        Kana(character: "", romaji: "", group: "Singular"),
        Kana(character: "", romaji: "", group: "Singular"),
        Kana(character: "", romaji: "", group: "Singular"),
        Kana(character: "", romaji: "", group: "Singular")
    ]
    
    func playSound(for kana: Kana) {
        guard !kana.isEmpty else { return }
        speechService.speak(text: kana.character)
    }
}
