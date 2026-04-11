//
//  ChatBotView.swift
//  ChangeMakers2026 iSleepUntilWWDC
//

import SwiftUI
import Combine
import FoundationModels

// MARK: - Models

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

@Generable
struct SceneReply {
    @Guide(description: "A short fantasy narration continuing the current scene.")
    let narration: String

    @Guide(description: "What the NPC says in response to the player.")
    let npcDialogue: String

    @Guide(description: "A short explanation of the social cue in the scene.")
    let socialHint: String
}

// MARK: - ViewModel

@MainActor
final class ChatBotViewModel: ObservableObject {
    static let initialSceneText = """
    Welcome, adventurer. You enter the Lantern & Leaf tavern.
    A nervous elf named Mira is sitting alone, looking unsure whether to speak.
    What do you do?
    """

    @Published var messages: [ChatMessage] = [
        ChatMessage(
            text: ChatBotViewModel.initialSceneText,
            isUser: false
        )
    ]

    @Published var input: String = ""
    @Published var isLoading: Bool = false
    @Published var errorText: String? = nil

    private let model = SystemLanguageModel.default

    private lazy var session = LanguageModelSession(
        model: model,
        instructions: """
        You are a Dungeon & Dragons style narrative chatbot for a supportive social practice app.

        Your goals:
        - Create short fantasy scenes.
        - Keep language clear and gentle.
        - Include social context in each reply.
        - Help the player notice emotions, intentions, and body language.
        - Keep scenes safe, calm, and encouraging.
        - Do not shame the player.
        - Keep responses concise.

        Always return:
        - narration: 1 short paragraph
        - npcDialogue: what the character says
        - socialHint: one short explanation of the social cue
        """
    )

    func sendMessage() async {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoading else { return }

        input = ""
        _ = await sendMessage(
            trimmed,
            messageType: .narrative,
            diceSummary: nil,
            addUserMessage: true
        )
    }

    @discardableResult
    func sendMessage(
        _ text: String,
        messageType: AdventureMessageType,
        diceSummary: String?,
        addUserMessage: Bool = true
    ) async -> [ChatMessage] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoading else { return [] }

        if addUserMessage {
            messages.append(ChatMessage(text: trimmed, isUser: true))
        }
        errorText = nil
        isLoading = true

        defer { isLoading = false }

        do {
            let diceContext = if let diceSummary, messageType.requiresDice {
                """
                This is a \(messageType.rawValue.lowercased()) check.
                Dice result: \(diceSummary).
                A higher dice result means the player is more likely to perform the attempt correctly.
                A low dice result can cause a partial success, awkward success, or failure.
                """
            } else {
                "This message does not use a dice roll."
            }

            let prompt = """
            Continue the fantasy roleplay scene.

            The player's message type is: \(messageType.rawValue).
            \(diceContext)

            The player says:
            "\(trimmed)"

            Respond with:
            - narration
            - npcDialogue
            - socialHint
            """

            let response = try await session.respond(
                to: prompt,
                generating: SceneReply.self
            )

            let reply = response.content
            let generated = [
                ChatMessage(text: reply.narration, isUser: false),
                ChatMessage(text: "Mira: \(reply.npcDialogue)", isUser: false),
                ChatMessage(text: "Social hint: \(reply.socialHint)", isUser: false)
            ]

            messages.append(contentsOf: generated)
            return generated
        } catch {
            errorText = error.localizedDescription
            let fallback = ChatMessage(
                text: "I couldn’t generate a reply right now: \(error.localizedDescription)",
                isUser: false
            )
            messages.append(fallback)
            return [fallback]
        }
    }

    func resetConversation() {
        messages = [
            ChatMessage(
                text: ChatBotViewModel.initialSceneText,
                isUser: false
            )
        ]
        input = ""
        errorText = nil
        isLoading = false
    }
}

// MARK: - View

@available(iOS 26.0, *)
struct ChatBotView: View {
    @StateObject private var vm = ChatBotViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.messages) { message in
                                HStack {
                                    if message.isUser {
                                        Spacer(minLength: 40)
                                    }

                                    Text(message.text)
                                        .padding(12)
                                        .background(
                                            message.isUser
                                            ? Color.blue.opacity(0.18)
                                            : Color.gray.opacity(0.15)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: message.isUser ? .trailing : .leading
                                        )
                                        .id(message.id)

                                    if !message.isUser {
                                        Spacer(minLength: 40)
                                    }
                                }
                            }

                            if vm.isLoading {
                                HStack {
                                    ProgressView()
                                    Text("Thinking...")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: vm.messages.count) { _, _ in
                        if let lastID = vm.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                HStack(spacing: 10) {
                    TextField("Say something to the character...", text: $vm.input, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)

                    Button {
                        Task {
                            await vm.sendMessage()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                            .padding(10)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isLoading)
                }
                .padding()
            }
            .navigationTitle("DnD Chatbot")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        vm.resetConversation()
                    }
                }
            }
        }
    }
}

// MARK: - Fallback for unsupported OS

struct UnsupportedView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("This demo requires iOS 26 or later.")
                .font(.headline)

            Text("It uses Apple’s Foundation Models framework.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    if #available(iOS 26.0, *) {
        ChatBotView()
    } else {
        UnsupportedView()
    }
}
