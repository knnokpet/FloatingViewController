import UIKit

protocol FloatViewTransitionable {
    func present(completionHandler: ((Bool) -> Void)?)
    func remove(completionHandler: ((Bool) -> Void)?)
    func move(mode: FloatingMode, recognizer: UIPanGestureRecognizer?, velocity: Float?, duration: Double?)
    //func move(mode: FloatingMode, velocity: Float?, duration: Double?)
}
