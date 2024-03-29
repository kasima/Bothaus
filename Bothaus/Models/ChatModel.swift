//
// ChatModel.swift
// Bothaus
//
// Created by kasima on 3/5/23.
//

import Foundation
import SwiftUI
import Speech
import FirebaseAnalytics

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

final class ChatModel: NSObject, ObservableObject, SpeechRecognizerDelegate {
    private let maxConversationHistory = 10

    @Published var chatState = ChatState.standby

    /// Transcription results, both in-process and final
    @Published var promptText: String

    /// Conversation consisting of user and assistant messages
    @Published var messages: [Message]

    /// Indicates whether interface is in keyboard entry mode
    @Published var keyboardEntry: Bool = false

    /// Contents of keyboard entry TextField, used to pre-fill with voice transcription
    @Published var keyboardEntryText = ""

    /// The id of the Message that is currently being spoken by text to speech
    @Published var speakingMessageId: Int?


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

    init(bot: Bot,
         chatState: ChatState = .standby,
         keyboardEntryText: String = "",
         promptText: String = "",
         messages: [Message] = [],
         speakingMessageId: Int? = nil
    ) {
        self.bot = bot
        self.chatState = chatState
        self.promptText = promptText
        self.messages = messages
        self.speakingMessageId = speakingMessageId
        super.init()

        setup()

        // Add an observer to the keyboardEntry user default
        UserDefaults.standard.addObserver(self, forKeyPath: "keyboardEntry", options: [.initial, .new], context: nil)
        keyboardEntry = UserDefaults.standard.bool(forKey: "keyboardEntry")
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
        Analytics.logEvent("start_mic", parameters: nil)
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

    // Add a method to handle changes to the keyboardEntry user default
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "keyboardEntry" {
            keyboardEntry = UserDefaults.standard.bool(forKey: "keyboardEntry")

            // User is switching from voice to keyboard mid-transcription
            if (keyboardEntry && chatState == .listening) {
                stopRecording()
            }
        }
    }

    private func voiceToKeyboardEntry() {
        DispatchQueue.main.async {
            // Update textfield with what has been transcribed so far
            self.keyboardEntryText = self.promptText
            self.chatState = .standby
        }
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
            // assume that the user is switching from voice to keyboard
            if keyboardEntry {
                voiceToKeyboardEntry()
            } else {
                Analytics.logEvent("generate_from_speech", parameters: nil)
                sendToChatGPTAPI()
            }
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
                    let message = self.addAssistantMessage(message: response)
                    print("chatGPT response: \(response.content)")

                    // Only speak if we're in keyboard entry mode
                    if self.keyboardEntry {
                        self.chatState = .standby
                    } else {
                        // NB - needs to be sent to the main queue or the speech ends up one message behind :shrug:
                        self.speakMessage(id: message.id)
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

    @discardableResult
    private func addUserMessage() -> Message {
        let newMessage = Message(id: messages.count, role: "user", content: promptText)
        self.messages.append(newMessage)
        print(messages)

        // Clear the promptText once the message shows up in history
        promptText = ""

        return newMessage
    }

    private func recentMessages() -> [ChatMessage] {
        // Gather only the most recent messages to send to the API for latency
        let recentMessages = Array(messages.suffix(self.maxConversationHistory))
        let chatMessages = recentMessages.map { message in
            return ChatMessage(role: message.role, content: message.content)
        }
        return chatMessages
    }

    @discardableResult
    private func addAssistantMessage(message: ChatMessage) -> Message {
        let newMessage = Message(id: messages.count, role: message.role, content: message.content)
        messages.append(newMessage)
        return newMessage
    }


    //
    // MARK: - Speech
    //

    func speak(text: String) {
        guard text != "" else { return }
        self.textToSpeech?.speak(text: text, voiceIdentifier: bot?.voiceIdentifier ?? defaultVoiceIdentifier)
    }

    func speakMessage(id: Int) {
        if let message = messages.first(where: { $0.id == id }) {
            speakingMessageId = message.id
            speak(text: message.content)
        }
    }

    func speakLastMessage() {
        if let message = messages.last {
            speakMessage(id: message.id)
        }
    }

    func stopSpeaking() {
        Analytics.logEvent("stop_speaking", parameters: nil)
        self.textToSpeech?.stopSpeaking()
        chatState = .standby
    }

    func didStartSpeech() {
        self.chatState = .speaking
    }

    func didStopSpeech() {
        self.chatState = .standby
        self.speakingMessageId = nil
    }
}
