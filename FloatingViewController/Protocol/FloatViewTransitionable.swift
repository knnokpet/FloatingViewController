import Foundation

protocol FloatViewTransitionable {
    func present(completionHandler: ((Bool) -> Void)?)
    func remove(completionHandler: ((Bool) -> Void)?)
    func move(mode: FloatingMode, notification: Notification?)
}
