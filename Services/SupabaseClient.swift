import Foundation
import Supabase

/// Reads Supabase configuration injected via `Config/Supabase.xcconfig` at
/// build time (see `App/Info.plist`), rather than hardcoding it in source.
enum SupabaseConfig {
    static let url: URL = {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: raw)
        else {
            fatalError("SUPABASE_URL missing or invalid in Info.plist — check Config/Supabase.xcconfig")
        }
        return url
    }()

    static let anonKey: String = {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
            !key.isEmpty
        else {
            fatalError("SUPABASE_ANON_KEY missing in Info.plist — check Config/Supabase.xcconfig")
        }
        return key
    }()

    /// Where the app is reopened when a user taps an email magic link. Must
    /// match the `CFBundleURLSchemes` entry in `App/Info.plist` and be
    /// allow-listed in the Supabase dashboard under Auth > URL Configuration.
    static let authRedirectURL = URL(string: "com.nickm717.stacks://auth-callback")!
}

extension SupabaseClient {
    /// The app-wide Supabase client, configured against the "stacks" project.
    static let shared = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
}
