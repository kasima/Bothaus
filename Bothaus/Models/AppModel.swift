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

enum ChatState {
    case standby
    case listening
    case waitingForResponse
    case speaking
}

final class AppModel: ObservableObject, SpeechRecognizerDelegate {
    private let voiceIdentifier = AVSpeechSynthesisVoiceIdentifierAlex

    @Published var chatState = ChatState.standby
    @Published var promptText: String = ""
    @Published var responseText: String = ""
    @Published var messages: [Chat.Message] = []
    @Published var systemMessage = "You are ChatGPT, a large language model trained by OpenAI. Answer as concisely as possible. Limit answers to 30 seconds or less. Format answers for clarity when read by text to speech software. Do not preface responses with caveats or safety warnings."

    private var speechRecognizer: SpeechRecognizer?
    private var openAIAPIClient: OpenAIAPIClient?
    private var speechDelegate: SpeechDelegate?
    private var textToSpeech: TextToSpeech?

    init(chatState: ChatState = .standby) {
        self.chatState = chatState
        setup()
    }

    func setup() {
        speechRecognizer = SpeechRecognizer(delegate: self)
        openAIAPIClient = setupOpenAIAPIClient()
        speechDelegate = SpeechDelegate(appModel: self)
        textToSpeech = TextToSpeech(delegate: speechDelegate!)
    }

    func loaded() {
        textToSpeech?.speak(text: "Loaded", voiceIdentifier: AVSpeechSynthesisVoiceIdentifierAlex)
    }

    func setupOpenAIAPIClient() -> OpenAIAPIClient? {
        var apiKey = ""
        var organization = ""
        let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist")
        if let path = url?.path, let data = FileManager.default.contents(atPath: path) {
            do {
                let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
                guard let secrets = plist as? [String: String] else {
                    return nil
                }
                apiKey = secrets["openai-api-key"]!
                organization = secrets["openai-organization"]!
            } catch {
                print("Error reading regions plist file: \(error)")
                return nil
            }
        }
        return OpenAIAPIClient(apiKey: apiKey, organization: organization)
    }
    
    func voiceTest() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices where voice.language == "en-US" {
            print("\(voice.language) - \(voice.name) - \(voice.quality.rawValue) [\(voice.identifier)]")
            let phrase = "The voice you're now listening to is the one called \(voice.name)."
            self.speak(text: phrase)
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

    // MARK: - SpeechRecognizerDelegate

    func didStartRecording() {
        self.chatState = .listening
    }

    func didStopRecording() {
        self.chatState = .waitingForResponse
    }

    func didReceiveTranscription(_ transcription: String, isFinal: Bool) {
        promptText = transcription
        if isFinal {
            sendToChatGPTAPI()
        }
    }

    func didFailWithError(_ error: Error) {
        print(">>> AppModel: \(error)")
        self.chatState = .standby
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


    // MARK: - ChatGPT Request

    private func buildMessageHistory() {
        let newMessage = Chat.Message(role: "user", content: promptText)
        messages.append(newMessage)
        print(messages)
    }

    func sendToChatGPTAPI() {
        DispatchQueue.main.async {
            self.chatState = .waitingForResponse
        }
        buildMessageHistory()
        Task {
            do {
                if let response = try await openAIAPIClient?.sendToChatGPTAPI(system: systemMessage, messages: messages) {
                    DispatchQueue.main.async {
                        self.messages.append(response)
                        self.responseText = response.content
                        self.speak(text: self.responseText)
                    }
                } else {
                    print("no response")
                    self.chatState = .standby
                }
            } catch {
                print("chatgpt error")
                self.chatState = .standby
            }
        }
    }

    // MARK: - Speech

    func speak(text: String) {
        self.textToSpeech?.speak(text: self.responseText, voiceIdentifier: voiceIdentifier)
    }

    func stopSpeaking() {
        self.textToSpeech?.stopSpeaking()
        chatState = .standby
    }

    func didStartSpeech() {
        self.chatState = .speaking
    }

    func didStopSpeech() {
        self.chatState = .standby
    }
}
