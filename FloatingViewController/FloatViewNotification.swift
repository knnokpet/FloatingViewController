import Foundation

extension Notification.Name {
    static let didBeginFloatViewTranslation = Notification.Name("didBeginFloatViewTranslation")
    static let didChangeFloatViewTranslation = Notification.Name("didChangeFloatViewTranslation")
    static let didEndFloatViewTranslation = Notification.Name("didEndFloatViewTranslation")
}

enum FloatNotificationProperty: String {
    case translation, velocity, recognizer
}
