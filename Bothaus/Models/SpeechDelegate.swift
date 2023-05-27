//
//  SpeechDelegate.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import Foundation
import Speech

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let chatModel: ChatModel

    init(chatModel: ChatModel) {
        self.chatModel = chatModel
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        chatModel.didStartSpeech()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        chatModel.didStopSpeech()
    }
}
