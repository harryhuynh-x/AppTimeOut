//
//  BlockView.swift
//
//  Purpose:
//  - Unified Blocking screen for managing blocked Apps and Websites.
//
//  Key Features:
//  - Split into two sections: Apps and Websites, each with list, empty state, and add/remove.
//  - Subscription badge and messaging (Free vs Premium) at the top.
//  - Edit mode via toolbar for deletions.
//
//  Notes:
//  - Uses ContentUnavailableView on iOS 17+; falls back to a simple placeholder on earlier OS versions.
//

import SwiftUI

struct BlockingView: View {
    let subscription: SubscriptionLevel

    @State private var blockedApps: [BlockedApp] = []
    @State private var blockedWebsites: [BlockedWebsite] = []

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
                    Text(subscription == .free
                         ? "Free: up to 4 items."
                         : "Premium: more items + extra controls.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Section("Apps") {
                    if blockedApps.isEmpty {
                        EmptyAppsPlaceholder()
                    } else {
                        ForEach(blockedApps) { app in
                            HStack {
                                Image(systemName: "app")
                                    .foregroundStyle(.blue)
                                Text(app.displayName)
                                Spacer()
                                Text(app.bundleIdentifier)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: removeApps)
                    }

                    Button {
                        addApp()
                    } label: {
                        Label("Add App", systemImage: "plus.circle.fill")
                    }
                }

                Section("Websites") {
                    if blockedWebsites.isEmpty {
                        EmptyWebsitesPlaceholder()
                    } else {
                        ForEach(blockedWebsites) { site in
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundStyle(.green)
                                Text(site.displayName)
                                Spacer()
                                Text(site.domain)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: removeWebsites)
                    }

                    Button {
                        addWebsite()
                    } label: {
                        Label("Add Website", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Blocking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { EditButton() }
        }
    }

    // MARK: - Actions

    private func addApp() {
        // TODO: Present an app picker; for now, append a placeholder
        blockedApps.append(BlockedApp(bundleIdentifier: "com.example.app\(Int.random(in: 100...999))",
                                      displayName: "Example App"))
    }

    private func removeApps(at offsets: IndexSet) {
        blockedApps.remove(atOffsets: offsets)
    }

    private func addWebsite() {
        // TODO: Prompt for a domain; for now, append a placeholder
        blockedWebsites.append(BlockedWebsite(domain: "example.com",
                                              displayName: "Example"))
    }

    private func removeWebsites(at offsets: IndexSet) {
        blockedWebsites.remove(atOffsets: offsets)
    }
}

// MARK: - Empty State Placeholders with iOS 17 fallback

private struct EmptyAppsPlaceholder: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView("No blocked apps",
                                   systemImage: "app.badge",
                                   description: Text("Add apps to block them during focus or schedules."))
        } else {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "app.badge").foregroundColor(.secondary)
                    Text("No blocked apps").font(.subheadline.bold())
                }
                Text("Add apps to block them during focus or schedules.")
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
                                   description: Text("Add websites by domain to block them."))
        } else {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "globe").foregroundColor(.secondary)
                    Text("No blocked websites").font(.subheadline.bold())
                }
                Text("Add websites by domain to block them.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Models

struct BlockedApp: Identifiable, Equatable {
    let id = UUID()
    var bundleIdentifier: String
    var displayName: String
}

struct BlockedWebsite: Identifiable, Equatable {
    let id = UUID()
    var domain: String
    var displayName: String
}

#Preview("Blocking - Free") {
    BlockingView(subscription: .free)
}

#Preview("Blocking - Premium") {
    BlockingView(subscription: .premium)
}
