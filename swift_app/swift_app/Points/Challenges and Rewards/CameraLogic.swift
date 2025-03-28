//
//  CameraLogic.swift
//  swift_app
//
//  Created by Paulina Arrazola on 26/03/25.
//

import Foundation
import UIKit

class OpenAIService {
    private let apiKey: String
    
    init() {
        // Retrieve API key from Info.plist using the original key name
        guard let key = Bundle.main.infoDictionary?["KEY_ECOSPHERE"] as? String else {
            fatalError("OpenAI API Key not found in Info.plist")
        }
        self.apiKey = key
    }
    
    func analyzeImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Ensure the image can be converted to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversionError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        // Base64 encode the image
        let base64Image = imageData.base64EncodedString()
        
        // Prepare the API request
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
        
        // Prepare the request body
        let body: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Carefully examine the image and describe what you see in detail."],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 300
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        // Perform the network request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Error handling
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                // If response is not successful, create a specific error
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "APIError",
                                            code: statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid response from server (Status Code: \(statusCode))"])))
                return
            }
            
            // Parse the response
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError",
                                            code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                // Print raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(responseString)")
                }
                
                // Parse JSON response
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
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
    
    private let openAIService: OpenAIService
    
    init() {
        self.openAIService = OpenAIService()
    }
    
    func analyzeImage() {
        guard let image = capturedImage else {
            errorMessage = "No image captured"
            return
        }
        
        isAnalyzing = true
        errorMessage = nil
        
        openAIService.analyzeImage(image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                
                switch result {
                case .success(let analysis):
                    self?.analysisResult = analysis
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Image Analysis Error: \(error)")
                }
            }
        }
    }
}
