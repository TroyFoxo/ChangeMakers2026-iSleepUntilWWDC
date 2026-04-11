//
//  DrawingCanvasView.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Samuel Aarón Flores Montemayor on 10/04/26.
//

import SwiftUI
import UIKit

final class InsecureSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

enum KanaComposerInputMode: String, CaseIterable, Identifiable {
    case keyboard = "Keyboard"
    case canvas = "Canvas"
    case voice = "Voice"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .keyboard:
            return "keyboard"
        case .canvas:
            return "pencil.and.outline"
        case .voice:
            return "mic.fill"
        }
    }
}

enum LearningSection: String, CaseIterable, Identifiable {
    case hiragana = "Hiragana"
    case dictionary = "Dictionary"
    case flashcards = "Flashcards"
    case quiz = "Quiz"
    case practice = "Practice"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .hiragana:
            return "textformat.abc"
        case .dictionary:
            return "book.closed.fill"
        case .flashcards:
            return "rectangle.on.rectangle.fill"
        case .quiz:
            return "questionmark.circle.fill"
        case .practice:
            return "pencil.and.scribble"
        }
    }
}

struct LearningView: View {
    @State private var viewModel = LearningViewModel()
    @State private var selectedSection: LearningSection = .hiragana
    @State private var practiceWord = ""
    @State private var selectedPracticeEntryID: LearningEntry.ID?
    @State private var practiceFeedbackMessage: String?
    @State private var practiceFeedbackSuccess = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                header
                categoryFilter
                sectionPicker
                sectionContent
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                GlobalBackground()
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.resetFlashcardIndexIfNeeded()
            }
            .onChange(of: viewModel.selectedCategory) { _, _ in
                viewModel.resetFlashcardIndexIfNeeded()
            }
            .onAppear {
                syncPracticeEntry()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Learning Hall")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Learn hiragana words and phrases for social comfort, real situations, and DnD adventures.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))

            TextField("Search kana, romaji, or translation", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    viewModel.selectedCategory = nil
                    viewModel.resetFlashcardIndexIfNeeded()
                    syncPracticeEntry()
                } label: {
                    Text("All")
                        .modifier(LearningChipStyle(isSelected: viewModel.selectedCategory == nil))
                }
                .buttonStyle(.plain)

                ForEach(LearningEntry.Category.allCases) { category in
                    Button {
                        viewModel.selectedCategory = category
                        viewModel.resetFlashcardIndexIfNeeded()
                        syncPracticeEntry()
                    } label: {
                        Label(category.rawValue, systemImage: category.icon)
                            .modifier(LearningChipStyle(isSelected: viewModel.selectedCategory == category))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LearningSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: section.icon)
                                .font(.headline)

                            Text(section.rawValue)
                                .font(.caption.weight(.semibold))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 72)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(selectedSection == section ? Theme.primary.opacity(0.78) : Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(
                                    selectedSection == section ? Theme.primary : Color.white.opacity(0.08),
                                    lineWidth: 1.2
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch selectedSection {
        case .hiragana:
            hiraganaSection
        case .dictionary:
            dictionarySection
        case .flashcards:
            flashcardsSection
        case .quiz:
            quizSection
        case .practice:
            practiceSection
        }
    }

    private var hiraganaSection: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 12) {
                ForEach(DictionaryViewModel.kanaAlphabetLibrary) { kana in
                    if kana.isEmpty {
                        placeholderKanaCell
                    } else {
                        Button {
                            viewModel.markKanaLearned(kana)
                            viewModel.speak(kana: kana)
                        } label: {
                            VStack(spacing: 6) {
                                Text(kana.character)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text(kana.romaji)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.72))

                                Text(viewModel.progressLabel(for: kana))
                                    .font(.caption2)
                                    .foregroundStyle(viewModel.isKanaLearned(kana) ? .green : .white.opacity(0.55))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Double tap to hear and mark this hiragana as learned.")
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
    }

    private var placeholderKanaCell: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.clear)
            .frame(maxWidth: .infinity, minHeight: 92)
    }

    private var dictionarySection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredEntries) { entry in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.kana)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text(entry.romaji)
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.75))

                                Text(entry.translation)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.primary)
                            }

                            Spacer()

                            Button {
                                viewModel.speak(entry: entry)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white.opacity(0.12), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        Text(entry.usage)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))

                        HStack(spacing: 8) {
                            Label(entry.category.rawValue, systemImage: entry.category.icon)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.8))

                            if let groupLabel = entry.groupLabel {
                                Text(groupLabel)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.12), in: Capsule())
                            }

                            if let kindLabel = entry.kindLabel {
                                Text(kindLabel)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Theme.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Theme.primary.opacity(0.14), in: Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.8))
                }
            }
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
    }

    private var flashcardsSection: some View {
        VStack(spacing: 18) {
            if let card = viewModel.currentFlashcard {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewModel.showFlashcardAnswer.toggle()
                    }
                } label: {
                    VStack(spacing: 18) {
                        Text(viewModel.showFlashcardAnswer ? card.translation : card.kana)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text(viewModel.showFlashcardAnswer ? card.romaji : "Tap to reveal meaning")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.75))

                        if viewModel.showFlashcardAnswer {
                            Text(card.usage)
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.78))
                                .multilineTextAlignment(.center)

                            HStack(spacing: 8) {
                                if let groupLabel = card.groupLabel {
                                    Text(groupLabel)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.white.opacity(0.12), in: Capsule())
                                }

                                if let kindLabel = card.kindLabel {
                                    Text(kindLabel)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Theme.primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Theme.primary.opacity(0.14), in: Capsule())
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                    .padding(24)
                    .background(
                        LinearGradient(
                            colors: [Theme.primary.opacity(0.45), Color.black.opacity(0.28)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 26, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                HStack(spacing: 12) {
                    Button("Prev") {
                        viewModel.previousFlashcard()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)

                    Button {
                        viewModel.speak(entry: card)
                    } label: {
                        Label("Listen", systemImage: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primary)

                    Button("Learned") {
                        viewModel.markEntryLearned(card)
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)

                    Button("Next") {
                        viewModel.nextFlashcard()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var quizSection: some View {
        VStack(spacing: 18) {
            if let entry = viewModel.currentQuizEntry {
                VStack(spacing: 18) {
                    Text("What does this mean?")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(entry.kana)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(entry.romaji)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.72))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))

                VStack(spacing: 10) {
                    ForEach(viewModel.quizOptions, id: \.self) { option in
                        Button(option) {
                            viewModel.submitQuizAnswer(option)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.primary.opacity(0.9))
                        .frame(maxWidth: .infinity)
                    }
                }

                if let feedback = viewModel.quizFeedback {
                    Text(feedback)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(feedback == "Correct" ? .green : .orange)
                }

                Button("Next Quiz") {
                    viewModel.nextQuiz()
                }
                .buttonStyle(.bordered)
                .tint(.white)
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            viewModel.prepareQuiz()
        }
    }

    private var practiceSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let selectedEntry = selectedPracticeEntry {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Practice target")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.72))

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedEntry.kana)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text(selectedEntry.romaji)
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.72))

                                Text(selectedEntry.translation)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.primary)
                            }

                            Spacer()

                            Button {
                                viewModel.speak(entry: selectedEntry)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white.opacity(0.12), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        Text(selectedEntry.usage)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.8))
                }

                Menu {
                    ForEach(viewModel.filteredEntries) { entry in
                        Button("\(entry.kana) • \(entry.translation)") {
                            selectedPracticeEntryID = entry.id
                            practiceWord = entry.kana
                            resetPracticeFeedback()
                        }
                    }
                } label: {
                    HStack {
                        Text("Choose practice word")
                        Spacer()
                        Text(selectedPracticeEntry?.kana ?? "None")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                KanaComposerView(composedWord: $practiceWord, isFloating: false)

                if let selectedEntry = selectedPracticeEntry {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Goal")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.72))

                        Text("Match your input to \(selectedEntry.kana) (\(selectedEntry.romaji)).")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.78))

                        Button("Check Practice") {
                            let result = viewModel.practiceFeedback(for: practiceWord, target: selectedEntry)
                            practiceFeedbackMessage = result.message
                            practiceFeedbackSuccess = result.isSuccess
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.primary)

                        if let practiceFeedbackMessage {
                            Text(practiceFeedbackMessage)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(practiceFeedbackSuccess ? .green : .white)
                        } else {
                            Text("Use keyboard, canvas, or Japanese voice, then validate your answer.")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .glassCard()
                }
            }
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .onChange(of: viewModel.filteredEntries.map(\.id)) { _, _ in
            syncPracticeEntry()
        }
        .onChange(of: practiceWord) { _, _ in
            resetPracticeFeedback()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("No entries found")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Try another category or search term.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .glassCard()
    }

    private var selectedPracticeEntry: LearningEntry? {
        if let selectedPracticeEntryID {
            return viewModel.filteredEntries.first(where: { $0.id == selectedPracticeEntryID })
        }

        return viewModel.filteredEntries.first
    }

    private func syncPracticeEntry() {
        guard let fallback = viewModel.filteredEntries.first else {
            selectedPracticeEntryID = nil
            practiceWord = ""
            return
        }

        if selectedPracticeEntry == nil {
            selectedPracticeEntryID = fallback.id
            practiceWord = fallback.kana
            resetPracticeFeedback()
        }
    }

    private func resetPracticeFeedback() {
        practiceFeedbackMessage = nil
        practiceFeedbackSuccess = false
    }
}

