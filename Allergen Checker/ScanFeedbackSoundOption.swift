import AudioToolbox
import Foundation

struct ScanFeedbackSoundOption: Identifiable, Hashable {
    let id: String
    let name: String
    let systemSoundID: SystemSoundID
}

enum ScanFeedbackSoundCatalog {
    static let positiveStorageKey = "scanPositiveSoundOptionID"
    static let negativeStorageKey = "scanNegativeSoundOptionID"

    static let positiveOptions: [ScanFeedbackSoundOption] = [
        .init(id: "iphone_ding", name: "iPhone Ding", systemSoundID: 1104),
        .init(id: "chime", name: "Soft Chime", systemSoundID: 1025),
        .init(id: "bright_pop", name: "Bright Pop", systemSoundID: 1057),
        .init(id: "quick_note", name: "Quick Note", systemSoundID: 1110),
        .init(id: "new_mail", name: "New Mail", systemSoundID: 1000),
        .init(id: "mail_sent", name: "Mail Sent", systemSoundID: 1001),
        .init(id: "new_voicemail", name: "Voicemail", systemSoundID: 1002),
        .init(id: "message_received_positive", name: "Message Received", systemSoundID: 1003),
        .init(id: "sent_message", name: "Sent Message", systemSoundID: 1004),
        .init(id: "tweet_sent", name: "Tweet Sent", systemSoundID: 1016),
        .init(id: "swoosh", name: "Swoosh", systemSoundID: 1018),
        .init(id: "popcorn", name: "Popcorn", systemSoundID: 1020),
        .init(id: "shake", name: "Shake", systemSoundID: 1109),
        .init(id: "beep_beep", name: "Beep Beep", systemSoundID: 1111),
        .init(id: "short_double", name: "Short Double", systemSoundID: 1112),
        .init(id: "triple_tick", name: "Triple Tick", systemSoundID: 1113),
        .init(id: "quick_ping", name: "Quick Ping", systemSoundID: 1114)
    ]

    static let negativeOptions: [ScanFeedbackSoundOption] = [
        .init(id: "gentle_warning", name: "Gentle Warning", systemSoundID: 1053),
        .init(id: "low_tone", name: "Low Tone", systemSoundID: 1073),
        .init(id: "soft_buzz", name: "Soft Buzz", systemSoundID: 1074),
        .init(id: "double_tap", name: "Double Tap", systemSoundID: 1102),
        .init(id: "received_message", name: "Received Message", systemSoundID: 1003),
        .init(id: "alarm", name: "Alarm", systemSoundID: 1005),
        .init(id: "low_power", name: "Low Power", systemSoundID: 1006),
        .init(id: "anticipate", name: "Anticipate", systemSoundID: 1021),
        .init(id: "bloom", name: "Bloom", systemSoundID: 1050),
        .init(id: "calypso", name: "Calypso", systemSoundID: 1051),
        .init(id: "choo_choo", name: "Choo Choo", systemSoundID: 1052),
        .init(id: "descent", name: "Descent", systemSoundID: 1054),
        .init(id: "fanfare", name: "Fanfare", systemSoundID: 1023),
        .init(id: "ladder", name: "Ladder", systemSoundID: 1024),
        .init(id: "noir", name: "Noir", systemSoundID: 1055),
        .init(id: "spell", name: "Spell", systemSoundID: 1056)
    ]

    static let defaultPositiveOptionID = positiveOptions[0].id
    static let defaultNegativeOptionID = negativeOptions[0].id

    static func positiveOption(for id: String) -> ScanFeedbackSoundOption {
        positiveOptions.first(where: { $0.id == id }) ?? positiveOptions[0]
    }

    static func negativeOption(for id: String) -> ScanFeedbackSoundOption {
        negativeOptions.first(where: { $0.id == id }) ?? negativeOptions[0]
    }
}

enum ScanFeedbackPlayer {
    static func play(_ option: ScanFeedbackSoundOption) {
        // System sounds respect the device silent setting.
        AudioServicesPlaySystemSound(option.systemSoundID)
    }
}
