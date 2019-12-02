import Foundation

// MARK: TraitCollection
extension Notification.Name {
    static let willChangeTraitCollection = Notification.Name("willChangeTraitCollection")
    static let didChangeTraitCollection = Notification.Name("didChangeTraitCollection")
}

// MARK: Transition
extension Notification.Name {
    static let didBeginFloatViewTranslation = Notification.Name("didBeginFloatViewTranslation")
    static let didChangeFloatViewTranslation = Notification.Name("didChangeFloatViewTranslation")
    static let didEndFloatViewTranslation = Notification.Name("didEndFloatViewTranslation")
    
    static let dismissFloatView = Notification.Name("dismissFloatView")
}

enum FloatNotificationProperty: String {
    case translation, velocity, recognizer, traitcollection
}
