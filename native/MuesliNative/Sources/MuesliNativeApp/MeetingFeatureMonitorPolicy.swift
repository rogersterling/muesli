enum MeetingFeatureMonitorPolicy {
    static func shouldStartFeatureMonitors(config: AppConfig) -> Bool {
        config.showMeetingDetectionNotification
            || config.showScheduledMeetingNotifications
    }

    static func shouldRunDetectionMonitor(config: AppConfig, hasActiveAutoStop: Bool) -> Bool {
        config.showMeetingDetectionNotification || hasActiveAutoStop
    }
}
