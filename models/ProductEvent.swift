import Foundation

// AUTO-GENERATED - DO NOT EDIT 

public enum NotificationSettingsOpenedSource: String {
    case settings
    case onboarding
}

public enum AutoplayToggledValue: String {
    case true
    case false
}

public enum AutoplayToggledSource: String {
    case notification_settings
    case profile_settings
}

public enum MarkAsReadToggledValue: String {
    case true
    case false
}

public enum MiniplayerSeekValue: String {
    case forward
    case back
}

public struct ProductEvent {
    public let name: String
    public let attributes: [String: String]
}

extension ProductEvent {

    /// notification_settings_viewed
    /// - Returns: A ProductEvent for notification_settings_viewed
    public static func notificationSettingsViewed() -> ProductEvent {
        ProductEvent(
            name: "notification_settings_viewed",
            ]
        )
    }

    /// notification_settings_opened
    /// - Parameters:
    ///   - source: Which screen you open from
    /// - Returns: A ProductEvent for notification_settings_opened
    public static func notificationSettingsOpened(source: NotificationSettingsOpenedSource) -> ProductEvent {
        ProductEvent(
            name: "notification_settings_opened",
            attributes: [
            "source": source.rawValue
            ]
        )
    }

    /// autoplay_toggled
    /// - Parameters:
    ///   - value: Which settings toggle
    ///   - source: Which settings screen
    /// - Returns: A ProductEvent for autoplay_toggled
    public static func autoplayToggled(value: AutoplayToggledValue, source: AutoplayToggledSource) -> ProductEvent {
        ProductEvent(
            name: "autoplay_toggled",
            attributes: [
            "value": value.rawValue,
            "source": source.rawValue
            ]
        )
    }

    /// mark_as_read_toggled
    /// - Parameters:
    ///   - value: Which settings toggle
    /// - Returns: A ProductEvent for mark_as_read_toggled
    public static func markAsReadToggled(value: MarkAsReadToggledValue) -> ProductEvent {
        ProductEvent(
            name: "mark_as_read_toggled",
            attributes: [
            "value": value.rawValue
            ]
        )
    }

    /// minimise_player
    /// - Parameters:
    ///   - value: URL of the podcast
    ///   - source: Where event took place, eg. miniplayer
    /// - Returns: A ProductEvent for minimise_player
    public static func minimisePlayer(value: String, source: String) -> ProductEvent {
        ProductEvent(
            name: "minimise_player",
            attributes: [
            "value": value,
            "source": source
            ]
        )
    }

    /// miniplayer_seek
    /// - Parameters:
    ///   - value: Direction of seek
    ///   - source: Where event took place, eg. miniplayer
    /// - Returns: A ProductEvent for miniplayer_seek
    public static func miniplayerSeek(value: MiniplayerSeekValue, source: String) -> ProductEvent {
        ProductEvent(
            name: "miniplayer_seek",
            attributes: [
            "value": value.rawValue,
            "source": source
            ]
        )
    }

    /// podcast_play
    /// - Parameters:
    ///   - value: URL of the podcast
    ///   - source: Where event took place, eg. miniplayer
    /// - Returns: A ProductEvent for podcast_play
    public static func podcastPlay(value: String, source: String) -> ProductEvent {
        ProductEvent(
            name: "podcast_play",
            attributes: [
            "value": value,
            "source": source
            ]
        )
    }

    /// podcast_pause
    /// - Parameters:
    ///   - value: URL of the podcast
    ///   - source: Where event took place, eg. miniplayer
    /// - Returns: A ProductEvent for podcast_pause
    public static func podcastPause(value: String, source: String) -> ProductEvent {
        ProductEvent(
            name: "podcast_pause",
            attributes: [
            "value": value,
            "source": source
            ]
        )
    }

}
