//
//  AddBotView.swift
//  Bothaus
//
//  Created by kasima on 3/15/23.
//

import SwiftUI
import CoreData

struct AddBotView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var name = ""
    @State private var systemPrompt = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bot Information")) {
                    TextField("Name", text: $name)
                }
                Section(header: Text("What kind of bot is it?")) {
                    TextEditor(text: $systemPrompt)
                }
            }
            .navigationBarTitle("Add Bot", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                trailing:
                    Button("Save") {
                        addBot()
                    }.disabled(name.isEmpty || systemPrompt.isEmpty)
            )
        }
    }

    private func addBot() {
        let newBot = Bot(context: viewContext)
        // newBot.id = UUID()
        newBot.name = name
        newBot.systemPrompt = systemPrompt

        do {
            try viewContext.save()
        } catch {
            print("Error saving bot: \(error)")
        }

        presentationMode.wrappedValue.dismiss()
    }
}

struct AddBotView_Previews: PreviewProvider {
    static var previews: some View {
        AddBotView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
