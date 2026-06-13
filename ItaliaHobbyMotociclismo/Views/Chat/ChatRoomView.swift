import SwiftUI

/// Private chat room for a specific event — only subscribed users can access this.
struct ChatRoomView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var chatVM: ChatViewModel

    init(event: Event) {
        _chatVM = StateObject(wrappedValue: ChatViewModel(event: event))
    }

    var body: some View {
        ZStack {
            CrownBackground()

            VStack(spacing: 14) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(chatVM.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == authVM.currentUser?.id
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                    }
                    .onChange(of: chatVM.messages.count) { _, _ in
                        if let last = chatVM.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                CrownPanel(spacing: 12) {
                    HStack(spacing: 8) {
                        TextField("Write a message…", text: $chatVM.newMessageText, axis: .vertical)
                            .lineLimit(1...4)
                            .crownTextField()

                        Button {
                            Task { await sendMessage() }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(CrownPrimaryButtonStyle())
                        .frame(width: 70)
                        .disabled(chatVM.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(chatVM.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
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
        .crownNavigationChrome()
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
            if isCurrentUser { Spacer(minLength: 40) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 5) {
                if !isCurrentUser {
                    Text(message.senderNickname)
                        .font(.caption.bold())
                        .foregroundColor(CrownTheme.gold)
                }

                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(isCurrentUser ? CrownTheme.crimson : CrownTheme.parchment)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(CrownTheme.gold.opacity(isCurrentUser ? 0.45 : 0.8), lineWidth: 1.5)
                    )
                    .foregroundColor(isCurrentUser ? CrownTheme.parchment : CrownTheme.ink)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(CrownTheme.parchment.opacity(0.7))
            }

            if !isCurrentUser { Spacer(minLength: 40) }
        }
    }
}
