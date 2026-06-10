import Foundation
import SwiftUI

/// Manages chat messages for a specific event and handles polling.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var newMessageText = ""

    let event: Event
    private var pollingTask: Task<Void, Never>?
    private let chatRepo = ChatRepository.shared

    // MARK: - Init

    init(event: Event) {
        self.event = event
        messages = chatRepo.cachedMessages(for: event.id)
    }

    deinit {
        pollingTask?.cancel()
    }

    // MARK: - Load / Poll

    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.fetchMessages()
                try? await Task.sleep(nanoseconds: 15_000_000_000) // 15 s
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
    }

    func fetchMessages() async {
        do {
            messages = try await chatRepo.fetchMessages(for: event.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Send

    func sendMessage(userId: String, nickname: String) async {
        let text = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        newMessageText = ""
        errorMessage = nil

        do {
            let msg = try await chatRepo.sendMessage(
                eventId: event.id,
                userId: userId,
                nickname: nickname,
                text: text
            )
            if !messages.contains(where: { $0.id == msg.id }) {
                messages.append(msg)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
