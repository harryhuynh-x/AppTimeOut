# Auth Setup: Apple, Google, Facebook

---

## Sign in with Apple

- Use Apple's native `AuthenticationServices` framework.
- Steps:
  1. Import `AuthenticationServices`.
  2. Create and configure `ASAuthorizationAppleIDButton`.
  3. Implement `ASAuthorizationControllerDelegate` and `ASAuthorizationControllerPresentationContextProviding`.
  4. Handle authorization requests and responses.
  5. Use the credential's user identifier and tokens as needed.

---

## Google Sign-In (SPM)

- **SPM Package URL:**  
  `https://github.com/google/GoogleSignIn-iOS`

- **Xcode Setup:**  
  1. Open your project > Swift Packages > Add Package Dependency.  
  2. Paste the package URL above.  
  3. Choose the latest version and add to your target.

- **Info.plist Entries:**

  ```xml
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>REVERSED_CLIENT_ID</string> <!-- replace with your reversed client ID -->
      </array>
    </dict>
  </array>

  <key>GoogleService-Info</key> <!-- Optional: if using plist config -->