private struct LearningChipStyle: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Theme.primary.opacity(0.75) : Color.white.opacity(0.12))
            )
    }
}

struct DrawingCanvasView: View {
    var body: some View {
        LearningView()
    }
}

struct KanaComposerView: View {
    struct PredictionResponse: Decodable {
        let character: String
        let confidence: Double
        let classIndex: Int

        enum CodingKeys: String, CodingKey {
            case character
            case confidence
            case classIndex = "class_index"
        }
    }

    @Binding var composedWord: String
    var isFloating = true
    var onClose: (() -> Void)?

    @State private var selectedMode: KanaComposerInputMode = .keyboard
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var exportedImage: UIImage?
    @State private var predictionResponse: PredictionResponse?
    @State private var isUploading = false
    @State private var errorMessage: String?
    @State private var voiceInputService = VoiceInputService()
    @State private var voiceBaseWord = ""
    @State private var keyboardDraft = ""

    private let endpoint = "http://31.220.50.65:9900/predict"
    private let canvasSize = CGSize(width: 240, height: 240)
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(
            configuration: configuration,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            liveWordSection
            modePicker
            modeContent

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
        .accessibilityElement(children: .contain)
        .onChange(of: selectedMode) { _, newValue in
            if newValue != .voice {
                voiceInputService.stopListening()
            }

            if newValue != .keyboard {
                keyboardDraft = ""
            }
        }
        .onChange(of: keyboardDraft) { _, newValue in
            guard selectedMode == .keyboard else { return }
            composedWord = romanjiToHiragana(newValue)
        }
        .onChange(of: voiceInputService.transcript) { _, newValue in
            guard selectedMode == .voice else { return }
            composedWord = voiceBaseWord + romanjiToHiragana(normalizedVoiceText(from: newValue))
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Kana Practice")
                    .font(.headline.bold())
                    .foregroundStyle(.white)

                Text("Use keyboard, canvas, or Japanese voice input.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close kana composer")
            }
        }
    }

    private var liveWordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Current word")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                Button {
                    removeLastCharacter()
                } label: {
                    Image(systemName: "delete.left")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
                .disabled(composedWord.isEmpty)
                .opacity(composedWord.isEmpty ? 0.45 : 1)
                .accessibilityLabel("Delete last character")
            }

            HStack(spacing: 12) {
                Text(displayedWord.isEmpty ? "..." : displayedWord)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !displayedWord.isEmpty {
                    Text("\(displayedWord.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(KanaComposerInputMode.allCases) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    Label(mode.rawValue, systemImage: mode.icon)
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedMode == mode ? Theme.primary.opacity(0.8) : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var modeContent: some View {
        switch selectedMode {
        case .keyboard:
            keyboardComposer
        case .canvas:
            canvasComposer
        case .voice:
            voiceComposer
        }
    }

    private var keyboardComposer: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Type in romaji", text: $keyboardDraft)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .accessibilityLabel("Romaji input")
                .accessibilityHint("Type in romaji and the current word updates in hiragana.")

            Text("Type in romaji below. The current word above updates in hiragana.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
        }
    }

    private var canvasComposer: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)

                Canvas { context, _ in
                    for stroke in strokes {
                        drawStroke(stroke, in: &context)
                    }

                    drawStroke(currentStroke, in: &context)
                }
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentStroke.append(value.location)
                    }
                    .onEnded { _ in
                        guard !currentStroke.isEmpty else { return }
                        strokes.append(currentStroke)
                        currentStroke = []
                    }
            )
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Drawing canvas")
            .accessibilityHint("Draw one hiragana character, then activate OK to recognize it.")

            HStack(spacing: 12) {
                Button("Prev") {
                    undoLastStroke()
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .disabled(isCanvasEmpty)
                .accessibilityHint("Removes the most recent stroke.")

                Button(isUploading ? "Reading..." : "OK") {
                    Task {
                        await exportAndPredict()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
                .disabled(isUploading || isCanvasEmpty)
                .accessibilityHint("Recognizes the drawing and adds the hiragana to the current word.")
            }

            if let predictionResponse {
                Text("Last kana: \(predictionResponse.character)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
            } else {
                Text("Write one hiragana, tap OK, and it will append to the word.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
    }

    private var voiceComposer: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(voiceInputService.isListening ? "Stop Voice" : "Start Voice") {
                if voiceInputService.isListening {
                    voiceInputService.stopListening()
                } else {
                    voiceBaseWord = composedWord
                    voiceInputService.resetTranscript()

                    Task {
                        await voiceInputService.startListening()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(voiceInputService.isListening ? .orange : Theme.primary)
            .accessibilityHint("Starts or stops Japanese speech input.")

            Text(voiceInputService.transcript.isEmpty ? "Speak in Japanese to fill the word live." : voiceInputService.transcript)
                .font(.body)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 16))

            Text("Uses Apple on-device speech recognition when available.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
        }
    }

    private var isCanvasEmpty: Bool {
        strokes.isEmpty && currentStroke.isEmpty
    }

    private func drawStroke(_ points: [CGPoint], in context: inout GraphicsContext) {
        guard !points.isEmpty else { return }

        var path = Path()
        path.move(to: points[0])

        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        context.stroke(
            path,
            with: .color(.black),
            style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)
        )
    }

    private func undoLastStroke() {
        if !currentStroke.isEmpty {
            currentStroke.removeAll()
        } else if !strokes.isEmpty {
            strokes.removeLast()
        }

        errorMessage = nil
    }

    @MainActor
    private func exportAndPredict() async {
        errorMessage = nil
        predictionResponse = nil

        guard let image = renderCanvasImage(size: canvasSize) else {
            errorMessage = "Could not render image."
            return
        }

        exportedImage = image

        guard let jpgData = image.jpegData(compressionQuality: 0.9) else {
            errorMessage = "Could not convert image to JPG."
            return
        }

        isUploading = true
        defer { isUploading = false }

        do {
            let responseText = try await uploadImage(jpgData: jpgData, filename: "drawing.jpg")
            guard let jsonData = responseText.data(using: .utf8) else {
                errorMessage = "The server response could not be read."
                return
            }

            let decoded = try JSONDecoder().decode(PredictionResponse.self, from: jsonData)
            predictionResponse = decoded
            composedWord.append(contentsOf: normalizedKanaPrediction(decoded.character))
            clearCanvas()
        } catch {
            errorMessage = "Prediction failed: \(error.localizedDescription)"
        }
    }

    private func clearCanvas() {
        strokes = []
        currentStroke = []
        exportedImage = nil
    }

    private func renderCanvasImage(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let cgContext = context.cgContext
            cgContext.setStrokeColor(UIColor.black.cgColor)
            cgContext.setLineWidth(16)
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)

            for stroke in strokes {
                guard let first = stroke.first else { continue }
                cgContext.beginPath()
                cgContext.move(to: first)

                for point in stroke.dropFirst() {
                    cgContext.addLine(to: point)
                }

                cgContext.strokePath()
            }
        }
    }

    private func uploadImage(jpgData: Data, filename: String) async throws -> String {
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(jpgData)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")

        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverText = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NSError(
                domain: "UploadError",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: serverText]
            )
        }

        return String(data: data, encoding: .utf8) ?? ""
    }

    private func normalizedVoiceText(from text: String) -> String {
        text
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }

    private func removeLastCharacter() {
        guard !composedWord.isEmpty else { return }

        if selectedMode == .keyboard, !keyboardDraft.isEmpty {
            keyboardDraft.removeLast()
            composedWord = romanjiToHiragana(keyboardDraft)
            return
        }

        composedWord.removeLast()
    }

    private var displayedWord: String {
        return composedWord
    }

    private func romanjiToHiragana(_ text: String) -> String {
        guard !text.isEmpty else { return "" }

        let mutable = NSMutableString(string: text.lowercased())
        CFStringTransform(mutable, nil, kCFStringTransformLatinHiragana, false)
        return mutable as String
    }

    private func normalizedKanaPrediction(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let converted = romanjiToHiragana(trimmed)
        return converted.isEmpty ? trimmed : converted
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

#Preview {
    LearningView()
}
