//
//  SupabaseClient.swift
//  gourd
//

import Foundation
import Supabase

// ─── Singleton ───────────────────────────────────────────────────────────────
// Credentials live in Secrets.swift (gitignored).
// Copy Secrets.swift.example → Secrets.swift and fill in your values.

let supabase = SupabaseClient(
    supabaseURL: URL(string: Secrets.supabaseURL)!,
    supabaseKey: Secrets.supabaseAnonKey
)
