import Foundation
import Firebase

class ChallengesViewModel: ObservableObject {
    //List of challenges. It is passed to Challenges and Rewards views
    @Published var challenges: [Challenge] = []
    
    //Variable that contains the user
    private var userId: String = "userAdmin"
    
    //List of userChallenges. It is used to create the user structure
    private var userChallenges: [UserChallenge] = []
    
    //Initation. First get all userChallenges and then use that when creating the Challenge structure
    init() {
        fetchUserChallenges { [weak self] in
            self?.fetchChallenges()
        }
    }
    
    //Function for getting user-challenges
    private func fetchUserChallenges(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users-challenges").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user challenges: \(error.localizedDescription)")
                completion()
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
                print("Updated userChallenges: \(self.userChallenges)")
                print("Finished fetching user challenges, now fetching challenges...")
                completion()
            }
        }
    }
    
    //Function for creating the Challenges
    // First it gets all challenges from the DB, but for UI we need the challenge data associated with the user
    // Once we get the raw challenge data, we find the respective user-challenge object to create a complete Challenge structure
    private func fetchChallenges() {
        let db = Firestore.firestore()
        db.collection("challenges").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching challenges: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                var fetchedChallenges: [Challenge] = []
                
                
                for document in snapshot.documents {
                    let documentID = document.documentID
                    let data = document.data()
                    
                    //Get the challenge data
                    if let title = data["title"] as? String,
                       let expirationTimestamp = data["expiration"] as? Timestamp,
                       let reward = data["reward"] as? String,
                       let description = data["description"] as? String,
                       
                        //Find the respective userChallenge to complete the Challenge structure
                       let userChallenge = self.userChallenges.first(where: { $0.complete_id.starts(with: documentID) }) {
                        
                        let expirationDate = expirationTimestamp.dateValue()
                        
                        let challenge = Challenge(
                            title: title,
                            expirationDate: expirationDate,
                            reward: reward,
                            description: description,
                            complete_id: userChallenge.complete_id,
                            completionPercentage: Int(userChallenge.progress),
                            isCompleted: userChallenge.isCompleted
                        )
                        
                        fetchedChallenges.append(challenge)
                    } else {
                        print("No matching userChallenge found for \(documentID)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.challenges = fetchedChallenges
                    print("Complete challenges: \(self.challenges)")
                }
            }
        }
    }
    
    //Function for updating a single challenge's progress. It will be called from the RegisterPopUpView "Register" button
    func updateProgressChallenge(pChallenge: Challenge, newProgress: Int) {
        
        
        //CODIGO PARA CUANDO TENGAMOS LAS COSAS FUNCIONALES
        //let db = Firestore.firestore()
        //let complete_id = pChallenge.complete_id
        //let newComplete = newProgress == 100 ? 1 : 0
        
        //let documentRef = db.collection("users-challenges").document(complete_id)
        
        //documentRef.updateData([
        //    "progress": newProgress,
        //    "completed": newComplete
        //]) { error in
        //    if let error = error {
        //        print("Error updating challenge \(complete_id): \(error.localizedDescription)")
        //    } else {
        //        print("Successfully updated challenge \(complete_id)")
        
    }
}

