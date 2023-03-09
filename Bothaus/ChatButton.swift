//
//  ChatButton.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI

struct ChatButton: View {
    var state: ChatState
    var appModel: AppModel

    var body: some View {
        Button(action: {
            switch state {
            case .standby:
                appModel.startRecording()
            case .listening:
                appModel.stopRecording()
            case .waitingForResponse:
                print("Should be something else in here")
            case .speaking:
                appModel.stopSpeaking()
            }
        }, label: {
            VStack {
                switch state {
                case .standby:
                    Image(systemName: "mic")
                        .font(.title)
                        .padding(.bottom, 1)
                    Text("Start Listening")
                case .listening:
                    Image(systemName: "mic.slash")
                        .font(.title)
                        .padding(.bottom, 1)
                    Text("Stop Listening")
                case .waitingForResponse:
                    ProgressView()
                case .speaking:
                    Image(systemName: "speaker.slash")
                        .font(.title)
                        .padding(.bottom, 1)
                    Text("Stop Speaking")
                }
            }
        })
        .disabled(state == .waitingForResponse)
        .foregroundColor(.white)
        .padding()
        .background(backgroundColor())
        .cornerRadius(10)
    }

    func backgroundColor() -> Color {
        switch state {
        case .listening:
            return Color.red
        case .waitingForResponse:
            return Color.gray
        case .speaking:
            return Color.green
        default:
            return Color.blue
        }
    }
}

struct ChatButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatButton(state: .standby, appModel: AppModel())
                .previewLayout(.fixed(width:300, height: 100))
            ChatButton(state: .listening, appModel: AppModel())
                .previewLayout(.fixed(width:300, height: 100))
            ChatButton(state: .waitingForResponse, appModel: AppModel())
                .previewLayout(.fixed(width:300, height: 100))
            ChatButton(state: .speaking, appModel: AppModel())
                .previewLayout(.fixed(width:300, height: 100))
        }
    }
}
