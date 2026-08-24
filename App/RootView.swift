import SwiftUI

/// Placeholder post-auth root. The real navigation shell (tab bar: Library ·
/// Browse · Profile) lands with the information-architecture work — see
/// stacks-context/product/information-architecture.md. This view exists to
/// prove the Supabase session — established via STK-4's Sign in with Apple /
/// email magic link flow — reaches here and survives an app restart.
struct RootView: View {
    @EnvironmentObject private var authService: AuthService

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
            if case .signedIn(let email) = authService.state {
                Text("Signed in as \(email ?? "unknown")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Button("Sign Out") {
                Task { try? await authService.signOut() }
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

#Preview {
    RootView()
        .environmentObject(AuthService())
}
