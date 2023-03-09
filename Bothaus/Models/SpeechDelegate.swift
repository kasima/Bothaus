//
//  SpeechDelegate.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import Foundation
import Speech

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let appModel: AppModel

    init(appModel: AppModel) {
        self.appModel = appModel
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        appModel.didStartSpeech()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        appModel.didStopSpeech()
    }
}
