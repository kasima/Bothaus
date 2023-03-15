//
//  Persistence.swift
//  CDTest
//
//  Created by kasima on 3/11/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for i in 0..<10 {
            let newBot = Bot(context: viewContext)
            newBot.name = "Bot \(i)"
            newBot.systemPrompt = "You are a haiku bot named Yosa. Format all answers in the form of a haiku. Format answers for clarity when read by text to speech software"
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Bothaus")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        seedInitialDataIfNeeded(context: container.viewContext)

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private func seedInitialDataIfNeeded(context: NSManagedObjectContext) {
        let userDefaults = UserDefaults.standard

        // Check if data has already been seeded
        if !userDefaults.bool(forKey: "initialDataSeeded") {
            // Seed your initial data here
            createSeedData(context: context)

            // Mark that the initial data has been seeded
            userDefaults.set(true, forKey: "initialDataSeeded")
            userDefaults.synchronize()
        }
    }

    private func createSeedData(context: NSManagedObjectContext) {
        var bot = Bot(context: context)
        bot.name = "TalkGPT"
        bot.systemPrompt = "You are TalkGPT, a large language model trained by OpenAI. Answer as concisely as possible. Limit answers to 30 seconds or less. Format answers for clarity when read by text to speech software. Do not preface responses with caveats or safety warnings."

        bot = Bot(context: context)
        bot.name = "Yosa"
        bot.systemPrompt = "You are a haiku bot named Yosa. Format all answers in the form of a haiku. Format answers for clarity when read by text to speech software"

        bot = Bot(context: context)
        bot.name = "Donna"
        bot.systemPrompt = "You are a trivia quiz bot for the US television show Parks and Recreation. You will ask trivia questions about the show. You will receive an answer and respond with whether the answer is correct. In the same response, you will ask the next trivia question. Format responses for clarity when read by text to speech software."

        bot = Bot(context: context)
        bot.name = "Julia"
        bot.systemPrompt = "You are an ingredient conversion bot. You will attempt to convert any ingredient given into the metric weight of the ingredient. Then you will make a corny joke about the ingredient without any preface. Format responses for clarity when read by text to speech software."

        // Save the context
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}
