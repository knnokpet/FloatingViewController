import Foundation

let didBeginFloatViewTranslation = Notification.Name("didBeginFloatViewTranslation")
let didChangeFloatViewTranslation = Notification.Name("didChangeFloatViewTranslation")
let didEndFloatViewTranslation = Notification.Name("didEndFloatViewTranslation")

enum FloatNotificationProperty: String {
    case translation, velocity, recognizer
}
