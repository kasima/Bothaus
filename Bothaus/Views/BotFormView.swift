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
    @Environment(\.presentationMode) private var presentationMode

    @StateObject var viewModel: BotFormViewModel

    init(bot: Bot? = nil, viewContext: NSManagedObjectContext) {
        self._viewModel = StateObject(wrappedValue: BotFormViewModel(bot: bot, context: viewContext))
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $viewModel.name)

                Section(header: Text("Speech Voice")) {
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.languages, id: \.self) { language in
                            let locale = Locale(identifier: language)
                            let languageName = locale.localizedString(forLanguageCode: locale.languageCode ?? "") ?? "Unknown"
                            let countryAbbreviation = locale.localizedString(forRegionCode: locale.regionCode ?? "") ?? ""
                            Text("\(languageName) (\(countryAbbreviation))")
                                .tag(language)
                        }
                    }
                    .onChange(of: viewModel.selectedLanguage, perform: viewModel.updateSelectedVoice)

                    Picker("Voice", selection: $viewModel.selectedVoiceIdentifier) {
                        ForEach(viewModel.availableVoices, id: \.identifier) { voice in
                            Text(voice.name)
                                .tag(voice.identifier)
                        }
                    }
                    .onChange(of: viewModel.selectedVoiceIdentifier, perform: viewModel.voiceDemo)
                }

                Section(header: Text("What kind of bot is it?")) {
                    TextField(viewModel.systemPromptFieldName(), text: $viewModel.systemPrompt, axis: .vertical)
                        .lineLimit(5...40)
                }
            }
            .navigationBarTitle(viewModel.bot == nil ? "Add Bot" : "Edit Bot", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button(viewModel.bot == nil ? "Add" : "Save") {
                viewModel.saveBot()
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                viewModel.initializeVoiceToSystemLanguage()
                viewModel.loadBotData()
            }
        }
    }
}

struct BotFormView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        BotFormView(viewContext: context)
    }
}
