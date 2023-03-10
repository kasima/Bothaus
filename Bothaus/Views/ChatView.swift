//
//  ChatView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI
import OpenAIKit

struct ChatView: View {
    @EnvironmentObject var appModel: AppModel
    var messages: [Message]

    init(messages: [Message]) {
        self.messages = messages
        UITableView.appearance().separatorStyle = .none
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(messages, id: \.id) { message in
                        MessageView(message: message)
                            .id(message.id)
                    }
                }
                .onChange(of: messages.count) { newCount in
                    // print(">>> onChange detected, count: \(messages.count), \(messages.last?.id): \(messages.last?.content)")
                    // print(">>> onChange detected, newCount: \(newCount), \(appModel.messages.last?.id)")

                    // this closure holds the old state of messages, even though newCount is correct, so we need to go back to the model
                    // TODO - Make messages conform to Equatable so that onChange can be used with messages instead of messages.count
                    withAnimation {
                        proxy.scrollTo(appModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
        }

        Button("Add Message") {
            appModel.promptText = "New Message \(messages.count)"
            appModel.sendToChatGPTAPI()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(messages: [
            Message(id: 1, role: "user", content: "Hey you"),
            Message(id: 2, role: "assistant", content: "Who me?"),
            Message(id: 3, role: "user", content: "Yeah you"),
            Message(id: 4, role: "assistant", content: "Get into my car! Awwwwwwwww yeah. Get out of my dreams. Get into my car. Beep beep, yeah.")

        ])
    }
}
