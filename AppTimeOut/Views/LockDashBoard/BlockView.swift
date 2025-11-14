//
//  BlockView.swift
//
//  Purpose:
//  - Unified Blocking screen for managing blocked Apps and Websites.
//
//  Key Features:
//  - Split into two sections: Apps and Websites, each with list, empty state, and add/remove.
//  - Subscription badge and messaging (Free vs Premium tier) at the top.
//  - Edit mode via toolbar for deletions.
//
//  Notes:
//  - Uses ContentUnavailableView on iOS 17+; falls back to a simple placeholder on earlier OS versions.
//

import SwiftUI
import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

struct BlockingView: View {
    let subscription: SubscriptionLevel

#if canImport(FirebaseAuth)
    @StateObject private var sync = BlockingSyncCoordinator(userIDProvider: { Auth.auth().currentUser?.uid })
#else
    @StateObject private var sync = BlockingSyncCoordinator()
#endif

    @State private var showingAppPicker: Bool = false
    @State private var appPickerSelection: AppPickerTab = .installed
    @State private var appStoreQuery: String = ""
    @State private var mockInstalledApps: [BlockedApp] = [
        BlockedApp(bundleIdentifier: "com.apple.MobileSMS", displayName: "Messages"),
        BlockedApp(bundleIdentifier: "com.apple.mobilesafari", displayName: "Safari"),
        BlockedApp(bundleIdentifier: "com.apple.Music", displayName: "Music")
    ]

    @State private var showingWebsiteEntry: Bool = false
    @State private var websiteInput: String = ""
    @State private var websiteInputError: String? = nil

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Blocking")
                            .font(.title2.bold())
                        Spacer()
                        Text(subscription == .free ? "Free" : "Premium")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if subscription == .free {
                        Text("Free: up to 3 apps and 3 websites.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Apps") {
                    if sync.apps.isEmpty {
                        EmptyAppsPlaceholder()
                    } else {
                        ForEach(sync.apps) { app in
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: "app.fill")
                                    .foregroundStyle(.red)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(app.displayName)
                                    Text(app.bundleIdentifier)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                HStack(spacing: 6) {
                                    Image(systemName: "nosign").foregroundStyle(.red)
                                    Text("Blocked")
                                        .font(.caption.bold())
                                        .foregroundStyle(.red)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { sync.apps[$0].id }
                            Task {
                                for id in ids {
                                    await sync.removeApp(id: id)
                                }
                            }
                        }
                    }

                    Button {
                        showingAppPicker = true
                    } label: {
                        Label("Add App", systemImage: "plus.circle.fill")
                    }
                    .disabled(subscription == .free && sync.apps.count >= 3)
                }

                Section("Websites") {
                    if sync.websites.isEmpty {
                        EmptyWebsitesPlaceholder()
                    } else {
                        ForEach(sync.websites) { site in
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: "globe")
                                    .foregroundStyle(.red)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(site.displayName)
                                    Text(site.domain)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                HStack(spacing: 6) {
                                    Image(systemName: "nosign").foregroundStyle(.red)
                                    Text("Blocked")
                                        .font(.caption.bold())
                                        .foregroundStyle(.red)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { sync.websites[$0].id }
                            Task {
                                for id in ids {
                                    await sync.removeWebsite(id: id)
                                }
                            }
                        }
                    }

                    Button {
                        showingWebsiteEntry = true
                    } label: {
                        Label("Add Website", systemImage: "plus.circle.fill")
                    }
                    .disabled(subscription == .free && sync.websites.count >= 3)
                }
            }
            .navigationTitle("Manage Blocks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { EditButton() }
            .task {
                await sync.load()
            }
            .sheet(isPresented: $showingAppPicker) {
                AppPickerView(
                    selection: $appPickerSelection,
                    installedApps: mockInstalledApps,
                    topSocialApps: AppPickerView.defaultTopSocialApps,
                    appStoreQuery: $appStoreQuery
                ) { picked in
                    // Add picked app if not already present; enforce free limit of 3
                    if !sync.apps.contains(where: { $0.bundleIdentifier == picked.bundleIdentifier }) {
                        if subscription == .free && sync.apps.count >= 3 {
                            // Silently ignore for now; you may show an alert later
                        } else {
                            Task {
                                await sync.addApp(picked)
                            }
                        }
                    }
                    showingAppPicker = false
                } onCancel: {
                    showingAppPicker = false
                }
            }
            .sheet(isPresented: $showingWebsiteEntry) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Website")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "globe").foregroundStyle(.red)
                                TextField("example.com or https://example.com", text: $websiteInput)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.URL)
                                    .autocorrectionDisabled()
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            if let error = websiteInputError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                websiteInput = ""
                                websiteInputError = nil
                                showingWebsiteEntry = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let normalized = normalizeDomain(from: websiteInput)
                                if let domain = normalized {
                                    if subscription == .free && sync.websites.count >= 3 {
                                        websiteInputError = "Free limit reached (3 websites)."
                                    } else if sync.websites.contains(where: { $0.domain.caseInsensitiveCompare(domain) == .orderedSame }) {
                                        websiteInputError = "Already in your blocked list."
                                    } else {
                                        Task {
                                            await sync.addWebsite(BlockedWebsite(domain: domain, displayName: prettifyDomain(domain)))
                                            websiteInput = ""
                                            websiteInputError = nil
                                            showingWebsiteEntry = false
                                        }
                                    }
                                } else {
                                    websiteInputError = "Please enter a valid domain or URL."
                                }
                            }
                            .disabled(websiteInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }

    // MARK: - URL/Domain helpers

    private func normalizeDomain(from input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Try to build URL; if missing scheme, add https://
        var urlString = trimmed
        if !trimmed.contains("://") {
            urlString = "https://" + trimmed
        }
        guard let url = URL(string: urlString), let host = url.host else {
            // If direct domain without dots, reject
            return isLikelyDomain(trimmed) ? trimmed.lowercased() : nil
        }
        // Strip common www.
        let domain = host.lowercased().replacingOccurrences(of: "^www\\.", with: "", options: .regularExpression)
        return isLikelyDomain(domain) ? domain : nil
    }

    private func isLikelyDomain(_ s: String) -> Bool {
        // Very lightweight domain check: must contain a dot and no spaces
        if s.contains(" ") { return false }
        return s.contains(".")
    }

    private func prettifyDomain(_ domain: String) -> String {
        // Capitalize first letter, remove www.
        let core = domain.replacingOccurrences(of: "^www\\.", with: "", options: .regularExpression)
        return core.capitalized
    }
}

