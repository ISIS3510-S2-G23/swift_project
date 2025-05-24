//
//  CaptionGeneratorService.swift
//  swift_app
//
//  Created by Paulina Arrazola on 18/05/25.
//

import SwiftUI
import UIKit

class CaptionGeneratorService {
    private let apiKey: String
    
    init() {
        // Retrieve API key from Info.plist
        guard let key = Bundle.main.infoDictionary?["KEY_ECOSPHERE"] as? String else {
            fatalError("OpenAI API Key not found in Info.plist")
        }
        self.apiKey = key
    }
    
    func generateCaption(for image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CaptionError.imageConversionFailed
        }
        
        let base64Image = imageData.base64EncodedString()
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw CaptionError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that generates engaging social media captions for images. Create a short, catchy caption (1-2 sentences) that describes what you see in the image. Focus on making it suitable for a forum post about environmental topics, sustainability, upcycling, transport, or recycling. Don't use hashtags unless specifically relevant."
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Please generate a caption for this image that would be suitable for an environmental forum post."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 100
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CaptionError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw CaptionError.parsingFailed
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum CaptionError: LocalizedError {
    case imageConversionFailed
    case invalidURL
    case invalidResponse
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Could not convert image to data"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .parsingFailed:
            return "Could not parse API response"
        }
    }
}
