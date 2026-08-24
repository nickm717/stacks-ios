import SwiftUI

/// The O2 sign-in surface: email magic link, currently the only sign-in
/// method. Sign in with Apple was pulled from STK-4's scope pending an
/// Apple Developer Program account — see STK-34 — so this screen is a
/// plain email form rather than the system Apple button plus alternative.
/// The rest of the onboarding journey (welcome, profile setup, first scan)
/// is out of scope here — see STK-32.
struct SignInView: View {
    @EnvironmentObject private var authService: AuthService

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
                .buttonStyle(.borderedProminent)
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
