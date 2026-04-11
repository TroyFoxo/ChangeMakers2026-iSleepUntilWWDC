//
//  SpeechService.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Raymond Chavez on 10/04/26.
//


import Foundation
import AVFoundation
import Speech

@Observable
final class SpeechService {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(text: String, languageCode: String = "ja-JP") {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 1

        synthesizer.speak(utterance)
    }
}

@MainActor
@Observable
final class VoiceInputService {
    var transcript = ""
    var isListening = false
    var errorMessage: String?

    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func startListening() async {
        errorMessage = nil

        guard await requestPermissions() else { return }
        guard let recognizer else {
            errorMessage = "Japanese voice recognition is unavailable on this device."
            return
        }
        guard recognizer.isAvailable else {
            errorMessage = "Speech recognition is not available right now."
            return
        }

        stopListening()

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.requiresOnDeviceRecognition = true
            request.taskHint = .dictation
            recognitionRequest = request

            let inputNode = audioEngine.inputNode
            inputNode.removeTap(onBus: 0)

            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isListening = true

            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }

                Task { @MainActor in
                    if let result {
                        self.transcript = result.bestTranscription.formattedString
                    }

                    if let error {
                        self.errorMessage = error.localizedDescription
                        self.stopListening()
                    } else if result?.isFinal == true {
                        self.stopListening()
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            stopListening()
        }
    }

    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func resetTranscript() {
        transcript = ""
        errorMessage = nil
    }

    private func requestPermissions() async -> Bool {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        guard speechAuthorized else {
            errorMessage = "Speech recognition permission is required."
            return false
        }

        let micAuthorized = await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }

        guard micAuthorized else {
            errorMessage = "Microphone permission is required."
            return false
        }

        return true
    }
}