// MARK: - Models

struct BlockedApp: Identifiable, Equatable, Codable {
    let id: UUID
    var bundleIdentifier: String
    var displayName: String

    init(id: UUID = UUID(), bundleIdentifier: String, displayName: String) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
    }
}

struct BlockedWebsite: Identifiable, Equatable, Codable {
    let id: UUID
    var domain: String
    var displayName: String

    init(id: UUID = UUID(), domain: String, displayName: String) {
        self.id = id
        self.domain = domain
        self.displayName = displayName
    }
}

// MARK: - Empty State Placeholders with iOS 17 fallback

private struct EmptyAppsPlaceholder: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView("No blocked apps",
                                   systemImage: "app.badge",
                                   description: Text("Add apps to block"))
        } else {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "app.badge").foregroundColor(.secondary)
                    Text("No blocked apps").font(.subheadline.bold())
                }
                Text("Add apps to block")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct EmptyWebsitesPlaceholder: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView("No blocked websites",
                                   systemImage: "globe",
                                   description: Text("Add websites to block"))
        } else {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "globe").foregroundColor(.secondary)
                    Text("No blocked websites").font(.subheadline.bold())
                }
                Text("Add websites to block")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - App Picker

private enum AppPickerTab: String, CaseIterable, Identifiable {
    case installed = "Installed"
    case social = "Top Social"
    case store = "App Store"
    var id: String { rawValue }
}

private struct AppPickerView: View {
    @Binding var selection: AppPickerTab
    var installedApps: [BlockedApp]
    var topSocialApps: [BlockedApp]
    @Binding var appStoreQuery: String
    var onPick: (BlockedApp) -> Void
    var onCancel: () -> Void

    static let defaultTopSocialApps: [BlockedApp] = [
        BlockedApp(bundleIdentifier: "com.burbn.instagram", displayName: "Instagram"),
        BlockedApp(bundleIdentifier: "com.facebook.Facebook", displayName: "Facebook"),
        BlockedApp(bundleIdentifier: "com.toyopagroup.picaboo", displayName: "Snapchat"),
        BlockedApp(bundleIdentifier: "com.twitter.twitter", displayName: "X (Twitter)"),
        BlockedApp(bundleIdentifier: "com.google.ios.youtube", displayName: "YouTube"),
        BlockedApp(bundleIdentifier: "com.zhiliaoapp.musically", displayName: "TikTok"),
        BlockedApp(bundleIdentifier: "com.reddit.Reddit", displayName: "Reddit"),
        BlockedApp(bundleIdentifier: "net.whatsapp.WhatsApp", displayName: "WhatsApp"),
        BlockedApp(bundleIdentifier: "com.tencent.xin", displayName: "WeChat"),
        BlockedApp(bundleIdentifier: "com.pinterest", displayName: "Pinterest")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented control
                Picker("Source", selection: $selection) {
                    ForEach(AppPickerTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                Group {
                    switch selection {
                    case .installed:
                        AppListView(apps: installedApps, onPick: onPick)
                    case .social:
                        AppListView(apps: topSocialApps, onPick: onPick)
                    case .store:
                        AppStoreSearchView(query: $appStoreQuery, onPick: onPick)
                    }
                }
            }
            .navigationTitle("Add App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

private struct AppListView: View {
    var apps: [BlockedApp]
    var onPick: (BlockedApp) -> Void

    var body: some View {
        List(apps) { app in
            Button {
                onPick(app)
            } label: {
                HStack {
                    Image(systemName: "app.fill")
                        .foregroundStyle(.red)
                    Text(app.displayName)
                    Spacer()
                    Text(app.bundleIdentifier)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct AppStoreSearchView: View {
    @Binding var query: String
    var onPick: (BlockedApp) -> Void

    // This is a mock search. Wire to real App Store search later.
    private var results: [BlockedApp] {
        let catalog = AppPickerView.defaultTopSocialApps + [
            BlockedApp(bundleIdentifier: "com.spotify.client", displayName: "Spotify"),
            BlockedApp(bundleIdentifier: "com.netflix.Netflix", displayName: "Netflix"),
            BlockedApp(bundleIdentifier: "com.discord", displayName: "Discord")
        ]
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return catalog.filter { $0.displayName.lowercased().contains(query.lowercased()) }
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search App Store", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(10)
            .background(Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding([.horizontal, .top])

            if results.isEmpty {
                Spacer()
                Text("Type to search the App Store")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(results) { app in
                    Button { onPick(app) } label: {
                        HStack {
                            Image(systemName: "app.badge")
                                .foregroundStyle(.red)
                            Text(app.displayName)
                            Spacer()
                            Text(app.bundleIdentifier)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

#Preview("Blocking - Free") {
    BlockingView(subscription: .free)
}

#Preview("Blocking - Premium") {
    BlockingView(subscription: .premium)
}
