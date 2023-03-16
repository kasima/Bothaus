//
//  AddBotView.swift
//  Bothaus
//
//  Created by kasima on 3/15/23.
//

import SwiftUI
import CoreData

struct BotFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    let defaultSystemPrompts = [
        Bot.talkGPTPrompt,
        Bot.haikuBotPrompt,
        Bot.triviaBotPrompt,
        Bot.ingredientConverterPrompt
    ]

    @State private var name: String = ""
    @State private var systemPrompt: String = ""

    let bot: Bot?

    init(bot: Bot? = nil) {
        self.bot = bot
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
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
            .onAppear(perform: loadBotData)
        }
    }

    private func systemPromptFieldName() -> String {
        if bot == nil {
            return defaultSystemPrompts.randomElement()!
        } else {
            return "Describe the bot"
        }
    }

    private func loadBotData() {
        if let bot = bot {
            name = bot.name ?? ""
            systemPrompt = bot.systemPrompt ?? ""
        }
    }

    private func saveBot() {
        let botToSave = bot ?? Bot(context: viewContext)
        botToSave.name = name
        botToSave.systemPrompt = systemPrompt

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
