//
//  ContentView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bot.name, ascending: true)],
        animation: .default)
    private var bots: FetchedResults<Bot>

    @State private var showAddBotView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(bots) { bot in
                    NavigationLink {
                        TalkInterface(bot: bot)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(bot.name ?? "")
                                .font(.title2)
                            Text(bot.systemPrompt ?? "")
                                .lineLimit(2)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteBot)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddBotView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }            }
            .sheet(isPresented: $showAddBotView) {
                BotFormView().environment(\.managedObjectContext, viewContext)
            }
            .navigationTitle("🤖 Bothaus")
        }
    }

    private func deleteBot(offsets: IndexSet) {
        for index in offsets {
            let bot = bots[index]
            viewContext.delete(bot)
        }

        do {
            try viewContext.save()
        } catch {
            print("Error deleting bot: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
