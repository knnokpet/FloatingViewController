import Foundation

// MARK: Transition
extension Notification.Name {
    static let didBeginFloatViewTranslation = Notification.Name("didBeginFloatViewTranslation")
    static let didChangeFloatViewTranslation = Notification.Name("didChangeFloatViewTranslation")
    static let didEndFloatViewTranslation = Notification.Name("didEndFloatViewTranslation")
    
    static let dismissFloatView = Notification.Name("dismissFloatView")
    static let moveFloatView = Notification.Name("moveFloatView")
}

enum FloatNotificationProperty: String {
    case translation, velocity, recognizer, traitcollection, mode, duration
}
