//
//  SpeechDelegate.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import Foundation
import Speech

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let talkModel: TalkModel

    init(talkModel: TalkModel) {
        self.talkModel = talkModel
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        talkModel.didStartSpeech()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        talkModel.didStopSpeech()
    }
}
