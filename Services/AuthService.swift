import CryptoKit
import Foundation
import Security
import Supabase

/// Owns the app's Supabase Auth session: Sign in with Apple (preferred,
/// system-styled per stacks-context/design/design-decision-log.md "O2 auth"),
/// email magic link as the alternative, and the signed-in/signed-out state
/// the rest of the app reacts to. Session persistence across launches is
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

    /// Completes Sign in with Apple using the ID token AuthenticationServices
    /// returned, plus the raw nonce that was hashed into the original
    /// request (see `Self.randomNonceString`/`Self.sha256`).
    func signInWithApple(idToken: String, nonce: String) async throws {
        try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(provider: .apple, idToken: idToken, nonce: nonce)
        )
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

    // MARK: - Apple nonce

    /// Apple's recommended nonce dance: a random string is hashed into the
    /// `ASAuthorizationAppleIDRequest`, and the raw string is later handed to
    /// Supabase alongside the returned ID token so it can verify the token
    /// was minted for this exact request.
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            precondition(status == errSecSuccess, "Unable to generate nonce: SecRandomCopyBytes failed")
            for random in randoms where remaining > 0 {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
