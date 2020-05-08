import Foundation

protocol FloatViewTransitionObservable {
    func handleFloatViewControllerBeganTranslation(_ notification: Notification)
    func handleFloatViewControllerTranslation(_ notification: Notification)
    func handleFloatViewControllerEndTranslation(_ notification: Notification)
}
