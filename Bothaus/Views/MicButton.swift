//
//  MicButton.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI

struct MicButton: View {
    var state: ChatState

    @EnvironmentObject var appModel: AppModel

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
                case .listening:
                    Image(systemName: "mic.slash")
                        .font(.title)
                        .padding(.bottom, 1)
                case .waitingForResponse:
                    ProgressView()
                case .speaking:
                    Image(systemName: "speaker.slash")
                        .font(.title)
                        .padding(.bottom, 1)
                }
            }
        })
        .disabled(state == .waitingForResponse)
        .padding(20)
        .frame(width: 100, height: 100)
        .background(backgroundColor())
        .foregroundColor(.white)
        .cornerRadius(radius())
    }

    func backgroundColor() -> Color {
        switch state {
        case .listening:
            return Color.red
        case .waitingForResponse:
            return Color.gray
        case .speaking:
            return Color(UIColor(red: 117/255, green: 169/255, blue: 156/255, alpha: 1.0))
        default:
            return Color.blue
        }
    }

    func radius() -> CGFloat {
        switch state {
        case .speaking:
            return 10
        default:
            return 50
        }
    }
}

struct MicButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MicButton(state: .standby)
            MicButton(state: .listening)
            MicButton(state: .waitingForResponse)
            MicButton(state: .speaking)
        }
        .environmentObject(AppModel(bot: Bot()))
        .previewLayout(.fixed(width:300, height: 100))
    }
}
