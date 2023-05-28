//
// ChatModel.swift
// Bothaus
//
// Created by kasima on 3/5/23.
//

import Foundation
import SwiftUI
import Speech

enum ChatState {
    case standby
    case listening
    case waitingForResponse
    case speaking
}

struct Message {
    public var id: Int
    public var role: String
    public var content: String
}

final class ChatModel: ObservableObject, SpeechRecognizerDelegate {
    private let maxConversationHistory = 10

    @Published var chatState = ChatState.standby
    @Published var promptText: String
    @Published var messages: [Message]
    @Published var responseText: String = ""

    // Standard voice assistant
    private let defaultSystemPrompt = "You are ChatGPT, a large language model trained by OpenAI. Answer as concisely as possible. Limit answers to 30 seconds or less. Format answers for clarity when read by text to speech software. Do not preface responses with caveats or safety warnings."
    private let voiceLanguage = "en-US"
    private let defaultVoiceIdentifier = AVSpeechSynthesisVoiceIdentifierAlex

    // French translator
    // @Published var defaultSystemPrompt = "You are Charles, an english to french translator. Make your answers as concise and possible. Do not make translations literal, use idiomatic French when applicable. Format reponses for clarity when read by text to speech software"
    // private let voiceLanguage = "fr-FR"
    // private let defaultVoiceIdentifier = "com.apple.voice.compact.fr-FR.Thomas"

    private var speechRecognizer: SpeechRecognizer?
    private var openAIService = OpenAIService()
    private var speechDelegate: SpeechDelegate?
    private var textToSpeech: TextToSpeech?
    private var bot: Bot?

    init(bot: Bot, chatState: ChatState = .standby, promptText: String = "", messages: [Message] = []) {
        self.bot = bot
        self.chatState = chatState
        self.promptText = promptText
        self.messages = messages
        setup()
    }

    func setup() {
        speechRecognizer = SpeechRecognizer(delegate: self)
        speechDelegate = SpeechDelegate(chatModel: self)
        textToSpeech = TextToSpeech(delegate: speechDelegate!)
    }

    func loaded() {
        // Say the bot name
        // textToSpeech?.speak(text: bot?.name ?? "", voiceIdentifier: bot?.voiceIdentifier ?? defaultVoiceIdentifier)
    }
    
    func voiceTest() {
        let allLanguages = true
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices where (allLanguages || voice.language == voiceLanguage) {
            print("\(voice.language) - \(voice.name) - \(voice.quality.rawValue) [\(voice.identifier)]")
            let phrase = "The voice you're now listening to is the one called \(voice.name)."
            textToSpeech?.speak(text: phrase, voiceIdentifier: voice.identifier)
        }
    }

    func clearMessages() {
        messages = []
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

    func generateChatResponse(from messageText: String) {
        promptText = messageText
        sendToChatGPTAPI()
    }


    //
    // MARK: - SpeechRecognizerDelegate
    //

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
        print (">>> didFailwithError: \(error)")
        self.chatState = .standby
    }


    //
    // MARK: - ChatGPT Request
    //

    func sendToChatGPTAPI() {
        DispatchQueue.main.async {
            self.chatState = .waitingForResponse
        }
        self.addUserMessage()
        Task {
            do {
                let response = try await openAIService.generateNextAssistantMessage(
                    system: bot?.systemPrompt ?? defaultSystemPrompt,
                    messages: recentMessages()
                )
                DispatchQueue.main.async {
                    self.addAssistantMessage(message: response)
                    self.responseText = response.content
                    print("chatGPT response: \(response.content)")

                    // Only speak if we're in keyboard entry mode
                    if UserDefaults.standard.bool(forKey: "keyboardEntry") {
                        self.chatState = .standby
                    } else {
                        // NB - needs to be sent to the main queue or the speech ends up one message behind :shrug:
                        self.speak(text: self.responseText)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("chatgpt error")
                    self.chatState = .standby
                }
            }
        }
    }

    private func addUserMessage() {
        let newMessage = Message(id: messages.count, role: "user", content: promptText)
        self.messages.append(newMessage)
        print(messages)

        // Clear the promptText once the message shows up in history
        promptText = ""
    }

    private func recentMessages() -> [ChatMessage] {
        // Gather only the most recent messages to send to the API for latency
        let recentMessages = Array(messages.suffix(self.maxConversationHistory))
        let chatMessages = recentMessages.map { message in
            return ChatMessage(role: message.role, content: message.content)
        }
        return chatMessages
    }

    private func addAssistantMessage(message: ChatMessage) {
        let newMessage = Message(id: messages.count, role: message.role, content: message.content)
        messages.append(newMessage)
    }


    //
    // MARK: - Speech
    //

    func speak(text: String) {
        guard text != "" else { return }
        self.textToSpeech?.speak(text: text, voiceIdentifier: bot?.voiceIdentifier ?? defaultVoiceIdentifier)
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
