import Foundation
import SwiftUI
import Combine

final class FacebookLoginManager: ObservableObject {
    static let shared = FacebookLoginManager()

    @Published var isSignedIn: Bool = false
    @Published var email: String? = nil

    private init() {}

    @MainActor
    func signIn() async {
        self.isSignedIn = true
        self.email = "user@facebook.com"
    }

    func application(open url: URL) -> Bool {
        return false
    }

    func signOut() {
        self.isSignedIn = false
        self.email = nil
    }
}
