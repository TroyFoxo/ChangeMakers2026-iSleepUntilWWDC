//
//  MainMenu.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Alumno on 08/04/26.
//

//
//  ContentView.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Alumno on 08/04/26.
//

import SwiftUI

struct GameView: View {
    @State private var diceViewModel = DiceViewModel.shared
    @State private var showNextView = false
    @State private var isVisible = true
    @State private var userPrompt = ""
    @State private var isComposerVisible = true
    @State private var conversation: [AdventureChatMessage] = []
    @State private var isDicePickerVisible = false
    @State private var worldObjectives: [CampaignObjective] = []

    @AppStorage("world_main_tasks_json") private var worldMainTasksJSON = ""
    @AppStorage("adventure_user_message_count") private var adventureUserMessageCount = 0

    @State var NPCDialogue = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    private let kanaComposerBottomInset: CGFloat = 112
    private let kanaLauncherBottomInset: CGFloat = 114
    private let kanaLauncherExpandedDiceInset: CGFloat = 172
    var body: some View {
        VStack {
            if isVisible {
                VStack {
                    ZStack {
                        Image("ForestTrees")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 300)
                            .opacity(0.4)
                            .accessibilityHidden(true)

                        Image("HouseBG")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 300)
                            .opacity(0.4)
                            .accessibilityHidden(true)

                        Image("DndPotionLadySmaller")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: 380, maxHeight: 200, alignment: .bottom)
                    .padding(.bottom, 40)
                    .glassCard(isPrimary: true)

                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(NPCDialogue)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 4)
                                    .accessibilityLabel("Narrator dialogue")

                                ForEach(conversation) { message in
                                    HStack {
                                        if message.isUser {
                                            Spacer(minLength: 48)
                                        }

                                        VStack(alignment: .leading, spacing: 6) {
                                            if let diceSummary = message.diceSummary {
                                                Label(diceSummary, systemImage: "dice.fill")
                                                    .font(.caption.weight(.semibold))
                                                    .foregroundStyle(.white.opacity(0.85))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(Color.black.opacity(0.22), in: Capsule())
                                            }

                                            Text(message.text)
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 12)
                                                .background(
                                                    message.isUser
                                                        ? Theme.primary.opacity(0.32)
                                                        : Color.white.opacity(0.14),
                                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                )
                                        }
                                        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                                        .id(message.id)
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel(message.isUser ? "Your message" : "Adventure message")

                                        if !message.isUser {
                                            Spacer(minLength: 48)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        }
                        .scrollIndicators(.hidden)
                        .onChange(of: conversation.count) { _, _ in
                            guard let lastID = conversation.last?.id else { return }
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }
                    .frame(maxWidth: 380, maxHeight: 200, alignment: .bottom)
                    .glassCard(isPrimary: true)
                }

                Spacer()

                if isDicePickerVisible {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose the die for this action")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.78))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(availableDiceSides, id: \.self) { sides in
                                    Button {
                                        diceViewModel.selectDice(sides: sides)
                                    } label: {
                                        Text("d\(sides)")
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(
                                                        diceViewModel.selectedSides == sides
                                                            ? Theme.primary.opacity(0.72)
                                                            : Color.white.opacity(0.12)
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(
                                                        diceViewModel.selectedSides == sides
                                                            ? Theme.primary
                                                            : Color.white.opacity(0.12),
                                                        lineWidth: 1.2
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Select d\(sides)")
                                    .accessibilityValue(diceViewModel.selectedSides == sides ? "Selected" : "Not selected")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            isDicePickerVisible.toggle()
                        }
                    } label: {
                        Image(systemName: "dice.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(isDicePickerVisible ? Theme.primary.opacity(0.75) : Color.white.opacity(0.12))
                            )
                            .overlay(
                                Circle()
                                    .stroke(isDicePickerVisible ? Theme.primary : Color.white.opacity(0.12), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isDicePickerVisible ? "Hide dice options" : "Show dice options")

                    TextField("¿Que harás ahora?:", text: $userPrompt)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .frame(height: 50)
                        .accessibilityLabel("Adventure message")
                        .accessibilityHint("Enter your action or reaction plan.")

                    Button("Send") {
                        sendMessage()
                    }
                    .glassCard(isPrimary: true)
                    .foregroundStyle(.white)
                    .frame(height: 50)
                    .disabled(trimmedPrompt.isEmpty)
                    .accessibilityHint("Sends your message and rolls the selected die.")
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom)

            } else {
                Spacer()

                if !worldObjectives.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Main Adventures")
                            .font(.headline)
                            .foregroundStyle(.white)

                        VStack(spacing: 10) {
                            ForEach(worldObjectives) { objective in
                                Button {
                                    toggleObjective(objective.id)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(objective.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.white)
                                                .multilineTextAlignment(.leading)

                                            Spacer()

                                            Text(objective.isCompleted ? "Done" : "In progress")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(objective.isCompleted ? .green : .white.opacity(0.7))
                                        }

                                        ProgressView(value: objective.isCompleted ? 1 : 0, total: 1)
                                            .tint(objective.isCompleted ? .green : Theme.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(objective.title)
                                .accessibilityValue(objective.isCompleted ? "Completed" : "In progress")
                                .accessibilityHint("Double tap to toggle this objective.")
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding()
                }

                Spacer()
            }
        }
        .frame(maxWidth: 400, maxHeight: .infinity)
        .background {
            ZStack {
                Image("DndMapPlaceholder")
                    .resizable()
                    .scaledToFill()

                if isVisible {
                    Color.black.opacity(0.54)
                } else {
                    Color.black.opacity(0)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            loadObjectives()
        }
        .onChange(of: worldMainTasksJSON) { _, _ in
            loadObjectives()
        }
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 12) {
                if isVisible && !isDicePickerVisible && isComposerVisible {
                    KanaComposerView(composedWord: $userPrompt) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isComposerVisible = false
                        }
                    }
                    .frame(maxWidth: 360)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if isVisible && !isComposerVisible && !isDicePickerVisible {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isComposerVisible = true
                        }
                    } label: {
                        Label("Kana", systemImage: "character.textbox.ja")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open kana composer")
                }

                if !isDicePickerVisible {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isVisible.toggle()
                            if !isVisible {
                                isDicePickerVisible = false
                                isComposerVisible = false
                            }
                        }
                    } label: {
                        Label(isVisible ? "Ocultar diálogo" : "Mostrar diálogo", systemImage: isVisible ? "map.fill" : "arrow.uturn.backward.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Theme.primary.opacity(0.35), Color.white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Theme.primary.opacity(0.85), lineWidth: 1.5)
                    )
                    .accessibilityLabel(isVisible ? "Hide dialogue" : "Show dialogue")
                }
            }
            .padding(.trailing, 16)
            .padding(.bottom, overlayBottomInset)
        }
    }

