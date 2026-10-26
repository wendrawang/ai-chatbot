//
//  HostWindowTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 27/10/26.
//

import Testing

/// Satu suite untuk semua test yang memakai window scene aplikasi. Swift Testing menjalankan test
/// paralel, jadi suite ini berurutan agar window dan run loop tidak saling bertabrakan.
/// Test ditambahkan lewat `extension HostWindowTests` di file masing-masing.
@MainActor
@Suite(.serialized)
struct HostWindowTests {}
