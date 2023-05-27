//
//  SpeechEntryView.swift
//  Bothaus
//
//  Created by kasima on 5/27/23.
//

import SwiftUI

struct SpeechEntryView: View {
    @EnvironmentObject var appModel: AppModel
    @Binding var keyboardEntry: Bool

    var body: some View {
        ZStack {
            HStack {
                Button("Clear") {
                    appModel.clearMessages()
                }
                .font(.title2)
                .padding()
                .frame(width: (UIScreen.main.bounds.width-100) / 2)

                Spacer()
            }

            MicButton(state: appModel.chatState)
                .padding()

            HStack {
                Spacer()

                Button(action: {
                    keyboardEntry = true
                }) {
                    Image(systemName: "keyboard.fill")
                        .font(.title)
                        .padding()
                        .frame(width: (UIScreen.main.bounds.width-100) / 2)
                }
            }
        }
        .background(Color(UIColor.systemGray6))

    }
}

struct SpeechEntryView_Previews: PreviewProvider {
    @State static var keyboardEntry: Bool = true

    static var previews: some View {
        SpeechEntryView(keyboardEntry: $keyboardEntry)
            .environmentObject(AppModel(bot: Bot()))
    }
}
