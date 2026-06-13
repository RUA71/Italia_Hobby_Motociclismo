import SwiftUI

/// Private chat room for a specific event — only subscribed users can access this.
struct ChatRoomView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var chatVM: ChatViewModel

    init(event: Event) {
        _chatVM = StateObject(wrappedValue: ChatViewModel(event: event))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(chatVM.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == authVM.currentUser?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .onChange(of: chatVM.messages.count) { _, _ in
                    if let last = chatVM.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            // Message input
            HStack(spacing: 8) {
                TextField("Write a message…", text: $chatVM.newMessageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button {
                    Task { await sendMessage() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
                .disabled(chatVM.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
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

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.senderNickname)
                        .font(.caption.bold())
                        .foregroundColor(.accentColor)
                }

                Text(message.text)
                    .padding(10)
                    .background(isCurrentUser ? Color.accentColor : Color(.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(14)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !isCurrentUser { Spacer() }
        }
    }
}
