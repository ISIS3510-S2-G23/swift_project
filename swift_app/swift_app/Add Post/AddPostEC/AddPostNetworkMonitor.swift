//
//  AddPostNetworkMonitor.swift
//  swift_app
//
//  Created by Paulina Arrazola on 9/05/25.
//

import Network
import Foundation

enum PostNetworkStatus {
    case connected
    case disconnected
}

final class AddPostNetworkMonitor {
    static let shared = AddPostNetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "AddPostNetworkMonitor")
    
    @Published private(set) var isConnected: Bool = true
    static var onConnectivityRestored: (() -> Void)?
    var status: PostNetworkStatus {
        return isConnected ? .connected : .disconnected
    }
    private init() {
        startMonitoring()
    }
    private func startMonitoring() {
        var wasConnected = true
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let isNowConnected = path.status == .satisfied
                if isNowConnected && !wasConnected {
                    AddPostNetworkMonitor.onConnectivityRestored?()
                }
                wasConnected = isNowConnected
                self.isConnected = isNowConnected
            }
        }
        monitor.start(queue: queue)
    }
    func stopMonitoring() {
        monitor.cancel()
    }
}
