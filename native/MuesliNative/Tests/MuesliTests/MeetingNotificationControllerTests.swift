import Foundation
import AppKit
import Testing
@testable import MuesliNativeApp

@Suite("MeetingNotificationController")
struct MeetingNotificationControllerTests {
    @Test("Slack candidates map to the Slack notification platform")
    func slackCandidateMapsToSlackNotificationPlatform() {
        #expect(MeetingPlatform(.slack) == .slack)
    }

    @Test("Unsupported candidate platforms do not get notification icons")
    func unsupportedCandidatePlatformsDoNotMapToNotificationPlatforms() {
        #expect(MeetingPlatform(.whatsApp) == nil)
        #expect(MeetingPlatform(.unknown) == nil)
    }

    @Test("Auto-dismiss without a dedicated handler still fires close cleanup")
    @MainActor
    func autoDismissWithoutHandlerFiresCloseCleanup() {
        #expect(MeetingNotificationController.suppressesCloseCallbackDuringAutoDismiss(hasAutoDismissHandler: false) == false)
    }

    @Test("Detection auto-dismiss owns its cleanup path")
    @MainActor
    func detectionAutoDismissOwnsCleanupPath() {
        #expect(MeetingNotificationController.suppressesCloseCallbackDuringAutoDismiss(hasAutoDismissHandler: true))
    }

    @Test("Auto-dismiss callback is skipped when hover pauses during fade-out")
    @MainActor
    func autoDismissCallbackSkippedWhenPausedDuringFadeOut() {
        #expect(MeetingNotificationController.firesAutoDismissCallbackAfterFade(wasDismissPaused: false))
        #expect(!MeetingNotificationController.firesAutoDismissCallbackAfterFade(wasDismissPaused: true))
    }

    @Test("notification accent resolves custom hex color")
    @MainActor
    func notificationAccentResolvesCustomHexColor() throws {
        let components = try rgbComponents(MeetingNotificationController.accentColor(hex: "fb6100"))

        #expect(abs(components.red - 251.0 / 255.0) < 0.001)
        #expect(abs(components.green - 97.0 / 255.0) < 0.001)
        #expect(abs(components.blue - 0.0) < 0.001)
    }

    @Test("notification accent falls back for default recording color")
    @MainActor
    func notificationAccentFallsBackForDefaultRecordingColor() throws {
        let components = try rgbComponents(MeetingNotificationController.accentColor(hex: "1e1e2e"))

        #expect(abs(components.red - 249.0 / 255.0) < 0.001)
        #expect(abs(components.green - 115.0 / 255.0) < 0.001)
        #expect(abs(components.blue - 22.0 / 255.0) < 0.001)
    }

    private func rgbComponents(_ color: NSColor) throws -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        let converted = try #require(color.usingColorSpace(.sRGB))
        return (converted.redComponent, converted.greenComponent, converted.blueComponent)
    }
}
