import SwiftUI

/// Placeholder root view for the scaffold. The real navigation shell (tab
/// bar: Library · Browse · Profile) lands with the auth and information
/// architecture work — see stacks-context/product/information-architecture.md
/// and STK-4. This view exists to prove the project builds, runs, and can
/// reach the configured Supabase project.
struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "books.vertical")
                .font(.system(size: 48))
                .foregroundStyle(.primary)
            Text("Stacks")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Text("Scaffold running. Supabase project: \(SupabaseConfig.url.host ?? "unknown")")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    RootView()
}
