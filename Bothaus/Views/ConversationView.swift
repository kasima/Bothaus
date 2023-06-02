//
//  ConversationView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var chatModel: ChatModel

    var systemPrompt: String
    var messages: [Message]
    @Binding var scrollToBottom: Bool

    init(systemPrompt: String, messages: [Message], scrollToBottom: Binding<Bool> = .constant(false)) {
        self.systemPrompt = systemPrompt
        self.messages = messages
        self._scrollToBottom = scrollToBottom
        UITableView.appearance().separatorStyle = .none
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Text(systemPrompt)
                        .font(.footnote)
                        .padding()
                        .foregroundColor(Color(UIColor.systemGray))
                        .background(Color(UIColor.systemGray5))

                    ForEach(messages, id: \.id) { message in
                        MessageView(message: message)
                            .id(message.id)
                    }
                }
                .onChange(of: messages.count) { newCount in
                        // This closure holds the old state of messages, even though newCount is correct, so we need to go back to the model
                        // TODO - Make messages conform to Equatable so that onChange can be used with messages instead of messages.count
                    performScrollToBottom(proxy: proxy)
                }
                .onChange(of: scrollToBottom) { newValue in
                    if newValue == true {
                        scrollToBottom = false
                        performScrollToBottom(proxy: proxy)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func performScrollToBottom(proxy: ScrollViewProxy) {
        // Wait a moment for the keyboard to finish animating in so that the bottom is calculated correctly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation {
                proxy.scrollTo(chatModel.messages.last?.id, anchor: .bottom)
            }
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        let bot = Bot.talkGPT(context: PersistenceController.preview.container.viewContext)
        NavigationView {
            ConversationView(
                systemPrompt: bot.systemPrompt!,
                messages: [
                    Message(id: 1, role: "user", content: "Hey you"),
                    Message(id: 2, role: "assistant", content: "Who me?"),
                    Message(id: 3, role: "user", content: "Yeah you"),
                    Message(id: 4, role: "assistant", content: "Get into my car! Awwwwwwwww yeah. Get out of my dreams. Get into my car. Beep beep, yeah.")
                ]
            )
        }
        .environmentObject(ChatModel(bot: Bot()))
    }
}
