//
//  InboxController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import Foundation
import Combine

final class InboxController: ObservableObject {
    
    static let shared = InboxController()
    
    @Published private(set) var items: [AppNotification] = []
    @Published private(set) var toast: AppNotification?          // banner for a notification that just arrived
    
    private var knownIDs = Set<UUID>()
    private var didFirstLoad = false                             // the first load only fills the badge, no banner
    
    init() {}
    
    var unreadCount: Int { items.filter { !$0.isRead }.count }
    
    @MainActor
    func reload() async {
        guard await SupabaseAuthService.currentUserID() != nil else { return }
        guard let list = try? await SupabaseStore.fetchNotifications() else { return }
        
        let arrivals = list.filter { !$0.isRead && !knownIDs.contains($0.id) }
        knownIDs.formUnion(list.map { $0.id })
        items = list
        
        if didFirstLoad, let newest = arrivals.first {
            if arrivals.count == 1 {
                toast = newest
            } else {
                toast = AppNotification(
                    id: UUID(), kind: newest.kind,
                    title: "\(arrivals.count) new notifications",
                    body: newest.body, isRead: false, createdAt: newest.createdAt
                )
            }
        }
        didFirstLoad = true
    }
    
    @MainActor
    func markAllRead() async {
        let unread = items.filter { !$0.isRead }.map { $0.id }
        guard !unread.isEmpty else { return }
        for index in items.indices { items[index].isRead = true }
        try? await SupabaseStore.markNotificationsRead(ids: unread)
    }
    
    @MainActor
    func dismissToast(_ id: UUID? = nil) {
        if id == nil || toast?.id == id { toast = nil }
    }
    
    // Called on log out so the next user does not see the previous user's notifications
    func clear() {
        items = []
        toast = nil
        knownIDs = []
        didFirstLoad = false
    }
}
