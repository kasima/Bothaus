//
//  AddBotView.swift
//  Bothaus
//
//  Created by kasima on 3/15/23.
//

import SwiftUI
import CoreData
import Speech

struct BotFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    static let defaultVoiceIdentifier = AVSpeechSynthesisVoiceIdentifierAlex
    static let defaultLanguage = "en-US"
    static let defaultSystemPrompts = [
        Bot.talkGPTPrompt,
        Bot.haikuBotPrompt,
        Bot.triviaBotPrompt,
        Bot.ingredientConverterPrompt
    ]

    @State private var name: String = ""
    @State private var systemPrompt: String = ""
    // BCP 47 language code, e.g. "en-US"
    @State private var selectedLanguage: String = ""
    @State private var selectedVoiceIdentifier: String = ""

    let bot: Bot?

    private var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.language == selectedLanguage }
    }

    private var languages: [String] {
        Set(AVSpeechSynthesisVoice.speechVoices().map { $0.language }).sorted()
    }

    init(bot: Bot? = nil) {
        self.bot = bot
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)

                Section(header: Text("Speech Voice")) {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            let locale = Locale(identifier: language)
                            let languageName = locale.localizedString(forLanguageCode: locale.languageCode ?? "") ?? "Unknown"
                            let countryAbbreviation = locale.localizedString(forRegionCode: locale.regionCode ?? "") ?? ""
                            Text("\(languageName) (\(countryAbbreviation))")
                                .tag(language)
                        }
                    }
                    .onChange(of: selectedLanguage, perform: updateSelectedVoice)

                    Picker("Voice", selection: $selectedVoiceIdentifier) {
                        ForEach(availableVoices, id: \.identifier) { voice in
                            Text(voice.name)
                                .tag(voice.identifier)
                        }
                    }
                }

                Section(header: Text("What kind of bot is it?")) {
                    TextField(systemPromptFieldName(), text: $systemPrompt, axis: .vertical)
                        .lineLimit(5...40)
                }
            }
            .navigationBarTitle(bot == nil ? "Add Bot" : "Edit Bot", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button(bot == nil ? "Add" : "Save") {
                saveBot()
            })
            .onAppear{
                self.initializeVoiceToSystemLanguage()
                self.loadBotData()
            }
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


    private func initializeVoiceToSystemLanguage() {
        selectedLanguage = userLanguageCode
        if let voice = speechVoiceForLanguage(selectedLanguage) {
            print("Voice for system language: \(voice.name)")
            selectedVoiceIdentifier = voice.identifier
        } else {
            print("No voice found for the system language")
            selectedVoiceIdentifier = Self.defaultVoiceIdentifier
        }
    }

    private func speechVoiceForLanguage(_ languageCode: String) -> AVSpeechSynthesisVoice? {
        let preferredVoices: [String: [String]] = [
            "en-US": [
                "com.apple.voice.compact.en-US.Samantha",
                "com.apple.ttsbundle.siri_Nicky_en-US_compact"
            ]
        ]

        let availableVoices = AVSpeechSynthesisVoice.speechVoices()

        // Try to find the first available default voice for the language in the dictionary
        if let preferredVoicesForLanguage = preferredVoices[languageCode] {
            for voiceIdentifier in preferredVoicesForLanguage {
                if let voice = availableVoices.first(where: {
                    print($0.identifier)
                    return $0.identifier == voiceIdentifier
                }) {
                    return voice
                }
            }
        }

        // If there's no available default voice set for the language, return the first available voice for the language
        let voice = availableVoices.first(where: { $0.language == languageCode })
        return voice
    }

    private func updateSelectedVoice(_ language: String) {
        if let voice = speechVoiceForLanguage(language) {
            selectedVoiceIdentifier = voice.identifier
        }
    }

    private func systemPromptFieldName() -> String {
        if bot == nil {
            return Self.defaultSystemPrompts.randomElement()!
        } else {
            return "Describe the bot"
        }
    }

    private func loadBotData() {
        if let bot = bot {
            name = bot.name ?? ""
            systemPrompt = bot.systemPrompt ?? ""
            selectedVoiceIdentifier = bot.voiceIdentifier ?? Self.defaultVoiceIdentifier
            selectedLanguage = languageFor(selectedVoiceIdentifier) ?? Self.defaultLanguage
        }
    }

    private func languageFor(_ voiceIdentifier: String) -> String? {
        if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.identifier == selectedVoiceIdentifier }) {
            return voice.language
        }
        return nil
    }

    private func saveBot() {
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

        presentationMode.wrappedValue.dismiss()
    }
}

struct BotFormView_Previews: PreviewProvider {
    static var previews: some View {
        BotFormView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
