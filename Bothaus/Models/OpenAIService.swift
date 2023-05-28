//
//  OpenAIService.swift
//  DreamsAI21
//
//  Created by kasima on 5/26/23.
//

import Alamofire
import Foundation

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
}

struct ChatResponse: Codable {
    struct Choice: Codable {
        let message: ChatMessage
    }

    let choices: [Choice]
}

enum OpenAIError: Error {
    case invalidResponse
}

class OpenAIService {
    private let testing = true
    private let chatUrl = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-3.5-turbo"
    private var apiKey: String = ""

    init() {
        (apiKey, _) = OpenAIService.loadAPIKeys()
    }

    /**
     This function returns a tuple of OpenAI keys.

     - Returns: (API_key, organization)
     */
    static func loadAPIKeys() -> (String, String) {
        var apiKey = ""
        var organization = ""
        if let secrets = SecretsHelper.load() {
            apiKey = secrets["openai-api-key"]!
            organization = secrets["openai-organization"]!
        }
        return (apiKey, organization)
    }

    func generateNextAssistantMessage(system: String, messages: [ChatMessage]) async throws -> ChatMessage {
        if testing {
            sleep(10)
            let testResponses = [
                "This is test one. What do you call an alligator in a vest? An investigator.",
                "This is test two. I told my wife she was drawing her eyebrows too high. She looked surprised.",
                "This is test three. Why did the scarecrow win an award? Because he was outstanding in his field."
            ]
            let randomIndex = Int(arc4random_uniform(UInt32(testResponses.count)))
            return ChatMessage(role:"assistant", content: testResponses[randomIndex])
        } else {
            let systemMessage = ChatMessage(role: "system", content: system)
            let fullMessages = [systemMessage] + messages
            debugPrint("Full messages: ", fullMessages)
            return try await chat(model: model, messages: fullMessages)
        }
    }

    private func chat(model: String, messages: [ChatMessage]) async throws -> ChatMessage {
        let parameters = ChatRequest(model: model, messages: messages)
        let request = AF.request(chatUrl, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers())
        let response = await request.serializingDecodable(ChatResponse.self).response

        guard let firstChoice = response.value?.choices.first else {
            // debugPrint("Error: ", response.value)
            throw OpenAIError.invalidResponse
        }
        return firstChoice.message
    }

    private func headers() -> HTTPHeaders {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
}
