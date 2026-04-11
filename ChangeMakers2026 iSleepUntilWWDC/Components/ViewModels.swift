import SwiftUI
import UIKit
import CoreFoundation

@Observable
class LearningProgressStore {
    static let shared = LearningProgressStore()

    private let learnedKanaKey = "learned_hiragana_characters"
    private let learnedEntryKey = "learned_phrase_entries"

    var learnedKana: Set<String>
    var learnedEntryIDs: Set<String>

    private init() {
        let defaults = UserDefaults.standard
        learnedKana = Set(defaults.stringArray(forKey: learnedKanaKey) ?? [])
        learnedEntryIDs = Set(defaults.stringArray(forKey: learnedEntryKey) ?? [])
    }

    func markKanaLearned(_ character: String) {
        guard !character.isEmpty else { return }
        learnedKana.insert(character)
        UserDefaults.standard.set(Array(learnedKana).sorted(), forKey: learnedKanaKey)
    }

    func markEntryLearned(_ entryID: String) {
        learnedEntryIDs.insert(entryID)
        UserDefaults.standard.set(Array(learnedEntryIDs).sorted(), forKey: learnedEntryKey)
    }

    func isKanaLearned(_ character: String) -> Bool {
        learnedKana.contains(character)
    }

    func isEntryLearned(_ entryID: String) -> Bool {
        learnedEntryIDs.contains(entryID)
    }
}

@Observable
class HomeViewModel {
    private let progress = LearningProgressStore.shared
    private let adventureMessageCountKey = "adventure_user_message_count"

    var todayQuests: [DailyQuest] = []

    init() {
        refreshQuestProgress()
    }

    func refreshQuestProgress() {
        let adventureMessageCount = UserDefaults.standard.integer(forKey: adventureMessageCountKey)
        let hasLearningProgress = !progress.learnedKana.isEmpty || !progress.learnedEntryIDs.isEmpty

        todayQuests = [
            DailyQuest(
                title: "Learn Hiragana",
                description: "Learn hiragana through characters or words and phrases.",
                type: .learning,
                isCompleted: hasLearningProgress
            ),
            DailyQuest(
                title: "Take an Adventure",
                description: "Send at least one action message in Adventure.",
                type: .roleplay,
                isCompleted: adventureMessageCount >= 1
            ),
            DailyQuest(
                title: "Prepare the Reaction and Rest",
                description: "Send at least two Adventure messages: the action and the reaction plan.",
                type: .forge,
                isCompleted: adventureMessageCount >= 2
            )
        ]
    }
    
    func isPrimary(index: Int) -> Bool {
        !todayQuests[index].isCompleted && todayQuests.prefix(index).allSatisfy { $0.isCompleted }
    }
}

@Observable
class DiceViewModel {
    static let shared = DiceViewModel()

    let availableDiceSides = [6, 8, 4, 10, 12, 18, 20]
    var selectedSides = 6
    var displayValue = 6
    var isRolling = false
    var shakeDirection: Double = 0
    var diceScale: CGFloat = 1.0
    var rollHistory: [Int] = []

    private init() {}
    
    func selectDice(sides: Int) {
        guard availableDiceSides.contains(sides) else { return }
        selectedSides = sides
        displayValue = min(displayValue, sides)
    }

    func rollDice() {
        guard !isRolling else { return }
        isRolling = true
        
        let finalValue = Int.random(in: 1...selectedSides)
        shakeDirection = -15
        
        withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: true)) {
            shakeDirection = 15
        }
        
        var shuffleCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            shuffleCount += 1
            self.displayValue = Int.random(in: 1...self.selectedSides)
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            if shuffleCount >= 9 {
                timer.invalidate()
                self.commitRoll(finalValue)
                
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

    @discardableResult
    func rollInstant() -> Int {
        let result = Int.random(in: 1...selectedSides)
        commitRoll(result)
        return result
    }

    private func commitRoll(_ value: Int) {
        displayValue = value
        rollHistory.insert(value, at: 0)
        if rollHistory.count > 10 {
            rollHistory.removeLast()
        }
    }
}

@Observable
class DictionaryViewModel {
    private let speechService = SpeechService()
    private let progress = LearningProgressStore.shared

    static let kanaAlphabetLibrary: [Kana] = [
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

    let kanaAlphabet: [Kana] = DictionaryViewModel.kanaAlphabetLibrary

    var learnedKana: [Kana] {
        kanaAlphabet.filter { progress.isKanaLearned($0.character) }
    }
    
    func playSound(for kana: Kana) {
        guard !kana.isEmpty else { return }
        progress.markKanaLearned(kana.character)
        speechService.speak(text: kana.character)
    }
}

@Observable
class LearningViewModel {
    private let speechService = SpeechService()
    private let progress = LearningProgressStore.shared

