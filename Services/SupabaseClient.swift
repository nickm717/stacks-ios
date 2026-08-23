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
}

extension SupabaseClient {
    /// The app-wide Supabase client, configured against the "stacks" project.
    /// Auth wiring (Sign in with Apple) lands with STK-4.
    static let shared = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
}
