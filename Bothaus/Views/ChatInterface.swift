//
//  ChatInterface.swift
//  Bothaus
//
//  Created by kasima on 3/14/23.
//

import SwiftUI

struct ChatInterface: View {
    @ObservedObject var bot: Bot

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @StateObject var chatModel: ChatModel
    @State private var showEditBotView = false
    @AppStorage("keyboardEntry") private var keyboardEntry: Bool = false
    @State private var scrollToBottom: Bool = false

    init(bot: Bot, chatModel: ChatModel? = nil) {
        self.bot = bot
        // if a chatModel is passed in, just take it, rather than instantiate
        if let chatModel = chatModel {
            self._chatModel = StateObject(wrappedValue: chatModel)
        } else {
            self._chatModel = StateObject(wrappedValue: ChatModel(bot: bot))
        }
    }

    var body: some View {

        VStack {
            ZStack {
                ConversationView(
                    systemPrompt: bot.systemPrompt ?? "",
                    messages: chatModel.messages,
                    scrollToBottom: $scrollToBottom
                )

                // Speech recognition result overlay
                // NB - needs to be here because we want it in a ZStack with the conversation view
                VStack {
                    Spacer()
                    if (chatModel.chatState == .listening && chatModel.promptText != "" && !keyboardEntry) {
                        Text(chatModel.promptText)
                            .font(.title)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .foregroundColor(Color(UIColor.label))
                    }
                }
            }

            if keyboardEntry {
                KeyboardEntryView(keyboardEntry: $keyboardEntry)
            } else {
                SpeechEntryView(keyboardEntry: $keyboardEntry)
            }
        } // VStack

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
        .environmentObject(chatModel)
        .onAppear() {
            chatModel.loaded()
            // chatModel.voiceTest()
        }
        .onChange(of: keyboardEntry) { newValue in
            scrollToBottom = true
        }
    }
}

struct ChatInterface_Previews: PreviewProvider {
    static var previews: some View {
        let bot = Bot.talkGPT(context: PersistenceController.preview.container.viewContext)

        let chatModel = ChatModel(
            bot: bot,
            chatState: .listening,
            promptText: "Are you sentient?",
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
            ChatInterface(bot: bot, chatModel: chatModel)
        }
    }
}
