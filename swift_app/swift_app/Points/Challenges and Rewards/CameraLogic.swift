//
//  CameraLogic.swift
//  swift_app
//
//  Created by Paulina Arrazola on 26/03/25.
//

import SwiftUI
import UIKit

class OpenAIService {
    private let apiKey: String
    
    init() {
        // Retrieve API key from Info.plist
        guard let key = Bundle.main.infoDictionary?["KEY_ECOSPHERE"] as? String else {
            fatalError("OpenAI API Key not found in Info.plist")
        }
        self.apiKey = key
    }
    
    func analyzeImage(_ image: UIImage, challengeDescription: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversionError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(NSError(domain: "URLError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
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
                    "content": "You are an AI assistant that evaluates whether a submitted image correctly reflects a given challenge. Provide a short response: 'Yes' if it matches, 'No' if it does not, and a brief explanation if No."
                ],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Challenge description: \(challengeDescription). Does this image correctly reflect the challenge being completed?"],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 50
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(NSError(domain: "APIError",
                                            code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    completion(.success(content.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    completion(.failure(NSError(domain: "ParsingError",
                                                code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Could not parse API response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}

class CameraLogic: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var analysisResult: String?
    @Published var isAnalyzing: Bool = false
    @Published var errorMessage: String?

    private let openAIService = OpenAIService()

    func analyzeImage(challengeDescription: String) {
        guard let image = capturedImage else {
            errorMessage = "No image captured"
            return
        }

        isAnalyzing = true
        errorMessage = nil

        openAIService.analyzeImage(image, challengeDescription: challengeDescription) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAnalyzing = false

                switch result {
                case .success(let response):
                    // Directly use the response string (No need to join keywords)
                    self?.analysisResult = "Response: \(response)"
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Image Analysis Error: \(error)")
                }
            }
        }
    }
}


