//
//  SupabaseClient.swift
//  gourd
//

import Supabase

// ─── Singleton ───────────────────────────────────────────────────────────────
// Replace the placeholder values below with your project credentials.
// Supabase Dashboard → Project Settings → API

let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.projectURL)!,
    supabaseKey: SupabaseConfig.anonKey
)

enum SupabaseConfig {
    // TODO: Fill in your Supabase project URL and anon key
    static let projectURL = "https://YOUR_PROJECT_ID.supabase.co"
    static let anonKey    = "YOUR_ANON_KEY_HERE"
}
