import SwiftUI

@main
struct StacksApp: App {
    @StateObject private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            Group {
                switch authService.state {
                case .unknown:
                    ProgressView()
                case .signedOut:
                    SignInView()
                case .signedIn:
                    RootView()
                }
            }
            .environmentObject(authService)
            .onOpenURL { url in
                Task {
                    try? await authService.handle(url: url)
                }
            }
        }
    }
}
