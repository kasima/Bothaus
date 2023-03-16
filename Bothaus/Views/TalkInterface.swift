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

    @StateObject var talkModel: TalkModel
    @State private var showEditBotView = false

    init(bot: Bot, talkModel: TalkModel? = nil) {
        self.bot = bot
        // if a talkModel is passed in, just take it, rather than instantiate
        if let talkModel = talkModel {
            self._talkModel = StateObject(wrappedValue: talkModel)
        } else {
            self._talkModel = StateObject(wrappedValue: TalkModel(bot: bot))
        }
    }

    var body: some View {
        VStack {
            ZStack {
                ChatView(messages: talkModel.messages)

                if (talkModel.chatState == .listening && talkModel.promptText != "") {
                    VStack {
                        Spacer()
                        Text(talkModel.promptText)
                            .font(.title)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .foregroundColor(Color(UIColor.label))
                    }
                }
            }

            ZStack {
                ChatButton(state: talkModel.chatState)
                    .padding()

                HStack {
                    Spacer()
                    Button("Clear") {
                        talkModel.clearMessages()
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
                    Image(systemName: "info.circle")
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemGray6))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showEditBotView) {
            BotFormView(bot: bot).environment(\.managedObjectContext, viewContext)
        }
        .environmentObject(talkModel)
        .onAppear() {
            talkModel.loaded()
            // talkModel.voiceTest()
        }
    }
}

struct TalkInterface_Previews: PreviewProvider {
    static var previews: some View {
        let bot = Bot.talkGPT(context: PersistenceController.preview.container.viewContext)

        let talkModel = TalkModel(
            bot: bot,
            chatState: .listening,
            promptText: "This is the prompt",
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
            TalkInterface(bot: bot, talkModel: talkModel)
        }
    }
}
