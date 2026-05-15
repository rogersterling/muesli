import Testing
@testable import MuesliNativeApp

@Suite("Meeting feature monitor policy")
struct MeetingFeatureMonitorPolicyTests {
    @Test("auto-record setting does not start scheduled meeting monitors")
    func autoRecordSettingDoesNotStartScheduledMeetingMonitors() {
        var config = AppConfig()
        config.showScheduledMeetingNotifications = false
        config.showMeetingDetectionNotification = false
        config.autoRecordMeetings = true

        #expect(!MeetingFeatureMonitorPolicy.shouldStartFeatureMonitors(config: config))
    }

    @Test("scheduled notifications start calendar monitors")
    func scheduledNotificationsStartCalendarMonitors() {
        var config = AppConfig()
        config.showScheduledMeetingNotifications = true
        config.showMeetingDetectionNotification = false
        config.autoRecordMeetings = false

        #expect(MeetingFeatureMonitorPolicy.shouldStartFeatureMonitors(config: config))
    }

    @Test("active auto-stop keeps detection monitor running")
    func activeAutoStopKeepsDetectionMonitorRunning() {
        var config = AppConfig()
        config.showMeetingDetectionNotification = false

        #expect(MeetingFeatureMonitorPolicy.shouldRunDetectionMonitor(
            config: config,
            hasActiveAutoStop: true
        ))
    }

    @Test("foreground mic capture pauses detection monitor")
    func foregroundMicCapturePausesDetectionMonitor() {
        var config = AppConfig()
        config.showMeetingDetectionNotification = true

        #expect(!MeetingFeatureMonitorPolicy.shouldRunDetectionMonitor(
            config: config,
            hasActiveAutoStop: false,
            isForegroundMicCaptureActive: true
        ))
    }

    @Test("active auto-stop overrides foreground mic capture pause")
    func activeAutoStopOverridesForegroundMicCapturePause() {
        var config = AppConfig()
        config.showMeetingDetectionNotification = false

        #expect(MeetingFeatureMonitorPolicy.shouldRunDetectionMonitor(
            config: config,
            hasActiveAutoStop: true,
            isForegroundMicCaptureActive: true
        ))
    }
}
