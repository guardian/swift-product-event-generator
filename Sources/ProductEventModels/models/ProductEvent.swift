import Foundation

// AUTO-GENERATED - DO NOT EDIT 


public enum NotificationSettingsOpenedSource: String {
    case settings
    case onboarding
}

public enum AutoplayToggledValue: String {
    case `true`
    case `false`
}

public enum AutoplayToggledSource: String {
    case settings
}

public enum MarkAsReadToggledValue: String {
    case `true`
    case `false`
}

public enum MiniplayerSeekValue: String {
    case forward
    case back
}
public struct ProductEvent {
    public let name: String
    public let attributes: [String: String]?
    public init(name: String, attributes: [String: String]? = nil) {
        self.name = name
        self.attributes = attributes
    }
}

extension ProductEvent {

    /// User has viewed notification settings
    public static func notificationSettingsViewed() -> ProductEvent {
        ProductEvent(
            name: "notification_settings_viewed"
        )
    }

    /// User has opened notification settings
    ///
    /// - Parameters:
    ///   - source: Which screen you open from
    public static func notificationSettingsOpened(
        source: NotificationSettingsOpenedSource
    ) -> ProductEvent {
        ProductEvent(
            name: "notification_settings_opened",
            attributes: [
                "source": source.rawValue
            ]
        )
    }

    /// User has enabled settings toggle
    ///
    /// - Parameters:
    ///   - value: Which settings toggle
    ///   - source: Which settings screen
    public static func autoplayToggled(
        value: AutoplayToggledValue,
        source: AutoplayToggledSource
    ) -> ProductEvent {
        ProductEvent(
            name: "autoplay_toggled",
            attributes: [
                "value": value.rawValue,
                "source": source.rawValue
            ]
        )
    }

    /// User has enabled mark as read toggle
    ///
    /// - Parameters:
    ///   - value: Which settings toggle
    public static func markAsReadToggled(
        value: MarkAsReadToggledValue
    ) -> ProductEvent {
        ProductEvent(
            name: "mark_as_read_toggled",
            attributes: [
                "value": value.rawValue
            ]
        )
    }

    /// User minimised the podcast player
    ///
    /// - Parameters:
    ///   - value: URL of the podcast
    ///   - source: Where event took place, eg. miniplayer
    public static func minimisePlayer(
        value: String,
        source: String
    ) -> ProductEvent {
        ProductEvent(
            name: "minimise_player",
            attributes: [
                "value": value,
                "source": source
            ]
        )
    }

    /// User seeked audio in miniplayer
    ///
    /// - Parameters:
    ///   - value: Direction of seek
    ///   - source: Where event took place, eg. miniplayer
    public static func miniplayerSeek(
        value: MiniplayerSeekValue,
        source: String
    ) -> ProductEvent {
        ProductEvent(
            name: "miniplayer_seek",
            attributes: [
                "value": value.rawValue,
                "source": source
            ]
        )
    }

    /// User played podcast
    ///
    /// - Parameters:
    ///   - value: URL of the podcast
    ///   - source: Where event took place, eg. miniplayer
    public static func podcastPlay(
        value: String,
        source: String
    ) -> ProductEvent {
        ProductEvent(
            name: "podcast_play",
            attributes: [
                "value": value,
                "source": source
            ]
        )
    }

    /// User paused podcast
    ///
    /// - Parameters:
    ///   - value: URL of the podcast
    ///   - source: Where event took place, eg. miniplayer
    public static func podcastPause(
        value: String,
        source: String
    ) -> ProductEvent {
        ProductEvent(
            name: "podcast_pause",
            attributes: [
                "value": value,
                "source": source
            ]
        )
    }
}