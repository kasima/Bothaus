//
//  BotFormViewModel.swift
//  Bothaus
//
//  Created by kasima on 3/21/23.
//

import Foundation
import SwiftUI
import CoreData
import Speech

class BotFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var systemPrompt: String = ""
    @Published var selectedLanguage: String = ""
    @Published var selectedVoiceIdentifier: String = ""
    @Published var firstView = true

    private var viewContext: NSManagedObjectContext
    private var textToSpeech: TextToSpeech?
    let bot: Bot?

    static let defaultVoiceIdentifier = AVSpeechSynthesisVoiceIdentifierAlex
    static let defaultLanguage = "en-US"
    static let defaultSystemPrompts = [
        Bot.talkGPTPrompt,
        Bot.haikuBotPrompt,
        Bot.triviaBotPrompt,
        Bot.ingredientConverterPrompt
    ]

    init(bot: Bot? = nil, context: NSManagedObjectContext) {
        self.viewContext = context
        self.textToSpeech = TextToSpeech()
        self.bot = bot
    }

    var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.language == selectedLanguage }
    }

    var languages: [String] {
        Set(AVSpeechSynthesisVoice.speechVoices().map { $0.language }).sorted()
    }

    func initializeVoiceToSystemLanguage() {
        guard bot == nil else { return }
        selectedLanguage = userLanguageCode
        if let voice = speechVoiceForLanguage(selectedLanguage) {
            print("Voice for system language: \(voice.name)")
            selectedVoiceIdentifier = voice.identifier
        } else {
            print("No voice found for the system language")
            selectedVoiceIdentifier = Self.defaultVoiceIdentifier
        }
    }

    func loadBotData() {
        if let bot = bot {
            print("Bot: \(bot)")
            name = bot.name ?? ""
            systemPrompt = bot.systemPrompt ?? ""
            // Need to set the selectedLanguage first or the form gets in a weird state from the onChange
            let voiceIdentifier = bot.voiceIdentifier ?? Self.defaultVoiceIdentifier
            selectedLanguage = languageFor(voiceIdentifier) ?? Self.defaultLanguage
            print("Loaded bot voice: \(voiceIdentifier), \(selectedLanguage)")
            selectedVoiceIdentifier = voiceIdentifier
        }
    }

    func saveBot() {
        let botToSave = bot ?? Bot(context: viewContext)
        botToSave.name = name
        botToSave.systemPrompt = systemPrompt
        botToSave.voiceIdentifier = selectedVoiceIdentifier
        print("Saved bot voice: \(selectedVoiceIdentifier)")

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private var userLanguageCode: String {
        let currentLocale = Locale.current

        if let languageCode = currentLocale.language.languageCode,
           let regionCode = currentLocale.language.region {
            let bcp47LanguageCode = "\(languageCode)-\(regionCode)"
            print("Current system language code (BCP 47 format with region): \(bcp47LanguageCode)")

            // Try to find the exact BCP 47 language code match
            if languages.contains(bcp47LanguageCode) {
                return bcp47LanguageCode
            }

            // Try to find the first matching language code (without region)
            if let matchingLanguage = languages.first(where: { $0.hasPrefix(languageCode.identifier) }) {
                return matchingLanguage
            }
        } else {
            print("Failed to retrieve language and region codes.")
        }

        return Self.defaultLanguage
    }

    private func speechVoiceForLanguage(_ languageCode: String) -> AVSpeechSynthesisVoice? {
        let preferredVoices: [String: [String]] = [
            "en-US": [
                "com.apple.voice.compact.en-US.Samantha",
                "com.apple.ttsbundle.siri_Nicky_en-US_compact"
            ]
        ]

        // If the selectedVoiceIdentifier matches the language code, don't update it. It was probably set
        //   properly somewhere else. Only trigger this if there's a mismatch.
        guard (languageCode != languageFor(selectedVoiceIdentifier)) else { return nil }

        let availableVoices = AVSpeechSynthesisVoice.speechVoices()

        // Try to find the first available default voice for the language in the dictionary
        if let preferredVoicesForLanguage = preferredVoices[languageCode] {
            for voiceIdentifier in preferredVoicesForLanguage {
                if let voice = availableVoices.first(where: { $0.identifier == voiceIdentifier }) {
                    return voice
                }
            }
        }

        // If there's no available default voice set for the language, return the first available voice for the language
        let voice = availableVoices.first(where: { $0.language == languageCode })
        return voice
    }

    private func languageFor(_ voiceIdentifier: String) -> String? {
        if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.identifier == voiceIdentifier }) {
            return voice.language
        }
        return nil
    }

    func updateSelectedVoice(_ language: String) {
        if let voice = speechVoiceForLanguage(language) {
            selectedVoiceIdentifier = voice.identifier
        }
    }

    func systemPromptFieldName() -> String {
        if bot == nil {
            return Self.defaultSystemPrompts.randomElement()!
        } else {
            return "Describe the bot"
        }
    }

    //
    // MARK: - Speech
    //

    func voiceDemo(_ voiceIdentifier: String) {
        // NB – onChange is triggered the first time the form loads, probbaly from updatedSelectedVoice(),
        //   but don't say anything because maybe the user setting other fields. Only demo the voice
        //   if the user is setting it.
        if self.firstView {
            self.firstView = false
        } else {
            var text = ""
            if name != "" {
                text = name
            } else {
                let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)
                text = voice?.name ?? "My voice"
            }
            self.textToSpeech?.speak(text: text, voiceIdentifier: voiceIdentifier)
        }
    }
}
