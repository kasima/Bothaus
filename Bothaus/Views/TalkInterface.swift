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
        .navigationTitle(bot.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Edit") {
            showEditBotView = true
        })
        .sheet(isPresented: $showEditBotView) {
            BotFormView(bot: bot).environment(\.managedObjectContext, viewContext)
        }
        .environmentObject(talkModel)
        .onAppear() {
            talkModel.loaded()
            // talkModel.voiceTest()
        }
    }

    private func editBot() {
        
    }
}

struct TalkInterface_Previews: PreviewProvider {
    static var previews: some View {
        let talkModel = TalkModel(
            bot: Bot(),
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

        TalkInterface(bot: Bot(), talkModel: talkModel)
    }
}
