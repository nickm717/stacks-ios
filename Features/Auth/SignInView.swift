import AuthenticationServices
import SwiftUI

/// The O2 sign-in surface: Sign in with Apple as the system-styled primary
/// action (per stacks-context/design/design-decision-log.md, "Sign in with
/// Apple ... confirmed as system component"), with email magic link as a
/// secondary path for anyone without (or not wanting to use) an Apple ID.
/// The rest of the onboarding journey (welcome, profile setup, first scan)
/// is out of scope here — see STK-32.
struct SignInView: View {
    @EnvironmentObject private var authService: AuthService

    @State private var currentNonce: String?
    @State private var email = ""
    @State private var magicLinkState: MagicLinkState = .idle
    @State private var errorMessage: String?

    private enum MagicLinkState: Equatable {
        case idle
        case sending
        case sent
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "books.vertical")
                    .font(.system(size: 44))
                    .foregroundStyle(.primary)
                Text("Stacks")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text("Sign in to see your neighborhood library.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            SignInWithAppleButton(.signIn, onRequest: configure, onCompletion: handleAppleCompletion)
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 12) {
                Divider()
                Text("or")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Divider()
            }

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                Button {
                    Task { await sendMagicLink() }
                } label: {
                    Group {
                        if magicLinkState == .sending {
                            ProgressView()
                        } else {
                            Text("Continue with email")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(email.isEmpty || magicLinkState == .sending)

                if magicLinkState == .sent {
                    Text("Check \(email) for a sign-in link.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }

    private func configure(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = AuthService.randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = AuthService.sha256(nonce)
    }

    private func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                errorMessage = "Couldn't read Apple's sign-in response. Please try again."
                return
            }
            errorMessage = nil
            Task {
                do {
                    try await authService.signInWithApple(idToken: idToken, nonce: nonce)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }

        case .failure(let error):
            if (error as? ASAuthorizationError)?.code != .canceled {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func sendMagicLink() async {
        errorMessage = nil
        magicLinkState = .sending
        do {
            try await authService.sendMagicLink(to: email)
            magicLinkState = .sent
        } catch {
            errorMessage = error.localizedDescription
            magicLinkState = .idle
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthService())
}
