//
//  NotificationsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

struct NotificationBell: View {
    @ObservedObject private var inbox = InboxController.shared
    @State private var showInbox = false
    
    var body: some View {
        Button {
            showInbox = true
        } label: {
            Image(systemName: "bell.fill")
                .scaledFont(size: 17)
                .foregroundStyle(Color.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white.opacity(0.18)))
                .overlay(alignment: .topTrailing) {
                    if inbox.unreadCount > 0 {
                        Text(inbox.unreadCount > 9 ? "9+" : "\(inbox.unreadCount)")
                            .scaledFont(size: 9, weight: .bold)
                            .foregroundStyle(Color.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Circle().fill(Color.red))
                            .offset(x: 3, y: -3)
                    }
                }
        }
        .accessibilityLabel(inbox.unreadCount > 0 ? "Notifications, \(inbox.unreadCount) unread" : "Notifications")
        .sheet(isPresented: $showInbox) {
            NotificationsPage()
        }
    }
}

// Banner shown at the top of the app when a new notification arrives
struct InboxToastView: View {
    
    @ObservedObject private var inbox = InboxController.shared
    var onOpen: () -> Void = {}
    
    var body: some View {
        Group {
            if let toast = inbox.toast {
                HStack(spacing: 10) {
                    Image(systemName: toast.icon)
                        .scaledFont(size: 15)
                        .foregroundStyle(Color.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white.opacity(0.18)))
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(toast.title)
                            .scaledFont(size: 13, weight: .bold)
                            .lineLimit(1)
                        Text(toast.body)
                            .scaledFont(size: 11)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .foregroundStyle(Color.white)
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        inbox.dismissToast()
                    } label: {
                        Image(systemName: "xmark")
                            .scaledFont(size: 12, weight: .semibold)
                            .foregroundStyle(Color.white.opacity(0.85))
                            .frame(width: 28, height: 28)
                    }
                    .accessibilityLabel("Dismiss notification")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.siriusNavy))
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 12)
                .onTapGesture {
                    inbox.dismissToast()
                    onOpen()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .task(id: toast.id) {
                    try? await Task.sleep(for: .seconds(5))
                    inbox.dismissToast(toast.id)
                }
            }
        }
        .animation(.spring(duration: 0.3), value: inbox.toast?.id)
    }
}

// The inbox: newest first, unread ones marked with a dot
struct NotificationsPage: View {
    
    @ObservedObject private var inbox = InboxController.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Notifications")
                    .scaledFont(size: 26, weight: .medium)
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .scaledFont(size: 14, weight: .semibold)
                        .foregroundStyle(Color.siriusInk)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.siriusSurface))
                }
                .accessibilityLabel("Close")
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            if inbox.items.isEmpty {
                EmptyStateView(
                    icon: "bell.slash",
                    title: "No notifications yet",
                    message: "You will be notified here when something happens, such as an auto-application or an interview."
                )
                .padding(.top, 60)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(inbox.items) { item in
                            row(item)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
                .refreshable { await inbox.reload() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBg()
        .task { await inbox.reload() }
        .onDisappear {
            Task { await inbox.markAllRead() }
        }
    }
    
    // Fixed-size row: the text is shortened instead of growing the card
    private func row(_ item: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.icon)
                .scaledFont(size: 15)
                .foregroundStyle(Color.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.siriusNavy))
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .scaledFont(size: 13, weight: item.isRead ? .medium : .bold)
                        .foregroundStyle(Color.siriusText)
                        .lineLimit(1)
                    Spacer(minLength: 6)
                    Text(item.timeAgo)
                        .scaledFont(size: 10, weight: .light)
                        .foregroundStyle(Color.siriusText)
                        .lineLimit(1)
                }
                Text(item.body)
                    .scaledFont(size: 11)
                    .foregroundStyle(Color.siriusTextSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            if !item.isRead {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .padding(.top, 5)
                    .accessibilityLabel("Unread")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .fluidFrame(width: 354, height: 86, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.siriusSurface))
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 3)
        .accessibilityElement(children: .combine)
    }
}
