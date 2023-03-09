// TextToSpeech.swift
// Bothaus
//
// Created by kasima on 3/5/23.
//

import AVFoundation

class TextToSpeech {
    private let speechSynthesizer = AVSpeechSynthesizer()

    init(delegate: AVSpeechSynthesizerDelegate) {
        speechSynthesizer.delegate = delegate
    }

    func speak(text: String, voiceIdentifier: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)
        speechSynthesizer.speak(utterance)

        disableAVSession()
    }

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't disable.")
        }
    }
}
