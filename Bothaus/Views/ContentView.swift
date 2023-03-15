//
//  ContentView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI
import OpenAIKit

struct ContentView: View {
    var body: some View {
        TalkInterface()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppModel())
    }
}
