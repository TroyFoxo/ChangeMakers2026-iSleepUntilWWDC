//
//  SpeechService.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Raymond Chavez on 10/04/26.
//


import Foundation
import AVFoundation

@Observable
class SpeechService {
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(text: String, languageCode: String = "ja-JP") {
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 1
        
        synthesizer.speak(utterance)
    }
}
