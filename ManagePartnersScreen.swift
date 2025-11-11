import SwiftUI

enum PartnerContactMethod: String, CaseIterable, Identifiable {
    case name = "Name"
    case email = "Email"
    var id: String { rawValue }
}

struct ManagePartnersScreen: View {
    @State private var partnerName: String = ""
    @State private var partnerEmail: String = ""
    @State private var method: PartnerContactMethod = .name

    @State private var showValidation: Bool = false

    var body: some View {
        Form {
            Section("Partner Info") {
                TextField("Name", text: $partnerName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .disabled(method != .name)

                TextField("Email", text: $partnerEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .disabled(method != .email)
            }

            Section("Communication Method") {
                Picker("Method", selection: $method) {
                    ForEach(PartnerContactMethod.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)

                Text(method == .name
                     ? "We will use the partner's name as the contact identifier for unlock codes."
                     : "We will use the partner's email as the contact identifier for unlock codes.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            if showValidation, let error = validationMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }

            Section {
                Button("Save") {
                    if isValid {
                        // Persist the partner data and method selection.
                        // TODO: Hook into your persistence layer / settings model.
                        // Example: PartnerSettings.shared.save(name: partnerName, email: partnerEmail, method: method)
                    } else {
                        showValidation = true
                    }
                }
                .disabled(!isValid)
            }
        }
        .navigationTitle("Manage Partners")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Validation

    private var isValid: Bool {
        switch method {
        case .name:
            return !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .email:
            return isValidEmail(partnerEmail)
        }
    }

    private var validationMessage: String? {
        switch method {
        case .name:
            return partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Please enter a partner name." : nil
        case .email:
            return isValidEmail(partnerEmail) ? nil : "Please enter a valid email address."
        }
    }

    private func isValidEmail(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        // Lightweight email validation
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

#Preview {
    NavigationStack { ManagePartnersScreen() }
}
