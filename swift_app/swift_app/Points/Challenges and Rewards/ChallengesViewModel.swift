import Foundation
import Firebase

class ChallengesViewModel: ObservableObject {
    @Published var challenges: [Challenge] = [
        Challenge(title: "Challenge 1 - go to 3 recycle points", completionPercentage: 100, isCompleted: true, expirationDate: "Feb 12", reward: "X", description: "Bottle"),
        Challenge(title: "Challenge 2 - recycle 6 plastic bottles in ECO", completionPercentage: 50, isCompleted: false, expirationDate: "Dec 25", reward: "X", description: "Bottle"),
        Challenge(title: "Challenge 3 - visit Propelplast S.A.S.", completionPercentage: 0, isCompleted: false, expirationDate: "Jun 23", reward: "X", description: "Bottle")
    ]
    
    private var userId: String = "userAdmin"
    private var userChallenges: [UserChallenge] = []
    
    init() {
        fetchChallenges()
        fetchUserChallenges()
    }

    func fetchChallenges() {
        let db = Firestore.firestore()
        
        db.collection("challenges").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching challenges: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let documentID = document.documentID
                    let data = document.data()
                    print("Document ID: \(documentID)")
                    print("Data: \(data)\n")
                }
            }
        }
    }
    
    func fetchUserChallenges() {
        let db = Firestore.firestore()
        
        db.collection("users-challenges").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user challenges: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                var filteredChallenges: [UserChallenge] = []
                
                for document in snapshot.documents {
                    let documentID = document.documentID
                    let data = document.data()
                    
                    if documentID.contains(self.userId) {
                        if let progress = data["progress"] as? Double,
                           let isCompleted = data["completed"] as? Bool {
                            
                            let userChallenge = UserChallenge(
                                complete_id: documentID,
                                progress: progress * 100,
                                isCompleted: isCompleted
                            )
                            
                            filteredChallenges.append(userChallenge)
                        }
                    }
                }
                
                self.userChallenges = filteredChallenges
                print("Filtered user challenges: \(self.userChallenges)")
            }
        }
    }
}
