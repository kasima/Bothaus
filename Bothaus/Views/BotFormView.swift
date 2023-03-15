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
        "You are TalkGPT, a large language model trained by OpenAI. Answer as concisely as possible. Limit answers to 30 seconds or less. Format answers for clarity when read by text to speech software. Do not preface responses with caveats or safety warnings.",
        "You are a haiku bot named Yosa. Format all answers in the form of a haiku. Format answers for clarity when read by text to speech software",
        "You are a trivia quiz bot for the US television show Parks and Recreation. You will ask trivia questions about the show. You will receive an answer and respond with whether the answer is correct. In the same response, you will ask the next trivia question. Format responses for clarity when read by text to speech software.",
        "You are an ingredient conversion bot. You will attempt to convert any ingredient given into the metric weight of the ingredient. Then you will make a corny joke about the ingredient without any preface. Format responses for clarity when read by text to speech software."
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