    private var overlayBottomInset: CGFloat {
        if !isVisible {
            return 24
        }

        if isComposerVisible {
            return kanaComposerBottomInset
        }

        return isDicePickerVisible ? kanaLauncherExpandedDiceInset : kanaLauncherBottomInset
    }

    private var trimmedPrompt: String {
        userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sendMessage() {
        guard !trimmedPrompt.isEmpty else { return }

        conversation.append(
            AdventureChatMessage(
                text: trimmedPrompt,
                isUser: true,
                diceSummary: rolledDiceSummary()
            )
        )
        adventureUserMessageCount += 1

        userPrompt = ""
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            isDicePickerVisible = false
        }
    }

    private var availableDiceSides: [Int] {
        diceViewModel.availableDiceSides
    }

    private func rolledDiceSummary() -> String {
        let sides = diceViewModel.selectedSides
        let result = diceViewModel.rollInstant()
        return "d\(sides): \(result)"
    }

    private func loadObjectives() {
        guard let data = worldMainTasksJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([CampaignObjective].self, from: data) else {
            worldObjectives = []
            return
        }
        worldObjectives = decoded
    }

    private func toggleObjective(_ id: UUID) {
        guard let index = worldObjectives.firstIndex(where: { $0.id == id }) else { return }
        worldObjectives[index].isCompleted.toggle()
        saveObjectives()
    }

    private func saveObjectives() {
        guard let data = try? JSONEncoder().encode(worldObjectives),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        worldMainTasksJSON = json
    }
}


#Preview {
    GameView()
}
