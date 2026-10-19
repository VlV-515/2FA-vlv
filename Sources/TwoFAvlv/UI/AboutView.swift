import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        let t = settings.copy
        VStack(spacing: 12) {
            Image(nsImage: AppBranding.makeAboutIcon())
                .resizable()
                .frame(width: 96, height: 96)
                .accessibilityLabel(AppBranding.displayName)
            Text(AppBranding.displayName).font(.system(size: 22, weight: .bold, design: .rounded))
            Text(t.tagline)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
            Text("\(t.version) \(AppBranding.version) (\(AppBranding.build))")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)

            VStack(alignment: .leading, spacing: 8) {
                linkRow("person.crop.circle", t.developerGitHub, AppBranding.developerURL)
                linkRow("chevron.left.forwardslash.chevron.right", t.projectGitHub, AppBranding.projectURL)
                linkRow("arrow.down.circle", t.projectSourceForge, AppBranding.sourceForgeURL)
                linkRow("shippingbox", t.releases, AppBranding.releasesURL)
                linkRow("doc.text", t.license, AppBranding.licenseURL)
            }
            .padding(.top, 6)

            Text(t.createdBy).font(.system(size: 12, weight: .medium)).padding(.top, 6)
            Text(t.copyright)
                .font(.system(size: 11))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }

    private func linkRow(_ icon: String, _ title: String, _ url: URL) -> some View {
        Link(destination: url) {
            Label(title, systemImage: icon)
                .font(.system(size: 13))
                .frame(minWidth: 230, alignment: .leading)
        }
        .foregroundStyle(Theme.accent)
    }
}
