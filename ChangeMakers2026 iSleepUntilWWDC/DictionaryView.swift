import SwiftUI

struct DictionaryView: View {
    @State private var viewModel = DictionaryViewModel()
    @State private var learningViewModel = LearningViewModel()
    @State private var selectedSection = 0
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Grimoire")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    Text("Review learned hiragana and useful words.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Picker("Section", selection: $selectedSection) {
                    Text("Hiragana").tag(0)
                    Text("Words").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollView {
                    if selectedSection == 0 {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(grimoireKanaGrid) { kana in
                                if kana.isEmpty {
                                    KanaCellView(kana: kana)
                                } else {
                                    Button(action: {
                                        viewModel.playSound(for: kana)
                                    }) {
                                        KanaCellView(kana: kana)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityHint("Double tap to hear this hiragana.")
                                }
                            }
                        }
                        .padding()
                    } else {
                        if learningViewModel.learnedEntries.isEmpty {
                            emptyState("No words learned yet", "Use dictionary, flashcards, quizzes, or practice to register phrases.")
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(learningViewModel.learnedEntries) { entry in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.kana)
                                                    .font(.title3.bold())
                                                    .foregroundStyle(.white)
                                                Text(entry.romaji)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white.opacity(0.75))
                                            }
                                            Spacer()
                                            Text(entry.translation)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Theme.primary)
                                        }

                                        Text(entry.usage)
                                            .font(.footnote)
                                            .foregroundStyle(.white.opacity(0.78))

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
                                    .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
                                    .accessibilityElement(children: .combine)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                GlobalBackground()
            }
            .navigationTitle("Diccionario")
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func emptyState(_ title: String, _ subtitle: String) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding()
    }

    private var grimoireKanaGrid: [Kana] {
        DictionaryViewModel.kanaAlphabetLibrary.map { kana in
            guard !kana.isEmpty else { return kana }
            return learningViewModel.isKanaLearned(kana)
                ? kana
                : Kana(character: "", romaji: "", group: kana.group)
        }
    }
}

#Preview {
    DictionaryView()
}
