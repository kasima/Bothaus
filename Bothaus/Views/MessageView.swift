//
//  MessageView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI

struct MessageFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .cornerRadius(10)
    }
}

struct MessageView: View {
    @EnvironmentObject var chatModel: ChatModel
    @State var messageHeight = 0

    var message: Message

    var body: some View {
        if (message.role == "user") {
            HStack {
                Spacer()
                Text(message.content)
                    .textSelection(.enabled)
                    .modifier(MessageFormat())
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        } else {
            VStack {
                HStack {
                    Text(message.content)
                        .textSelection(.enabled)
                        .modifier(MessageFormat())
                        .foregroundColor(Color.white)
                        .background(Color(UIColor(red: 117/255, green: 169/255, blue: 156/255, alpha: 1.0)))
                        .cornerRadius(10)
                    Spacer()
                }

                HStack {
                    if (chatModel.chatState == .speaking && chatModel.speakingMessageId == message.id) {
                        Button(action: {
                            chatModel.stopSpeaking()
                        }, label: {
                            Image(systemName: "speaker.slash.fill")
                                .foregroundColor(.secondary)
                                .padding(.top, 0)
                        })
                    } else {
                        Button(action: {
                            chatModel.speakMessage(id: message.id)
                        }, label: {
                            Image(systemName: "waveform")
                                .foregroundColor(.secondary)
                                .padding(.top, 0)
                        })
                        .disabled(chatModel.chatState == .speaking)
                    }
                    Spacer()
                }
                .padding(.leading)

            }
            .padding()
        }

    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let chatModel = ChatModel(bot: Bot(), chatState: .standby)
        let speakingChatModel = ChatModel(bot: Bot(), chatState: .speaking, speakingMessageId: 2)

        Group {
            MessageView(message: Message(id: 1, role: "user", content: "Hey bot, tell me a nice little story."))
                .environmentObject(chatModel)

            MessageView(message: Message(id: 2, role: "assistant", content: "I told my wife she was drawing her eyebrows too high. She looked surprised."))
                .environmentObject(chatModel)

            MessageView(message: Message(id: 2, role: "assistant", content: "I told my wife she was drawing her eyebrows too high. She looked surprised."))
                .environmentObject(speakingChatModel)
        }
    }
}
