import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge

    var body: some View {
        HStack {
            Image(challenge.isCompleted ? .completeChallenge : .incompleteChallenge )
                .resizable()
                .frame(width: 55, height: 55)
                .padding(.leading, 15)
            // Icon based on completion status
            //Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath.circle.fill")
               // .foregroundColor(challenge.isCompleted ? .green : .purple)
             //   .font(.system(size: 20))
              //  .padding(.leading, 10)

            VStack(alignment: .leading, spacing: 5) {
                Text(challenge.title)
                    .font(.footnote)
                    .foregroundColor(.ecoMainPurple)

                HStack{
                    Text("\(challenge.completionPercentage)% completed")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 17)
                    Spacer()
                    if !challenge.isCompleted {
                        Button(action: {
                            // Action for registering visit
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                Text("Register visit")
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.ecoMainPurple)
                            .cornerRadius(10)
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                    }
                }
            }
            .padding(.leading, 5)

            Spacer()

        }
        .frame(width: 375, height: 90) // Fixed height for consistency
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.bottom, 20)
    }
}