    var selectedCategory: LearningEntry.Category? = nil
    var searchText = ""
    var flashcardIndex = 0
    var showFlashcardAnswer = false

    var quizIndex = 0
    var quizOptions: [String] = []
    var quizFeedback: String?

    static let hiraganaEntries: [Kana] = DictionaryViewModel.kanaAlphabetLibrary.filter { !$0.isEmpty }

    static let learningEntries: [LearningEntry] = [
        LearningEntry(id: "hello", kana: "こんにちは", romaji: "konnichiwa", translation: "hello", usage: "A calm greeting for meeting someone during the day.", category: .social, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "thanks", kana: "ありがとう", romaji: "arigatou", translation: "thank you", usage: "Use after help, kindness, or a clear social effort from someone.", category: .social, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "sorry", kana: "ごめんね", romaji: "gomen ne", translation: "sorry", usage: "A gentle apology for a small mistake with someone you know.", category: .social, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "okay", kana: "だいじょうぶ", romaji: "daijoubu", translation: "it's okay / are you okay?", usage: "Useful to reassure someone or check on their comfort.", category: .social, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "please", kana: "おねがいします", romaji: "onegai shimasu", translation: "please", usage: "A polite phrase for asking for help or a service.", category: .social, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "yoroshiku", kana: "よろしくおねがいします", romaji: "yoroshiku onegai shimasu", translation: "please treat me well", usage: "Common in introductions and cooperative group settings.", category: .context, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "quiet", kana: "しずかにします", romaji: "shizuka ni shimasu", translation: "I will be quiet", usage: "Useful when setting expectations in a shared space.", category: .context, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "go_together", kana: "いっしょにいきますか", romaji: "issho ni ikimasu ka", translation: "shall we go together?", usage: "A gentle invitation for a shared activity.", category: .context, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "short_break", kana: "すこしやすみます", romaji: "sukoshi yasumimasu", translation: "I will take a short break", usage: "Helpful for communicating sensory or social regulation needs.", category: .context, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "later", kana: "あとでいいですか", romaji: "ato de ii desu ka", translation: "can it be later?", usage: "A respectful way to delay an interaction or task.", category: .context, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "help_me", kana: "てつだってください", romaji: "tetsudatte kudasai", translation: "please help me", usage: "Useful in both social support and quest situations.", category: .context, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "hard_now", kana: "いまはむずかしいです", romaji: "ima wa muzukashii desu", translation: "that is difficult right now", usage: "A clear boundary-setting phrase for overwhelming moments.", category: .social, groupLabel: nil, kindLabel: nil),
        LearningEntry(id: "fight", kana: "たたかう", romaji: "tatakau", translation: "to fight", usage: "A standard DnD-style action verb for battle scenes.", category: .dnd, groupLabel: "General", kindLabel: "Action"),
        LearningEntry(id: "protect", kana: "まもる", romaji: "mamoru", translation: "to protect", usage: "Useful for defensive actions and supporting teammates.", category: .dnd, groupLabel: "General", kindLabel: "Action"),
        LearningEntry(id: "run", kana: "にげる", romaji: "nigeru", translation: "to run away", usage: "A clear action for retreating from danger.", category: .dnd, groupLabel: "General", kindLabel: "Action"),
        LearningEntry(id: "magic", kana: "まほう", romaji: "mahou", translation: "magic", usage: "Core fantasy vocabulary for spells and enchanted items.", category: .dnd, groupLabel: "General", kindLabel: "Spell"),
        LearningEntry(id: "healing", kana: "かいふく", romaji: "kaifuku", translation: "healing / recover", usage: "Useful when describing support or recovery actions.", category: .dnd, groupLabel: "General", kindLabel: "Spell"),
        LearningEntry(id: "attack", kana: "こうげきします", romaji: "kougeki shimasu", translation: "I attack", usage: "A direct combat phrase for turn-based actions.", category: .dnd, groupLabel: "General", kindLabel: "Attack"),
        LearningEntry(id: "elf_bow", kana: "ゆみをうつ", romaji: "yumi o utsu", translation: "shoot a bow", usage: "A common ranged attack phrase for elf-style agile builds.", category: .dnd, groupLabel: "Elf", kindLabel: "Attack"),
        LearningEntry(id: "elf_perception", kana: "けはいをかんじる", romaji: "kehai o kanjiru", translation: "sense a presence", usage: "Fits elf perception and alertness in exploration scenes.", category: .dnd, groupLabel: "Elf", kindLabel: "Trait"),
        LearningEntry(id: "elf_cantrip", kana: "まほうのひをつくる", romaji: "mahou no hi o tsukuru", translation: "create magical fire", usage: "A simple race-flavored spell phrase for high elf magic.", category: .dnd, groupLabel: "Elf", kindLabel: "Spell"),
        LearningEntry(id: "dwarf_axe", kana: "おのできる", romaji: "ono de kiru", translation: "strike with an axe", usage: "A strong melee attack phrase suited to dwarf weapon style.", category: .dnd, groupLabel: "Dwarf", kindLabel: "Attack"),
        LearningEntry(id: "dwarf_resist", kana: "どくにたえる", romaji: "doku ni taeru", translation: "endure poison", usage: "Useful for dwarf resilience and toughness moments.", category: .dnd, groupLabel: "Dwarf", kindLabel: "Trait"),
        LearningEntry(id: "dwarf_hammer", kana: "かなづちでたたく", romaji: "kanazuchi de tataku", translation: "smash with a hammer", usage: "Another dwarf combat phrase for close-range impact.", category: .dnd, groupLabel: "Dwarf", kindLabel: "Attack"),
        LearningEntry(id: "halfling_hide", kana: "かくれる", romaji: "kakureru", translation: "to hide", usage: "Good for halfling stealth and slipping behind allies.", category: .dnd, groupLabel: "Halfling", kindLabel: "Trait"),
        LearningEntry(id: "halfling_luck", kana: "うんがいい", romaji: "un ga ii", translation: "to be lucky", usage: "Matches halfling luck and second-chance moments.", category: .dnd, groupLabel: "Halfling", kindLabel: "Trait"),
        LearningEntry(id: "halfling_dagger", kana: "たんけんでさす", romaji: "tanken de sasu", translation: "stab with a dagger", usage: "A light weapon phrase suited to nimble halfling attacks.", category: .dnd, groupLabel: "Halfling", kindLabel: "Attack"),
        LearningEntry(id: "dragonborn_breath", kana: "ほのおをはく", romaji: "honoo o haku", translation: "breathe fire", usage: "Classic dragonborn breath weapon language.", category: .dnd, groupLabel: "Dragonborn", kindLabel: "Spell"),
        LearningEntry(id: "dragonborn_claw", kana: "つめでひっかく", romaji: "tsume de hikkaku", translation: "slash with claws", usage: "A race-flavored physical attack for draconic combat.", category: .dnd, groupLabel: "Dragonborn", kindLabel: "Attack"),
        LearningEntry(id: "dragonborn_resist", kana: "ほのおにたえる", romaji: "honoo ni taeru", translation: "resist fire", usage: "Useful for race-specific elemental resilience.", category: .dnd, groupLabel: "Dragonborn", kindLabel: "Trait"),
        LearningEntry(id: "tiefling_flame", kana: "ほのおをよぶ", romaji: "honoo o yobu", translation: "call flames", usage: "A tiefling-style infernal magic phrase.", category: .dnd, groupLabel: "Tiefling", kindLabel: "Spell"),
        LearningEntry(id: "tiefling_dark", kana: "やみがみえる", romaji: "yami ga mieru", translation: "see in darkness", usage: "A trait phrase for darkvision in low-light scenes.", category: .dnd, groupLabel: "Tiefling", kindLabel: "Trait"),
        LearningEntry(id: "tiefling_hellish", kana: "ほのおでやきかえす", romaji: "honoo de yakikaesu", translation: "burn back with fire", usage: "A reactive infernal-flavored attack phrase.", category: .dnd, groupLabel: "Tiefling", kindLabel: "Attack"),
        LearningEntry(id: "human_help", kana: "なかまをまとめる", romaji: "nakama o matomeru", translation: "organize the party", usage: "A simple human-style support action for teamwork.", category: .dnd, groupLabel: "Human", kindLabel: "Trait"),
        LearningEntry(id: "human_sword", kana: "けんでこうげき", romaji: "ken de kougeki", translation: "attack with a sword", usage: "A basic adaptable human combat phrase.", category: .dnd, groupLabel: "Human", kindLabel: "Attack"),
        LearningEntry(id: "human_training", kana: "れんしゅうをつむ", romaji: "renshuu o tsumu", translation: "train and improve", usage: "Fits the flexible growth theme of human characters.", category: .dnd, groupLabel: "Human", kindLabel: "Trait")
    ]

