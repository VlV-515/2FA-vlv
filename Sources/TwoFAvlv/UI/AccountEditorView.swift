import AppKit
import SwiftUI
import TwoFACore
import UniformTypeIdentifiers

struct AccountEditorView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case manual, uri, qr
        var id: String { rawValue }
    }

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var store: AccountStore
    @Environment(\.dismiss) private var dismiss

    let request: EditorRequest
    private let editing: Account?

    @State private var mode: Mode = .manual
    @State private var issuer = ""
    @State private var name = ""
    @State private var secret = ""
    @State private var folderID: UUID?
    @State private var isFavorite = false
    @State private var kind: OTPKind = .totp
    @State private var algorithm: OTPAlgorithm = .sha1
    @State private var digits = 6
    @State private var period = 30
    @State private var counter = 0
    @State private var showAdvanced = false
    @State private var uriText = ""
    @State private var info: String?
    @State private var error: String?
    @State private var secretTouched = false
    @State private var scanning = false

    init(request: EditorRequest) {
        self.request = request
        if case .edit(let account) = request { editing = account } else { editing = nil }
        if case .edit(let a) = request {
            _issuer = State(initialValue: a.issuer)
            _name = State(initialValue: a.name)
            _secret = State(initialValue: a.secret)
            _folderID = State(initialValue: a.folderID)
            _isFavorite = State(initialValue: a.isFavorite)
            _kind = State(initialValue: a.kind)
            _algorithm = State(initialValue: a.algorithm)
            _digits = State(initialValue: a.digits)
            _period = State(initialValue: a.period)
            _counter = State(initialValue: a.counter)
        }
    }

    private var t: AppCopy { settings.copy }
    private var secretValid: Bool { Base32.isValid(secret) }
    private var canSave: Bool { secretValid && !(issuer.trimmingCharacters(in: .whitespaces).isEmpty && name.trimmingCharacters(in: .whitespaces).isEmpty) }

    var body: some View {
        VStack(spacing: 0) {
            Text(editing == nil ? t.addAccountTitle : t.editAccountTitle)
                .font(.headline)
                .padding(.top, 16)

            if editing == nil {
                Picker("", selection: $mode) {
                    Text(t.modeManual).tag(Mode.manual)
                    Text(t.modeURI).tag(Mode.uri)
                    Text(t.modeQR).tag(Mode.qr)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            Group {
                switch mode {
                case .manual: manualForm
                case .uri: uriForm
                case .qr: qrForm
                }
            }

            if let info {
                Label(info, systemImage: "checkmark.circle").font(.system(size: 12)).foregroundStyle(Theme.accent)
                    .padding(.horizontal, 20)
            }
            if let error {
                Label(error, systemImage: "exclamationmark.triangle").font(.system(size: 12)).foregroundStyle(Theme.danger)
                    .padding(.horizontal, 20)
                    .accessibilityAddTraits(.updatesFrequently)
            }

            HStack {
                Spacer()
                Button(t.cancel, role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(t.save, action: save)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                    .disabled(mode != .manual || !canSave)
            }
            .padding(20)
        }
        .frame(width: 460, height: 540)
    }

    private var manualForm: some View {
        Form {
            TextField(t.service, text: $issuer, prompt: Text(t.servicePlaceholder))
            TextField(t.accountName, text: $name, prompt: Text(t.accountPlaceholder))
            VStack(alignment: .leading, spacing: 4) {
                TextField(t.secretKey, text: $secret, prompt: Text(t.secretPlaceholder))
                    .font(.system(.body, design: .monospaced))
                    .autocorrectionDisabled()
                    .onChange(of: secret) { _ in secretTouched = true }
                if secretTouched, !secret.isEmpty, !secretValid {
                    Text(t.secretInvalid).font(.system(size: 11)).foregroundStyle(Theme.danger)
                }
            }
            Picker(t.folder, selection: $folderID) {
                Text(t.noFolder).tag(UUID?.none)
                ForEach(store.folders) { folder in
                    Text(folder.name).tag(UUID?.some(folder.id))
                }
            }
            Toggle(t.favorite, isOn: $isFavorite)
            DisclosureGroup(t.advanced, isExpanded: $showAdvanced) {
                Picker(t.type, selection: $kind) {
                    Text(t.typeTOTP).tag(OTPKind.totp)
                    Text(t.typeHOTP).tag(OTPKind.hotp)
                    Text(t.typeSteam).tag(OTPKind.steam)
                }
                Picker(t.algorithm, selection: $algorithm) {
                    ForEach(OTPAlgorithm.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .disabled(kind == .steam)
                Stepper("\(t.digits): \(digits)", value: $digits, in: 4...10)
                    .disabled(kind == .steam)
                if kind == .hotp {
                    Stepper("\(t.counter): \(counter)", value: $counter, in: 0...Int.max)
                } else {
                    Stepper("\(t.period): \(period)", value: $period, in: 5...300, step: 5)
                }
            }
        }
        .formStyle(.grouped)
        .padding(.top, 4)
    }

    private var uriForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(t.uriHint).font(.system(size: 12)).foregroundStyle(Theme.textSecondary)
            TextField(t.uriLabel, text: $uriText, prompt: Text("otpauth://totp/..."))
                .font(.system(.body, design: .monospaced))
                .textFieldStyle(.roundedBorder)
                .onSubmit(useURI)
            Button(t.uriUse, action: useURI)
                .disabled(uriText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var qrForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t.qrHint).font(.system(size: 12)).foregroundStyle(Theme.textSecondary)
            HStack {
                Button(t.qrChooseImage, action: chooseImage)
                Button(t.qrCaptureScreen) { Task { await captureScreen() } }
                    .disabled(scanning)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Actions

    private func apply(_ account: Account) {
        issuer = account.issuer
        name = account.name
        secret = account.secret
        kind = account.kind
        algorithm = account.algorithm
        digits = account.digits
        period = account.period
        counter = account.counter
        showAdvanced = account.kind != .totp || account.algorithm != .sha1 || account.digits != 6 || account.period != 30
        error = nil
        info = nil
        mode = .manual
    }

    private func useURI() {
        do {
            apply(try OTPAuthURI.parse(uriText))
            info = t.qrLoaded
        } catch {
            self.error = t.uriInvalid
        }
    }

    private func handleQR(_ payloads: [String]) {
        guard !payloads.isEmpty else {
            error = t.qrNotFound
            return
        }
        guard let account = payloads.lazy.compactMap({ try? OTPAuthURI.parse($0) }).first else {
            error = t.qrNotOTP
            return
        }
        apply(account)
        info = t.qrLoaded
    }

    private func chooseImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        error = nil
        handleQR(QRScanner.decode(fileAt: url))
    }

    private func captureScreen() async {
        scanning = true
        defer { scanning = false }
        error = nil
        // The editor sheet would sit in the way of the selection, so hide the app while capturing.
        NSApp.hide(nil)
        try? await Task.sleep(nanoseconds: 250_000_000)
        let payloads = await QRScanner.captureScreenRegion()
        NSApp.activate(ignoringOtherApps: true)
        if let payloads { handleQR(payloads) }
    }

    private func save() {
        guard canSave else { return }
        var account = editing ?? Account(issuer: "", name: "", secret: "")
        account.issuer = issuer.trimmingCharacters(in: .whitespaces)
        account.name = name.trimmingCharacters(in: .whitespaces)
        account.secret = Base32.normalize(secret)
        account.folderID = folderID
        account.isFavorite = isFavorite
        account.kind = kind
        account.algorithm = kind == .steam ? .sha1 : algorithm
        account.digits = kind == .steam ? 5 : digits
        account.period = period
        account.counter = counter

        if editing != nil {
            store.update(account)
        } else if !store.addIfNew(account) {
            error = t.duplicateAccount
            return
        }
        dismiss()
    }
}
