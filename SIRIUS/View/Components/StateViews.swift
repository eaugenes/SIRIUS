//
//  StateViews.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

// Shared empty / loading / error states and the offline banner.

import SwiftUI
import Network
import Combine

enum LoadState: Equatable {
    case loading
    case loaded
    case failed(String)
}

// MARK: Empty / loading / error

struct EmptyStateView: View {
    let icon: String
    let title: String
    var message: String = ""
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var onDark: Bool = true                 // true on the blue background, false inside a white card
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .scaledFont(size: 40)
                .accessibilityHidden(true)
            Text(title)
                .scaledFont(size: 15, weight: .medium)
            if !message.isEmpty {
                Text(message)
                    .scaledFont(size: 12)
                    .multilineTextAlignment(.center)
                    .opacity(0.85)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .scaledFont(size: 13, weight: .semibold)
                    .padding(.horizontal, 18)
                    .frame(height: 34)
                    .background(Capsule().fill(Color.siriusSurface))
                    .foregroundStyle(Color.siriusNavy)
                    .padding(.top, 6)
            }
        }
        .foregroundStyle(onDark ? Color.white : Color.siriusInk)
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct LoadingStateView: View {
    var message = "Loading\u{2026}"
    
    var body: some View {
        VStack(spacing: 10) {
            ProgressView()
                .tint(Color.white)
            Text(message)
                .scaledFont(size: 13)
                .foregroundStyle(Color.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

struct ErrorStateView: View {
    let message: String
    var retry: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Something went wrong",
            message: message,
            actionTitle: "Try again",
            action: retry
        )
        .frame(maxHeight: .infinity)
    }
}

// MARK: Board state overlay (loading / failed) + sync error banner

private struct BoardStateModifier: ViewModifier {
    @ObservedObject var board: JobBoard
    
    func body(content: Content) -> some View {
        ZStack {
            content
            switch board.loadState {
            case .loading:
                LoadingStateView()
                    .background(Color.black.opacity(0.25).ignoresSafeArea())
            case .failed(let message):
                ErrorStateView(message: message) {
                    Task { await board.reload() }
                }
                .background(Color.siriusNavy.opacity(0.92).ignoresSafeArea())
            case .loaded:
                EmptyView()
            }
        }
    }
}

extension View {
    // Shows a spinner while the board loads and a retry card when loading failed
    func boardLoadState(_ board: JobBoard = .shared) -> some View {
        modifier(BoardStateModifier(board: board))
    }
}

// MARK: Network

final class NetworkMonitor: ObservableObject {
    @Published private(set) var isOffline = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "sirius.network")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let offline = path.status != .satisfied
            DispatchQueue.main.async { self?.isOffline = offline }
        }
        monitor.start(queue: queue)
    }
    
    deinit { monitor.cancel() }
}

// Top banner: offline notice and failed-save message with Retry / Dismiss
struct StatusBanner: View {
    @ObservedObject var network: NetworkMonitor
    @ObservedObject var board: JobBoard = .shared
    
    var body: some View {
        VStack(spacing: 6) {
            if network.isOffline {
                banner(icon: "wifi.slash", text: "You're offline. Changes can't be saved until you reconnect.")
            }
            if let error = board.syncError {
                banner(icon: "exclamationmark.circle", text: error, dismiss: { board.syncError = nil })
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .animation(.easeInOut(duration: 0.2), value: network.isOffline)
        .animation(.easeInOut(duration: 0.2), value: board.syncError)
    }
    
    private func banner(icon: String, text: String, dismiss: (() -> Void)? = nil) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(text)
                .scaledFont(size: 12, weight: .medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let dismiss {
                Button("Dismiss", action: dismiss)
                    .scaledFont(size: 12, weight: .semibold)
            }
        }
        .foregroundStyle(Color.white)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.siriusDanger))
        .accessibilityElement(children: .combine)
    }
}
