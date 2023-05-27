//
//  TalkInterface.swift
//  Bothaus
//
//  Created by kasima on 3/14/23.
//

import SwiftUI

struct TalkInterface: View {
    @ObservedObject var bot: Bot

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @StateObject var appModel: AppModel
    @State private var showEditBotView = false

    init(bot: Bot, appModel: AppModel? = nil) {
        self.bot = bot
        // if a appModel is passed in, just take it, rather than instantiate
        if let appModel = appModel {
            self._appModel = StateObject(wrappedValue: appModel)
        } else {
            self._appModel = StateObject(wrappedValue: AppModel(bot: bot))
        }
    }

    var body: some View {
        VStack {
            ZStack {
                ConversationView(systemPrompt: bot.systemPrompt ?? "", messages: appModel.messages)

                if (appModel.chatState == .listening && appModel.promptText != "") {
                    VStack {
                        Spacer()
                        Text(appModel.promptText)
                            .font(.title)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .foregroundColor(Color(UIColor.label))
                    }
                }
            }

            ZStack {
                SpeechEntryView(state: appModel.chatState)
                    .padding()

                HStack {
                    Spacer()
                    Button("Clear") {
                        appModel.clearMessages()
                    }
                    .font(.title2)
                    .padding()
                    .frame(width: (UIScreen.main.bounds.width-100) / 2)
                }
            }
            .background(Color(UIColor.systemGray6))
        }
        .navigationBarTitle(bot.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditBotView = true
                }) {
                    Text("Edit")
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemGray6))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showEditBotView) {
            BotFormView(bot: bot, viewContext: viewContext)
        }
        .environmentObject(appModel)
        .onAppear() {
            appModel.loaded()
            // appModel.voiceTest()
        }
    }
}

struct TalkInterface_Previews: PreviewProvider {
    static var previews: some View {
        let bot = Bot.talkGPT(context: PersistenceController.preview.container.viewContext)

        let appModel = AppModel(
            bot: bot,
            chatState: .listening,
            promptText: bot.systemPrompt!,
            messages: [
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?"),
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?"),
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?"),
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?")
            ]
        )

        NavigationStack {
            TalkInterface(bot: bot, appModel: appModel)
        }
    }
}
