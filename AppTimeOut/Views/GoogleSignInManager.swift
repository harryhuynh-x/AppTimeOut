import Foundation
import SwiftUI
import Combine

final class GoogleSignInManager: ObservableObject {
    static let shared = GoogleSignInManager()

    @Published var isSignedIn: Bool = false
    @Published var email: String? = nil

    private init() {}

    @MainActor
    func signIn() async {
        self.isSignedIn = true
        self.email = "user@gmail.com"
    }

    func handle(url: URL) -> Bool {
        return false
    }

    func signOut() {
        self.isSignedIn = false
        self.email = nil
    }
}
