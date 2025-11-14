import SwiftUI

/// Simple guardian code overlay.
/// Calls `onSuccess()` when the correct code is entered.
struct UnlockSheetView: View {

    var onSuccess: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""
    @State private var showError = false

    // TEMP: hard-coded; later replace with real partner code.
    private let correctCode = "1234"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Partner Code")
                    .font(.headline)

                SecureField("Enter code", text: $code)
                    .textFieldStyle(.roundedBorder)

                if showError {
                    Text("Incorrect code. Try again.")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Confirm") {
                        validate()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Confirm")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func validate() {
        if code == correctCode {
            onSuccess()
            dismiss()
        } else {
            showError = true
        }
    }
}
  
