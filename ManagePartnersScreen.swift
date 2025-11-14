import SwiftUI

enum PartnerContactMethod: String, CaseIterable, Identifiable {
    case phone = "Phone"
    case email = "Email"
    var id: String { rawValue }
}

struct ManagePartnersScreen: View {
    @State private var partnerName: String = ""
    @State private var partnerPhone: String = ""
    @State private var partnerEmail: String = ""
    @State private var method: PartnerContactMethod = .phone

    @State private var showValidation: Bool = false

    var body: some View {
        Form {
            Section("Partner Info") {
                TextField("Name (optional)", text: $partnerName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()

                TextField("Phone", text: $partnerPhone)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.phonePad)
                    .autocorrectionDisabled()
                    .disabled(method != .phone)

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

                Text(method == .phone
                     ? "We will use the partner's phone number to deliver unlock codes."
                     : "We will use the partner's email address to deliver unlock codes.")
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
                        // Example: PartnerSettings.shared.save(name: partnerName, phone: partnerPhone, email: partnerEmail, method: method)
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
        case .phone:
            return isValidPhone(partnerPhone)
        case .email:
            return isValidEmail(partnerEmail)
        }
    }

    private var validationMessage: String? {
        switch method {
        case .phone:
            return isValidPhone(partnerPhone) ? nil : "Please enter a valid phone number."
        case .email:
            return isValidEmail(partnerEmail) ? nil : "Please enter a valid email address."
        }
    }

    private func isValidPhone(_ s: String) -> Bool {
        let digits = s.filter { $0.isNumber }
        return digits.count >= 7
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
