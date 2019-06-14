import Foundation

protocol FloatViewTransitionObservable {
    func handleFloatViewControllerBegan(_ notification: Notification)
    func handleFloatViewControllerTranslation(_ notification: Notification)
    func handleFloatViewControllerEnd(_ notification: Notification)
}