    let entries = LearningViewModel.learningEntries

    var hiraganaEntries: [Kana] {
        LearningViewModel.hiraganaEntries
    }

    var filteredEntries: [LearningEntry] {
        entries.filter { entry in
            let matchesCategory = selectedCategory == nil || entry.category == selectedCategory
            let matchesSearch = searchText.isEmpty || [
                entry.kana,
                entry.romaji,
                entry.translation,
                entry.usage
            ].joined(separator: " ").localizedCaseInsensitiveContains(searchText)

            return matchesCategory && matchesSearch
        }
    }

    var currentFlashcard: LearningEntry? {
        guard !filteredEntries.isEmpty else { return nil }
        return filteredEntries[min(flashcardIndex, filteredEntries.count - 1)]
    }

    var currentQuizEntry: LearningEntry? {
        guard !filteredEntries.isEmpty else { return nil }
        return filteredEntries[min(quizIndex, filteredEntries.count - 1)]
    }

    var learnedEntries: [LearningEntry] {
        entries.filter { progress.isEntryLearned($0.id) }
    }

    func isKanaLearned(_ kana: Kana) -> Bool {
        progress.isKanaLearned(kana.character)
    }

    func progressLabel(for kana: Kana) -> String {
        isKanaLearned(kana) ? "Learned" : "Tap to learn"
    }

