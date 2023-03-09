//
// AppModel.swift
// Bothaus
//
// Created by kasima on 3/5/23.
//

import Foundation
import SwiftUI
import Speech
import OpenAIKit


final class AppModel: ObservableObject, SpeechRecognizerDelegate {
    @Published var isRecording: Bool = false
    @Published var promptText: String = ""
    @Published var responseText: String = ""
    @Published var messages: [Chat.Message] = []
    @Published var systemMessage = "You are ChatGPT, a large language model trained by OpenAI. Answer as concisely as possible. Limit answers to 30 seconds or less. Format answers for clarity when read by text to speech software. Do not preface responses with caveats or safety warnings."

    private var speechRecognizer: SpeechRecognizer?
    private var openAIAPIClient: OpenAIAPIClient?
    private let textToSpeech: TextToSpeech
    
    init() {
        self.textToSpeech = TextToSpeech()
        setup()
    }

    func setup() {
        self.openAIAPIClient = setupOpenAIAPIClient()
        self.speechRecognizer = SpeechRecognizer(delegate: self)
    }

    func loaded() {
        textToSpeech.speak(text: "Loaded", voiceIdentifier: AVSpeechSynthesisVoiceIdentifierAlex)
    }

    func setupOpenAIAPIClient() -> OpenAIAPIClient {
        var apiKey = ""
        var organization = ""
        let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist")
        if let path = url?.path, let data = FileManager.default.contents(atPath: path) {
            do {
                let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
//                guard let secrets = plist as? [String: String] else {
//                    return
//                }
                let secrets = plist as? [String: String]
                apiKey = secrets!["openai-api-key"]!
                organization = secrets!["openai-organization"]!
            } catch {
                print("Error reading regions plist file: \(error)")
//                return
            }
        }
        return OpenAIAPIClient(apiKey: apiKey, organization: organization)
    }
    
    func voiceTest() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices where voice.language == "en-US" {
            print("\(voice.language) - \(voice.name) - \(voice.quality.rawValue) [\(voice.identifier)]")
            let phrase = "The voice you're now listening to is the one called \(voice.name)."
            textToSpeech.speak(text: phrase, voiceIdentifier: voice.identifier)
        }
    }
    
    func startRecording() {
        do {
            try speechRecognizer?.startRecording()
        } catch {
            print("startRecording error")
        }
    }
    
    func stopRecording() {
        speechRecognizer?.stopRecording()
    }
    
    func sendToChatGPTAPI() {
        buildMessageHistory()
        Task {
            do {
                let response = try await openAIAPIClient?.sendToChatGPTAPI(system: systemMessage, messages: messages)
                DispatchQueue.main.async {
                    self.responseText = response!
                    self.textToSpeech.speak(text: self.responseText,
                                            voiceIdentifier: AVSpeechSynthesisVoiceIdentifierAlex)
                }
            } catch {
                print("chatgpt error")
            }
        }
    }

    private func buildMessageHistory() {
        let newMessage = Chat.Message(role: "user", content: promptText)
        messages.append(newMessage)
    }

    // SpeechRecognizerDelegate

    func didStartRecording() {
        self.isRecording = true
    }

    func didStopRecording() {
        self.isRecording = false
    }

    func didReceiveTranscription(_ transcription: String, isFinal: Bool) {
        promptText = transcription
        if isFinal {
            sendToChatGPTAPI()
        }
    }

    func didFailWithError(_ error: Error) {
        print(">>> AppModel: \(error)")
//        speakError(error)
    }

    func speakError(_ error: Error) {
//        DispatchQueue.main.async {
//            var errorMessage = ""
//            if let error = error as? SpeechRecognizerError {
//                errorMessage += error.message
//            } else {
//                errorMessage += error.localizedDescription
//            }
//            self.promptText = "<< \(errorMessage) >>"
//        }
    }
}
