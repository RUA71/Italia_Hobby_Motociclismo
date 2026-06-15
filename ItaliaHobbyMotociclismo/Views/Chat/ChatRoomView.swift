import SwiftUI

/// Private chat room for a specific event — only subscribed users can access this.
struct ChatRoomView: View {
    private let messageBubbleMinimumMargin: CGFloat = 40

    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var chatVM: ChatViewModel

    init(event: Event) {
        _chatVM = StateObject(wrappedValue: ChatViewModel(event: event))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(chatVM.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == authVM.currentUser?.id,
                                minimumMargin: messageBubbleMinimumMargin
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: chatVM.messages.count) { _, _ in
                    if let last = chatVM.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Write a message…", text: $chatVM.newMessageText, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await sendMessage() }
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(chatVM.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .navigationTitle(chatVM.event.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { chatVM.startPolling(userId: authVM.currentUser?.id ?? "") }
        .onDisappear { chatVM.stopPolling() }
        .alert("Error", isPresented: errorBinding) {
            Button("OK", role: .cancel) { chatVM.errorMessage = nil }
        } message: {
            Text(chatVM.errorMessage ?? "")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { chatVM.errorMessage != nil },
            set: { if !$0 { chatVM.errorMessage = nil } }
        )
    }

    private func sendMessage() async {
        guard let user = authVM.currentUser else { return }
        await chatVM.sendMessage(userId: user.id, nickname: user.nickname)
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    let minimumMargin: CGFloat

    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: minimumMargin) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.senderNickname)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }

                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isCurrentUser ? Color.accentColor : Color(.secondarySystemFill))
                    )
                    .foregroundStyle(isCurrentUser ? .white : .primary)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !isCurrentUser { Spacer(minLength: minimumMargin) }
        }
    }
}