    func speak(entry: LearningEntry) {
        progress.markEntryLearned(entry.id)
        entry.kana.forEach { progress.markKanaLearned(String($0)) }
        speechService.speak(text: entry.kana)
    }

    func speak(kana: Kana) {
        progress.markKanaLearned(kana.character)
        speechService.speak(text: kana.character)
    }

    func nextFlashcard() {
        guard !filteredEntries.isEmpty else { return }
        flashcardIndex = (flashcardIndex + 1) % filteredEntries.count
        showFlashcardAnswer = false
        progressCurrentFlashcard()
    }

    func previousFlashcard() {
        guard !filteredEntries.isEmpty else { return }
        flashcardIndex = (flashcardIndex - 1 + filteredEntries.count) % filteredEntries.count
        showFlashcardAnswer = false
        progressCurrentFlashcard()
    }

    func resetFlashcardIndexIfNeeded() {
        if flashcardIndex >= filteredEntries.count {
            flashcardIndex = 0
        }
        if quizIndex >= filteredEntries.count {
            quizIndex = 0
        }
        progressCurrentFlashcard()
        prepareQuiz()
    }

    func markEntryLearned(_ entry: LearningEntry) {
        progress.markEntryLearned(entry.id)
        entry.kana.forEach { progress.markKanaLearned(String($0)) }
    }

    func markKanaLearned(_ kana: Kana) {
        progress.markKanaLearned(kana.character)
    }

    func prepareQuiz() {
        guard let currentQuizEntry else {
            quizOptions = []
            quizFeedback = nil
            return
        }

        let distractors = filteredEntries
            .filter { $0.id != currentQuizEntry.id }
            .map(\.translation)
            .shuffled()
        quizOptions = Array(([currentQuizEntry.translation] + distractors.prefix(3)).shuffled())
        quizFeedback = nil
    }

    func submitQuizAnswer(_ answer: String) {
        guard let currentQuizEntry else { return }
        if answer == currentQuizEntry.translation {
            quizFeedback = "Correct"
            markEntryLearned(currentQuizEntry)
        } else {
            quizFeedback = "Try again"
        }
    }

    func nextQuiz() {
        guard !filteredEntries.isEmpty else { return }
        quizIndex = (quizIndex + 1) % filteredEntries.count
        prepareQuiz()
    }

    func isPracticeMatch(attempt: String, target: LearningEntry) -> Bool {
        normalizedKanaText(attempt) == normalizedKanaText(target.kana)
    }

    func practiceFeedback(for attempt: String, target: LearningEntry) -> (message: String, isSuccess: Bool) {
        let normalizedAttempt = normalizedKanaText(attempt)
        let normalizedTarget = normalizedKanaText(target.kana)

        guard !normalizedAttempt.isEmpty else {
            return ("Write or say the target word before checking.", false)
        }

        if normalizedAttempt == normalizedTarget {
            markEntryLearned(target)
            return ("Correct. This word is now registered as learned.", true)
        }

        if normalizedTarget.hasPrefix(normalizedAttempt) {
            return ("Close. You have the beginning right, but the word is incomplete.", false)
        }

        return ("Not yet. Compare your kana with the target and try again.", false)
    }

    private func progressCurrentFlashcard() {
        if let currentFlashcard {
            markEntryLearned(currentFlashcard)
        }
    }

    private func normalizedKanaText(_ text: String) -> String {
        let compactText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")

        let mutable = NSMutableString(string: compactText.lowercased())
        CFStringTransform(mutable, nil, kCFStringTransformLatinHiragana, false)
        return mutable as String
    }
}
