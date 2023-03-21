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

        // Enable migrations
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

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

        // NB - for testing
        // userDefaults.removeObject(forKey: "initialDataSeededForVoiceSelection")

        if !userDefaults.bool(forKey: "initialDataSeededForVoiceSelection") {
            // Seed your initial data here
            createSeedDataForVoiceSelection(context: context)

            // Mark that the initial data has been seeded
            userDefaults.set(true, forKey: "initialDataSeededForVoiceSelection")
            userDefaults.synchronize()
        }
    }

    private func createSeedData(context: NSManagedObjectContext) {
        var bot = Bot.talkGPT(context: context)
        bot = Bot.haikuBot(context: context)
        bot = Bot.triviaBot(context: context)
        bot = Bot.ingredientConverter(context: context)
        // This is annoying. Silencing warnings about an unused bot variable
        print("Bots created: \(bot)")

        // Save the context
        save(context)
    }

    private func createSeedDataForVoiceSelection(context: NSManagedObjectContext) {
        updateAllBots(attributeName: "voiceIdentifier", newValue: "com.apple.ttsbundle.siri_Nicky_en-US_compact", context: context)

        let bot = Bot.frenchTranslator(context: context)
        // This is annoying. Silencing warnings about an unused bot variable
        print("Bots created: \(bot)")

        // Save the context
        save(context)
    }

    func updateAllBots<T>(attributeName: String, newValue: T, context: NSManagedObjectContext) {
        guard let entityName = Bot.entity().name else { return }
        let request = NSBatchUpdateRequest(entityName: entityName)
        request.propertiesToUpdate = [attributeName: newValue]
        request.resultType = .updatedObjectsCountResultType

        do {
            let result = try context.execute(request) as? NSBatchUpdateResult
            if let count = result?.result as? Int {
                print("Updated \(count) rows.")
            }
        } catch {
            print("Error updating rows: \(error)")
        }
    }

    private func save(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
