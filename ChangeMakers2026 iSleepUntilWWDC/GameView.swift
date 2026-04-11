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
    @StateObject private var chatViewModel = ChatBotViewModel()
    @State private var isVisible = true
    @State private var userPrompt = ""
    @State private var isComposerVisible = true
    @State private var conversation: [AdventureChatMessage] = []
    @State private var isDicePickerVisible = false
    @State private var worldObjectives: [CampaignObjective] = []
    @State private var selectedMessageType: AdventureMessageType = .action
    @State private var requiresReactionFollowUp = false
    @State private var isRollingForSend = false

    @AppStorage("world_main_tasks_json") private var worldMainTasksJSON = ""
    @AppStorage("adventure_user_message_count") private var adventureUserMessageCount = 0

    private let kanaComposerBottomInset: CGFloat = 108
    private let kanaLauncherBottomInset: CGFloat = 92
    private let dialogueOnlyBottomInset: CGFloat = 92
    private let kanaLauncherExpandedDiceInset: CGFloat = 184
    var body: some View {
        VStack {
            if isVisible {
                VStack {
                    ZStack {
                        Image("ForestTrees")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 250)
                            .opacity(0.4)
                            .accessibilityHidden(true)

                        Image("HouseBG")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 250)
                            .opacity(0.4)
                            .accessibilityHidden(true)

                        Image("DndPotionLadySmaller")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 220)
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: 340, maxHeight: 150, alignment: .bottom)
                    .padding(.bottom, 20)
                    .glassCard(isPrimary: true)

                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(conversation) { message in
                                    HStack {
                                        if message.isUser {
                                            Spacer(minLength: 48)
                                        }

                                        VStack(alignment: .leading, spacing: 6) {
                                            if let messageType = message.messageType {
                                                Label(messageType.rawValue, systemImage: messageType.icon)
                                                    .font(.caption.weight(.semibold))
                                                    .foregroundStyle(.white.opacity(0.88))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(Color.black.opacity(0.22), in: Capsule())
                                            }

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
                    .frame(maxWidth: 380, maxHeight: 220, alignment: .bottom)
                    .glassCard(isPrimary: true)
                }

                Spacer()

                if !isDicePickerVisible {
                    Text(messageTypeHeader)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }

                if isDicePickerVisible && selectedMessageType.requiresDice {
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
                    if !isDicePickerVisible {
                        Button {
                            toggleMessageType()
                        } label: {
                            Image(systemName: typeSelectorIcon(for: selectedMessageType))
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Theme.primary.opacity(0.72))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Theme.primary, lineWidth: 1.2)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(requiresReactionFollowUp)
                        .accessibilityLabel(selectedMessageType.rawValue)
                        .accessibilityHint(requiresReactionFollowUp ? "Reaction is required after an action." : "Switches between action and narrative.")
                    }

                    TextField(inputPlaceholder, text: $userPrompt)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .frame(height: 50)
                        .accessibilityLabel("Adventure message")
                        .accessibilityHint("Enter your action or reaction plan.")

                    Button {
                        Task {
                            await sendMessage()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Theme.primary, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .disabled(trimmedPrompt.isEmpty)
                    .accessibilityLabel("Send message")
                    .accessibilityHint("Sends your message and rolls the selected die when needed.")
                }
                .padding(.horizontal)
                .padding(.top, 8)
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
            syncInitialConversationIfNeeded()
        }
        .onChange(of: worldMainTasksJSON) { _, _ in
            loadObjectives()
        }
        .onChange(of: selectedMessageType) { _, newValue in
            guard !newValue.requiresDice else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                isDicePickerVisible = false
                isComposerVisible = false
            }
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 10) {
                if isVisible && selectedMessageType.requiresDice && !isDicePickerVisible && isComposerVisible {
                    KanaComposerView(composedWord: $userPrompt) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isComposerVisible = false
                        }
                    }
                    .frame(maxWidth: 360)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if isVisible && selectedMessageType.requiresDice && !isComposerVisible && !isDicePickerVisible {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isComposerVisible = true
                        }
                    } label: {
                        Image(systemName: "character.textbox.ja")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open kana composer")
                }

                if isVisible && selectedMessageType.requiresDice {
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
                                    .fill(Color.white.opacity(0.12))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isDicePickerVisible ? "Hide dice options" : "Show dice options")
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
                        Image(systemName: isVisible ? "map.fill" : "arrow.uturn.backward.circle.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [Theme.primary.opacity(0.35), Color.white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: Circle()
                            )
                    }
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(Theme.primary.opacity(0.85), lineWidth: 1.5)
                    )
                    .accessibilityLabel(isVisible ? "Hide dialogue" : "Show dialogue")
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, overlayBottomInset)
        }
        .overlay {
            if isRollingForSend {
                ZStack {
                    Color.black.opacity(0.56)
                        .ignoresSafeArea()

                    VStack(spacing: 14) {
                        Text("Rolling d\(diceViewModel.selectedSides)")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)

                        DiceFaceView(value: diceViewModel.displayValue, isRolling: diceViewModel.isRolling)
                            .rotationEffect(.degrees(diceViewModel.shakeDirection))
                            .scaleEffect(diceViewModel.diceScale)
                            .animation(
                                diceViewModel.isRolling
                                ? .linear(duration: 0.08).repeatForever(autoreverses: true)
                                : .default,
                                value: diceViewModel.shakeDirection
                            )

                        Text("The result will be used for the scene.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .transition(.opacity)
            }
        }
    }

    private var overlayBottomInset: CGFloat {
        if !isVisible {
            return 24
        }

        if !selectedMessageType.requiresDice {
            return dialogueOnlyBottomInset
        }

        if isDicePickerVisible {
            return kanaLauncherExpandedDiceInset
        }

        if isComposerVisible {
            return kanaComposerBottomInset
        }

        return kanaLauncherBottomInset
    }

    private var trimmedPrompt: String {
        userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var inputPlaceholder: String {
        switch selectedMessageType {
        case .action:
            return "Describe your action"
        case .reaction:
            return "Describe your reaction"
        case .narrative:
            return "Add narrative context"
        }
    }

    private var messageTypeHeader: String {
        if requiresReactionFollowUp {
            return "Choose the reaction: \(selectedMessageType.rawValue)"
        }

        return "Choose your message type: \(selectedMessageType.rawValue)"
    }

    private var availableMessageTypes: [AdventureMessageType] {
        requiresReactionFollowUp ? [.reaction] : [.action, .narrative]
    }

    private func typeSelectorIcon(for type: AdventureMessageType) -> String {
        switch type {
        case .action:
            return "flame.fill"
        case .reaction:
            return "arrow.uturn.backward.circle.fill"
        case .narrative:
            return "text.bubble.fill"
        }
    }

    private func toggleMessageType() {
        guard !requiresReactionFollowUp else {
            selectedMessageType = .reaction
            return
        }

        selectedMessageType = selectedMessageType == .action ? .narrative : .action
    }

    private func syncInitialConversationIfNeeded() {
        guard conversation.isEmpty else { return }
        conversation = [
            AdventureChatMessage(
                text: ChatBotViewModel.initialSceneText,
                isUser: false,
                diceSummary: nil,
                messageType: nil
            )
        ]
    }

    private func sendMessage() async {
        guard !trimmedPrompt.isEmpty else { return }

        let prompt = trimmedPrompt
        let currentMessageType = selectedMessageType
        let diceSummary: String?

        if currentMessageType.requiresDice {
            isRollingForSend = true
            let result = await diceViewModel.rollAnimated()
            diceSummary = "d\(diceViewModel.selectedSides): \(result)"
            isRollingForSend = false
        } else {
            diceSummary = nil
        }

        conversation.append(
            AdventureChatMessage(
                text: prompt,
                isUser: true,
                diceSummary: diceSummary,
                messageType: currentMessageType
            )
        )
        adventureUserMessageCount += 1

        userPrompt = ""

        if currentMessageType == .action {
            requiresReactionFollowUp = true
            selectedMessageType = .reaction
        } else if currentMessageType == .reaction {
            requiresReactionFollowUp = false
            selectedMessageType = .action
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            isDicePickerVisible = false
            if !selectedMessageType.requiresDice {
                isComposerVisible = false
            }
        }

        let replies = await chatViewModel.sendMessage(
            prompt,
            messageType: currentMessageType,
            diceSummary: diceSummary,
            addUserMessage: false
        )

        conversation.append(
            contentsOf: replies.map {
                AdventureChatMessage(
                    text: $0.text,
                    isUser: false,
                    diceSummary: nil,
                    messageType: nil
                )
            }
        )
    }

    private var availableDiceSides: [Int] {
        diceViewModel.availableDiceSides
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
