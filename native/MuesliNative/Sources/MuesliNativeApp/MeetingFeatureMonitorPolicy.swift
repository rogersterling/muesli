enum MeetingFeatureMonitorPolicy {
    static func shouldStartFeatureMonitors(config: AppConfig) -> Bool {
        config.showMeetingDetectionNotification
            || config.showScheduledMeetingNotifications
    }

    static func shouldRunDetectionMonitor(
        config: AppConfig,
        hasActiveAutoStop: Bool,
        isForegroundMicCaptureActive: Bool = false
    ) -> Bool {
        if hasActiveAutoStop { return true }
        guard !isForegroundMicCaptureActive else { return false }
        return config.showMeetingDetectionNotification
    }
}
