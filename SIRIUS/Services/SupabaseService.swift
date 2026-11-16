//
//  SupabaseService.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

// Single Supabase client for the whole app.
// Requires the Swift package: https://github.com/supabase/supabase-swift (product "Supabase").

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://vkxjdqkdavzyogquhpel.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZreGpkcWtkYXZ6eW9ncXVocGVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMwODYxNzgsImV4cCI6MjEwODY2MjE3OH0.GQ17rjDYZDz-TKgCeeKb-38VattNoqpL0Y4ovpz3Blg"
}

enum SupabaseService {
    static let client = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
}
