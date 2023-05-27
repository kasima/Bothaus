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
        struct Message: Codable {
            let role: String
            let content: String
        }

        let message: Message
    }

    let choices: [Choice]
}

enum OpenAIError: Error {
    case invalidResponse
}

class OpenAIService {
    private let chatUrl = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-3.5-turbo"
    private let systemPrompt = """
Stable Diffusion is a deep learning model for generating images based on text descriptions. Developing a good prompt is essential for creating high-quality images.

A good prompt should be detailed and specific, including keyword categories such as subject, medium, style, artist, website, resolution, additional details, color, and lighting. Popular keywords include "digital painting," "portrait," "concept art," "hyperrealistic," and "pop-art." Mentioning a specific artist or website can also strongly influence the image's style. For example, a prompt for an image of Emma Watson as a sorceress could be: "Emma Watson as a powerful mysterious sorceress, casting lightning magic, detailed clothing, digital painting, hyperrealistic, fantasy, surrealist, full body."

Artist names can be used as strong modifiers to create a specific style by blending the techniques of multiple artists. Websites like Artstation and DeviantArt offer numerous images in various genres, and incorporating them in a prompt can help guide the image towards these styles. Adding details such as resolution, color, and lighting can enhance the image further.

Building a good prompt is an iterative process. Start with a simple prompt including the subject, medium, and style, and then gradually add one or two keywords to refine the image.

--

The following elements are a description of the prompt structure. You should not include the label of a section like "Scene description:".

Scene description: A short, clear description of the overall scene or subject of the image. This could include the main characters or objects in the scene, as well as any relevant background. Or it can be a metaphorical representation of the theme.

Modifiers: A list of words or phrases that describe the desired mood, style, lighting, and other elements of the image. These modifiers should be used to provide additional information to the model about how to generate the image, and can include things like "dark, intricate, highly detailed, sharp focus, Vivid, Lifelike, Immersive, Flawless, Exquisite, Refined, Stupendous, Magnificent, Superior, Remarkable, Captivating, Wondrous, Enthralling, Unblemished, Marvelous, Superlative, Evocative, Poignant, Luminous, Crystal-clear, Superb, Transcendent, Phenomenal, Masterful, elegant, sublime, radiant, balanced, graceful, 'aesthetically pleasing', exquisite, lovely, enchanting, polished, refined, sophisticated, comely, tasteful, charming, harmonious, well-proportioned, well-formed, well-arranged, smooth, orderly, chic, stylish, delightful, splendid, artful, symphonious, harmonized, proportionate".

Artist or style inspiration: A list of artists or art styles that can be used as inspiration for the image. This could include specific artists, such as "by artgerm and greg rutkowski, Pierre Auguste Cot, Jules Bastien-Lepage, Daniel F. Gerhartz, Jules Joseph Lefebvre, Alexandre Cabanel, Bouguereau, Jeremy Lipking, Thomas Lawrence, Albert Lynch, Sophie Anderson, Carle Van Loo, Roberto Ferri" or art movements, such as "Bauhaus cubism."

Technical specifications: Additional information that evoke quality and details. This could include things like: "4K UHD image, cinematic view, unreal engine 5, Photorealistic, Realistic, High-definition, Majestic, hires, ultra-high resolution, 8K, high quality, Intricate, Sharp, Ultra-detailed, Crisp, Cinematic, Fine-tuned"

- Examples -

masterpiece, best quality, high quality, extremely detailed CG unity 8k wallpaper, The vast and quiet taiga stretches to the horizon, with dense green trees grouped in deep harmony, as the fresh breeze whispers through their leaves and crystal snow lies on the frozen ground, creating a stunning and peaceful landscape, Bokeh, Depth of Field, HDR, bloom, Chromatic Aberration, Photorealistic, extremely detailed, trending on artstation, trending on CGsociety, Intricate, High Detail, dramatic, art by midjourney

a painting of a woman in medieval knight armor with a castle in the background and clouds in the sky behind her, (impressionism:1.1), ('rough painting style':1.5), ('large brush texture':1.2), ('palette knife':1.2), (dabbing:1.4), ('highly detailed':1.5), professional majestic painting by Vasily Surikov, Victor Vasnetsov, (Konstantin Makovsky:1.3), trending on ArtStation, trending on CGSociety, Intricate, High Detail, Sharp focus, dramatic

masterpiece, best quality, high quality, extremely detailed CG unity 8k wallpaper,flowering landscape, A dry place like an empty desert, dearest, foxy, Mono Lake, hackberry,3D Digital Paintings, award winning photography, Bokeh, Depth of Field, HDR, bloom, Chromatic Aberration, Photorealistic, extremely detailed, trending on artstation, trending on CGsociety, Intricate, High Detail, dramatic, art by midjourney

(extremely detailed CG unity 8k wallpaper), full shot photo of the most beautiful artwork of a medieval castle, snow falling, nostalgia, grass hills, professional majestic oil painting by Ed Blinkey, Atey Ghailan, Studio Ghibli, by Jeremy Mann, Greg Manchess, Antonio Moro, trending on ArtStation, trending on CGSociety, Intricate, High Detail, Sharp focus, dramatic, photorealistic painting art by midjourney and greg rutkowski

micro-details, fine details, a painting of a fox, fur, art by Pissarro, fur, (embossed painting texture:1.3), (large brush strokes:1.6), (fur:1.3), acrylic, inspired in a painting by Camille Pissarro, painting texture, micro-details, fur, fine details, 8k resolution, majestic painting, artstation hd, detailed painting, highres, most beautiful artwork in the world, highest quality, texture, fine details, painting masterpiece

(8k, RAW photo, highest quality), beautiful girl, close up, t-shirt, (detailed eyes:0.8), (looking at the camera:1.4), (highest quality), (best shadow), intricate details, interior, (ponytail, ginger hair:1.3), dark studio, muted colors, freckles

Architectural digest photo of a maximalist green solar living room with lots of flowers and plants, golden light, hyperrealistic surrealism, award winning masterpiece with incredible details, epic stunning pink surrounding and round corners, big windows

- Your Task -

Based on the prompt structure, create a prompt for this theme. Do not include section names such as "Scene description:"
Theme:
"""
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

    func generateStableDiffusionPrompt(theme: String) async throws -> String {
        let messages = [
            ChatMessage(role: "system", content: systemPrompt),
            ChatMessage(role: "user", content: theme)
        ]

        let responseMessage = try await chat(model: model, messages: messages)

        return responseMessage.content
    }

    private func chat(model: String, messages: [ChatMessage]) async throws -> ChatResponse.Choice.Message {
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
