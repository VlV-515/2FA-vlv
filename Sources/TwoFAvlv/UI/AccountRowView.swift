import SwiftUI
import TwoFACore

struct IconBadge: View {
    let title: String
    var size: CGFloat = 40

    var body: some View {
        let style = BrandStyle.make(for: title)
        Text(String(title.trimmingCharacters(in: .whitespaces).prefix(1)).uppercased())
            .font(.system(size: size * 0.46, weight: .bold, design: .rounded))
            .foregroundStyle(style.foreground)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous).fill(style.background))
            .accessibilityHidden(true)
    }
}

struct CountdownRing: View {
    let remaining: Double
    let period: Int

    private var tint: Color {
        if remaining <= 5 { return Theme.danger }
        if remaining <= 10 { return Theme.warning }
        return Theme.accent
    }

    var body: some View {
        ZStack {
            Circle().stroke(Theme.border, lineWidth: 3)
            Circle()
                .trim(from: 0, to: remaining / Double(max(period, 1)))
                .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(remaining.rounded(.up)))")
                .font(.system(size: 10, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(tint)
        }
        .frame(width: 30, height: 30)
        .accessibilityHidden(true)
    }
}

struct AccountRowView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: AppSettings
    let account: Account
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var revealUntil: Date = .distantPast

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.25)) { context in
            content(now: context.date)
        }
        .contextMenu { menu }
    }

    private func content(now: Date) -> some View {
        let code = OTP.code(for: account, at: now)
        let remaining = OTP.secondsRemaining(period: account.period, at: now)
        let masked = settings.hideCodes && now >= revealUntil
        let display = code.map { format($0) }

        return HStack(spacing: 12) {
            IconBadge(title: account.title, size: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(account.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                if !account.subtitle.isEmpty {
                    Text(account.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            Spacer(minLength: 8)
            if let display {
                if masked {
                    Button { revealUntil = Date().addingTimeInterval(10) } label: {
                        Label(settings.copy.codeHidden, systemImage: "eye")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .buttonStyle(.borderless)
                } else {
                    Text(display)
                        .font(.system(size: 22, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(account.kind == .totp && remaining <= 5 ? Theme.danger : Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Button { state.copyCode(for: account) } label: {
                    Image(systemName: "doc.on.doc").frame(width: 26, height: 26)
                }
                .buttonStyle(.borderless)
                .help(settings.copy.copyCode)
                .accessibilityLabel(settings.copy.copyCode)
                trailing(remaining: remaining)
            } else {
                Label(settings.copy.invalidSecretRow, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.danger)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .frame(minHeight: 48)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func trailing(remaining: Double) -> some View {
        if account.kind == .hotp {
            Button {
                state.store.incrementCounter(account.id)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.borderless)
            .help(settings.copy.nextCode)
            .accessibilityLabel(settings.copy.nextCode)
        } else {
            CountdownRing(remaining: remaining, period: account.period)
        }
    }

    private func format(_ code: String) -> String {
        guard account.kind != .steam else { return code }
        let half = code.count / 2
        guard code.count >= 6, code.count % 2 == 0 else { return code }
        return code.prefix(half) + " " + code.suffix(half)
    }

    @ViewBuilder
    private var menu: some View {
        let t = settings.copy
        Button(t.copyCode) { state.copyCode(for: account) }
        Button(account.isFavorite ? t.removeFromFavorites : t.addToFavorites) {
            state.store.toggleFavorite(account.id)
        }
        Menu(t.moveToFolder) {
            Button(t.noFolder) { state.store.setFolder(nil, for: account.id) }
            ForEach(state.store.folders) { folder in
                Button(folder.name) { state.store.setFolder(folder.id, for: account.id) }
            }
        }
        Divider()
        Button(t.editAccount, action: onEdit)
        Button(t.delete, role: .destructive, action: onDelete)
    }
}
