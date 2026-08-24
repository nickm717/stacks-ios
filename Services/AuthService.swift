import Foundation
import Supabase

/// Owns the app's Supabase Auth session: email magic link, currently the
/// only sign-in method (Sign in with Apple is deferred to STK-34, pending an
/// Apple Developer Program account), and the signed-in/signed-out state the
/// rest of the app reacts to. Session persistence across launches is
/// handled by the Supabase SDK's own (Keychain-backed) session storage —
/// this type just surfaces that state as `@Published`.
@MainActor
final class AuthService: ObservableObject {
    enum State: Equatable {
        case unknown
        case signedOut
        case signedIn(email: String?)
    }

    @Published private(set) var state: State = .unknown

    private let client: SupabaseClient
    private var listenerTask: Task<Void, Never>?

    init(client: SupabaseClient = .shared) {
        self.client = client
        listenerTask = Task { [weak self] in
            guard let self else { return }
            for await (event, session) in client.auth.authStateChanges {
                guard event == .initialSession || event == .signedIn || event == .signedOut else {
                    continue
                }
                self.apply(session: session)
            }
        }
    }

    deinit {
        listenerTask?.cancel()
    }

    private func apply(session: Session?) {
        state = session.map { .signedIn(email: $0.user.email) } ?? .signedOut
    }

    /// Sends a one-time sign-in link to `email`. The link opens the app via
    /// `SupabaseConfig.authRedirectURL`; finish the flow by passing the
    /// resulting URL to `handle(url:)`.
    func sendMagicLink(to email: String) async throws {
        try await client.auth.signInWithOTP(email: email, redirectTo: SupabaseConfig.authRedirectURL)
    }

    /// Handles the redirect URL opened when a user taps their magic link.
    func handle(url: URL) async throws {
        try await client.auth.session(from: url)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}
