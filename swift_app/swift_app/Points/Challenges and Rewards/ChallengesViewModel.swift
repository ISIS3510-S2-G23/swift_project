import Foundation
import Firebase
import Network

class ChallengesViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []

    private let networkMonitor = NWPathMonitor()
    @Published private(set) var isConnected = true
    private var userId: String = "userAdmin"
    private var userChallenges: [UserChallenge] = []

    private static let cache = NSCache<NSString, NSData>()
    private let cacheKey = "cachedChallenges"
    
    init() {
        setupNetworkMonitoring()
        
        // Try to load challenges from cache first
        if let cached = loadFromCache() {
            self.challenges = cached
            print("Loaded \(cached.count) challenges from cache")
        }
        
        // If we're online, fetch fresh data
        if isConnected {
            fetchUserChallenges { [weak self] in
                self?.fetchChallenges()
            }
        } else {
            print("Offline mode: Using challenges that are not completed yet only")
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                self?.isConnected = (path.status == .satisfied)
                if !wasConnected && self?.isConnected == true {
                    print("Network reconnected, refreshing data...")
                    self?.fetchUserChallenges {
                        self?.fetchChallenges()
                    }
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
    
    private func fetchUserChallenges(completion: @escaping () -> Void) {
        guard isConnected else { completion(); return }
        let db = Firestore.firestore()
        db.collection("users-challenges").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user challenges: \(error)")
                completion()
                return
            }
            self.userChallenges = snapshot?.documents.compactMap { doc in
                guard doc.documentID.contains(self.userId),
                      let prog = doc.data()["progress"] as? Double,
                      let done = doc.data()["completed"] as? Bool
                else { return nil }
                return UserChallenge(
                    complete_id: doc.documentID,
                    progress: prog * 100,
                    isCompleted: done
                )
            } ?? []
            print("Updated userChallenges: \(self.userChallenges.count)")
            completion()
        }
    }
    
    private func fetchChallenges() {
        guard isConnected else { return }
        let db = Firestore.firestore()
        db.collection("challenges").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching challenges: \(error)")
                return
            }
            let fetched: [Challenge] = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let expTs = data["expiration"] as? Timestamp,
                      let reward = data["reward"] as? String,
                      let desc  = data["description"] as? String,
                      let uc    = self.userChallenges.first(where: { $0.complete_id.starts(with: doc.documentID) })
                else {
                    print("No matching userChallenge for \(doc.documentID)")
                    return nil
                }
                return Challenge(
                    title: title,
                    expirationDate: expTs.dateValue(),
                    reward: reward,
                    description: desc,
                    complete_id: uc.complete_id,
                    completionPercentage: Int(uc.progress),
                    isCompleted: uc.isCompleted
                )
            } ?? []
            
            DispatchQueue.main.async {
                self.challenges = fetched
                let incomplete = fetched.filter { !$0.isCompleted }
                self.saveToCache(incomplete)
                print("Saved \(incomplete.count) challenges to cache")
            }
        }
    }
    
    private func saveToCache(_ challenges: [Challenge]) {
        do {
            let data = try JSONEncoder().encode(challenges)
            ChallengesViewModel.cache.setObject(data as NSData, forKey: cacheKey as NSString)
        } catch {
            print("Failed to encode challenges for cache: \(error)")
        }
    }
    
    private func loadFromCache() -> [Challenge]? {
        guard let data = ChallengesViewModel.cache.object(forKey: cacheKey as NSString) as Data? else {
            return nil
        }
        do {
            return try JSONDecoder().decode([Challenge].self, from: data)
        } catch {
            print("Failed to decode challenges from cache: \(error)")
            return nil
        }
    }
    
    func clearCache() {
        ChallengesViewModel.cache.removeObject(forKey: cacheKey as NSString)
    }

    
    func updateProgressChallenge(pChallenge: Challenge, newProgress: Int) {
        print("UPDATE PROGRESS CHALLENGE WAS JUST CLICKED")
        guard isConnected else {
            print("Cannot update challenge without internet connection")
            return
        }
        let db = Firestore.firestore()
        let complete_id = pChallenge.complete_id
        let newComplete = newProgress >= 100
        let newProgDec = Double(newProgress) / 100.0
        
        db.collection("users-challenges").document(complete_id)
            .updateData([
                "progress": newProgDec,
                "completed": newComplete
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating challenge \(complete_id): \(error)")
                    return
                }
                print("Successfully updated challenge \(complete_id)")
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    var updated = self.challenges
                    if let idx = updated.firstIndex(where: { $0.complete_id == complete_id }) {
                        let old = updated[idx]
                        updated[idx] = Challenge(
                            title: old.title,
                            expirationDate: old.expirationDate,
                            reward: old.reward,
                            description: old.description,
                            complete_id: old.complete_id,
                            completionPercentage: newProgress,
                            isCompleted: newComplete
                        )
                        self.challenges = updated
                        let incomplete = updated.filter { !$0.isCompleted }
                        self.saveToCache(incomplete)
                    }
                }
            }
    }
}
