    //
    //  AppModel.swift
    //  Bothaus
    //
    //  Created by kasima on 3/5/23.
    //

    import Foundation
    import Speech
    import AVFoundation
    import SwiftUI
    import OpenAIKit
    import AsyncHTTPClient

    final class AppModel: ObservableObject {
        enum RecognizerError: Error {
            case nilRecognizer
            case notAuthorizedToRecognize
            case notPermittedToRecord
            case recognizerIsUnavailable

            var message: String {
                switch self {
                case .nilRecognizer: return "Can't initialize speech recognizer"
                case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
                case .notPermittedToRecord: return "Not permitted to record audio"
                case .recognizerIsUnavailable: return "Recognizer is unavailable"
                }
            }
        }

        @Published var isRecording: Bool = false
        @Published var promptText: String = ""
        @Published var responseText: String = ""

        // OpenAPI keys
        var apiKey: String {
            ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!
        }
        var organization: String {
            ProcessInfo.processInfo.environment["OPENAI_ORGANIZATION"]!
        }

        var transcript: String = ""

        private var audioEngine: AVAudioEngine?
        private var request: SFSpeechAudioBufferRecognitionRequest?
        private var task: SFSpeechRecognitionTask?
        private let recognizer: SFSpeechRecognizer?
        private let openAIClient: OpenAIKit.Client?
        let speechSynthesizer = AVSpeechSynthesizer()

        init() {
            recognizer = SFSpeechRecognizer()

            // list all available voices
    //        let voices = AVSpeechSynthesisVoice.speechVoices()
    //        for voice in voices {
    //            print(voice.identifier)
    //        }

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
            let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
            let configuration = Configuration(apiKey: apiKey, organization: organization)
            openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)

            Task(priority: .background) {
                do {
                    guard recognizer != nil else {
                        throw RecognizerError.nilRecognizer
                    }
                    guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                        throw RecognizerError.notAuthorizedToRecognize
                    }
                    guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                        throw RecognizerError.notPermittedToRecord
                    }
                } catch {
                    speakError(error)
                }
            }
        }

        deinit {
            reset()
        }

        func voiceTest() {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("audioSession properties weren't set because of an error.")
            }


            let voices = AVSpeechSynthesisVoice.speechVoices()
            for voice in voices where voice.language == "en-US" {
                print("\(voice.language) - \(voice.name) - \(voice.quality.rawValue) [\(voice.identifier)]")
                let phrase = "The voice you're now listening to is the one called \(voice.name)."
                let utterance = AVSpeechUtterance(string: phrase)
                utterance.voice = voice
                speechSynthesizer.speak(utterance)
            }

            do {
                disableAVSession()
            }
        }

        func transcribe() {
            self.isRecording = true
    //        DispatchQueue(label: "Speech Recognizer Queue", qos: .background).async { [weak self] in
    //            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                guard let recognizer = self.recognizer, recognizer.isAvailable else {
                    self.speakError(RecognizerError.recognizerIsUnavailable)
                    return
                }

                do {
                    let (audioEngine, request) = try Self.prepareEngine()
                    self.audioEngine = audioEngine
                    self.request = request
                    self.task = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
                } catch {
                    self.reset()
                    self.speakError(error)
                }
    //        }
        }

        func stopTranscribing() {
            reset()
            self.isRecording = false
        }

        func reset() {
            request?.endAudio()
            task?.finish()
            audioEngine?.stop()

            audioEngine = nil
            request = nil
            task = nil
        }

        func startRecording() {
            transcribe()
        }

        func stopRecording() {
            stopTranscribing()
        }

        func sendToChatGPTAPI(_ prompt: String) async {
            // code to send prompt to ChatGPT API and retrieve response
            do {
                if let client = self.openAIClient {
    //                let augmentedPrompt = "\(prompt) and limit the response to 30 seconds"
                    let augmentedPrompt = prompt
                    let completion = try await client.chats.create(
                        model: Model.GPT3.gpt3_5Turbo,
                        messages: [
                            Chat.Message(role: "system", content: "You are ChatGPT, a large language model trained by OpenAI. Answer as concisely as possible. Limit answers to 30 seconds or less. Do not preface responses with caveats or safety warnings."),
                            Chat.Message(role: "user", content: augmentedPrompt)
                        ],
                        maxTokens: 512
                    )
                    print(completion)
                    DispatchQueue.main.async {
                        self.responseText = completion.choices[0].message.content
                        self.speakResponse(responseText: self.responseText)
                    }

                }
            //        } catch let error as APIErrorResponse {
            } catch {
                print("chatgpt error")
            }
        }

        func speakResponse(responseText: String) {
            print("speaking response: \(responseText)")
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("audioSession properties weren't set because of an error.")
            }

            let utterance = AVSpeechUtterance(string: responseText)
    //        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    //        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Nicky_en-US_compact")
            utterance.voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)



            self.speechSynthesizer.speak(utterance)

            do {
                disableAVSession()
            }
        }

        private func loadAPIKeys() -> (String, String) {
            var apiKey = ""
            var organization = ""
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist")
            if let path = url?.path, let data = FileManager.default.contents(atPath: path) {
                do {
                    let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
                    guard let secrets = plist as? [String: String] else {
                        return (apiKey, organization)
                    }
                    apiKey = secrets["openai-api-key"]!
                    organization = secrets["openai-organization"]!
                } catch {
                    print("Error reading regions plist file: \(error)")
                    return (apiKey, organization)
                }
            }

            return (apiKey, organization)
        }

        private func disableAVSession() {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("audioSession properties weren't disable.")
            }
        }

        private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
            let audioEngine = AVAudioEngine()

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true

            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                request.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()

            return (audioEngine, request)
        }

        private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
            print("result: \(result?.bestTranscription.formattedString ?? "nil") \((result?.isFinal ?? false) ? "FINAL" : "")")

            let receivedFinalResult = result?.isFinal ?? false
            let receivedError = error != nil

            if receivedFinalResult || receivedError {
                audioEngine?.stop()
                audioEngine?.inputNode.removeTap(onBus: 0)
            }

            if let result = result {
                self.speak(result.bestTranscription.formattedString, finalResult: result.isFinal)
            }
        }

        private func speak(_ message: String, finalResult: Bool) {
            DispatchQueue.main.async {
                if finalResult {
                    // Don't update promptText because it's blank when it's the final result. Speak the last state.
                    Task {
                        do {
                            await self.sendToChatGPTAPI(self.promptText)
                        }
                    }
                } else {
                    self.transcript = message
                    self.promptText = self.transcript
                }
            }
        }

        private func speakError(_ error: Error) {
            DispatchQueue.main.async {
                var errorMessage = ""
                if let error = error as? RecognizerError {
                    errorMessage += error.message
                } else {
                    errorMessage += error.localizedDescription
                }
                self.transcript = "<< \(errorMessage) >>"
                self.promptText = self.transcript
            }
        }
    }


    extension SFSpeechRecognizer {
        static func hasAuthorizationToRecognize() async -> Bool {
            await withCheckedContinuation { continuation in
                requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    extension AVAudioSession {
        func hasPermissionToRecord() async -> Bool {
            await withCheckedContinuation { continuation in
                requestRecordPermission { authorized in
                    continuation.resume(returning: authorized)
                }
            }
        }
    }
