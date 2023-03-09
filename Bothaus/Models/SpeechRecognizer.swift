//
//  SpeechRecognizer.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import Foundation
import Speech
import AVFoundation

protocol SpeechRecognizerDelegate: AnyObject {
    func didStartRecording()
    func didStopRecording()
    func didReceiveTranscription(_ transcription: String, isFinal: Bool)
    func didFailWithError(_ error: Error)
}

class SpeechRecognizer {
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

    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest){
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

    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?

    private weak var delegate: SpeechRecognizerDelegate?

    init(delegate: SpeechRecognizerDelegate) {
        self.delegate = delegate
        self.recognizer = SFSpeechRecognizer()
        Task {
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
                printError(error)
            }
        }
    }

    func printError(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        print(">>> SpeachRecognizer: \(errorMessage) >>")
    }

    func startRecording() throws {
        delegate?.didStartRecording()

        // TODO – Does this need to be put into a background queue, like in the Swift tutorial?
        // https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text
        guard let recognizer = self.recognizer, recognizer.isAvailable else {
            printError(RecognizerError.recognizerIsUnavailable)
            return
        }

        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
        } catch {
            self.stopRecording()
            self.printError(error)
        }
    }

    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
//        let receivedFinalResult = result?.isFinal ?? false
//        let receivedError = error != nil
//
//        if receivedFinalResult || receivedError {
//            audioEngine?.stop()
//            audioEngine?.inputNode.removeTap(onBus: 0)
//        }
//
//        if let result = result {
//            self.delegate?.didReceiveTranscription(result.bestTranscription.formattedString, isFinal: result.isFinal)
//        }
        if let error = error {
            self.stopRecording()
            audioEngine?.inputNode.removeTap(onBus: 0)

            self.delegate?.didFailWithError(error)
        } else if let result = result {
            print("result: \(result.bestTranscription.formattedString) \(result.isFinal ? " FINAL" : "")")

            self.delegate?.didReceiveTranscription(result.bestTranscription.formattedString, isFinal: result.isFinal)
            if result.isFinal {
                self.stopRecording()
                audioEngine?.inputNode.removeTap(onBus: 0)
            }
        }
    }

    func stopRecording() {
        audioEngine?.stop()
        request?.endAudio()
        task?.finish()

        audioEngine = nil
        request = nil
        task = nil

        delegate?.didStopRecording()
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

