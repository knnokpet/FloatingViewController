import UIKit

protocol FloatViewTransitionCoordinatorDelegate: class {
    func didChangeBackgroundShadowViewVisibility(_ isHidden: Bool, percentage: Float?)
}

class FloatViewTransitionCoordinator: NSObject, FloatViewTransitionObservable, FloatViewTransitionable {
    
    weak var stackController: FloatStackController?
    
    weak var delegate: FloatViewTransitionCoordinatorDelegate?
    
    var beginningTopConstraintConstant: CGFloat = 0
    
    init(stackController: FloatStackController) {
        super.init()
        self.stackController = stackController
        self.registerNotifications()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFloatViewControllerBegan(_:)), name: .didBeginFloatViewTranslation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFloatViewControllerTranslation(_:)), name: .didChangeFloatViewTranslation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFloatViewControllerEnd(_:)), name: .didEndFloatViewTranslation, object: nil)
    }
    
    @objc public func handleFloatViewControllerBegan(_ notification: Notification) {
        guard
            let currentFloatingViewController = self.stackController?.currentFloatingViewController,
            let currentParameter = self.stackController?.currentParameter
            else {
                return
        }
        
        currentParameter.floatingViewHeightConstraint?.constant = currentFloatingViewController.view.bounds.height
        self.stackController?.currentFloatingViewHeightConstant = currentFloatingViewController.view.bounds.height
        
        beginningTopConstraintConstant = currentParameter.activeTopConstraint?.constant ?? 0
    }
    
    @objc public func handleFloatViewControllerTranslation(_ notification: Notification) {
        guard
            let translation = notification.userInfo?[FloatNotificationProperty.translation] as? CGPoint,
            let currentParameter = self.stackController?.currentParameter
            else {
                return
        }
        
        if let topSpaceConstraint = currentParameter.activeTopConstraint {
            
            let fullScreenConstant = TopLayoutConstraintCaluculator.calculatedConstant(for: .fullScreen, containerViewController: self.stackController?.containerViewController)
            let middleConstant = TopLayoutConstraintCaluculator.calculatedConstant(for: .middle, containerViewController: self.stackController?.containerViewController)
            
            let topSpaceConstant: CGFloat = {
                let absolutedTranslationY = beginningTopConstraintConstant + translation.y
                
                // Set upper and lower limit
                let mergin: CGFloat = 12.0
                let bottomConstant = TopLayoutConstraintCaluculator.calculatedConstant(for: .bottom, containerViewController: self.stackController?.containerViewController)
                
                if absolutedTranslationY < fullScreenConstant {
                    let difference = abs(absolutedTranslationY - fullScreenConstant)
                    let percentage = (mergin) / (difference + mergin)
                    return fullScreenConstant - (mergin - mergin * percentage)
                } else if absolutedTranslationY > bottomConstant {
                    let difference = abs(absolutedTranslationY - bottomConstant)
                    let percentage = (mergin) / (difference + mergin)
                    return bottomConstant + (mergin - mergin * percentage)
                } else {
                    return absolutedTranslationY
                }
            }()
            
            // shadow
            if self.stackController?.containerViewController.traitCollection.verticalSizeClass == .regular {
                if (fullScreenConstant...middleConstant).contains(topSpaceConstant) {
                    let max = middleConstant - fullScreenConstant
                    let current = topSpaceConstant - fullScreenConstant
                    let percentage = 1 - current / max
                    delegate?.didChangeBackgroundShadowViewVisibility(false, percentage: Float(percentage))
                }
            }
            
            
            topSpaceConstraint.constant = topSpaceConstant
        }
        
        currentParameter.floatingViewHeightConstraint?.constant =  (self.stackController?.currentFloatingViewHeightConstant ?? 0) + (-translation.y)
    }
    
    @objc public func handleFloatViewControllerEnd(_ notification: Notification) {
        guard
            let floatStackController = self.stackController,
            let translation = notification.userInfo?[FloatNotificationProperty.translation] as? CGPoint,
            let recognizer = notification.userInfo?[FloatNotificationProperty.recognizer] as? UIPanGestureRecognizer
            else {
                return
        }
        
        let velocity: CGPoint = recognizer.velocity(in: self.stackController?.containerViewController.view)
        
        if abs(translation.y) < 50 {
            if (-100...100).contains(velocity.y) {
                self.move(mode: floatStackController.currentFloatingMode, notification: notification)
            } else if velocity.y < -100 {
                let toMode: FloatingMode = {
                    switch floatStackController.currentFloatingMode {
                    case .middle:
                        return .fullScreen
                    case .fullScreen:
                        return .fullScreen
                    case .bottom:
                        return .middle
                    case .progressing:
                        return .progressing
                    }
                }()
                self.move(mode: toMode, notification: nil)
            } else if velocity.y > 100 {
                let toMode: FloatingMode = {
                    switch floatStackController.currentFloatingMode {
                    case .middle:
                        return .bottom
                    case .fullScreen:
                        return .middle
                    case .bottom:
                        return .bottom
                    case .progressing:
                        return .progressing
                    }
                }()
                self.move(mode: toMode, notification: notification)
            }
        } else {
            #warning("TO DO ADJUSTMENT")
            let _ = recognizer.location(in: self.stackController?.containerViewController.view)
            if translation.y < -50 {
                let toMode: FloatingMode = {
                    switch floatStackController.currentFloatingMode {
                    case .middle:
                        return .fullScreen
                    case .fullScreen:
                        return .fullScreen
                    case .bottom:
                        if translation.y < -400 {
                            return .fullScreen
                        }
                        return .middle
                    case .progressing:
                        return .progressing
                    }
                }()
                self.move(mode: toMode, notification: nil)
            } else if translation.y > 50 {
                let toMode: FloatingMode = {
                    switch floatStackController.currentFloatingMode {
                    case .middle:
                        return .bottom
                    case .fullScreen:
                        if translation.y > 400 {
                            return .bottom
                        }
                        return .middle
                    case .bottom:
                        return .bottom
                    case .progressing:
                        return .progressing
                    }
                }()
                self.move(mode: toMode, notification: nil)
            } else {
                if (-100...100).contains(velocity.y) {
                    self.move(mode: floatStackController.currentFloatingMode, notification: notification)
                } else if velocity.y < -100 {
                    let toMode: FloatingMode = {
                        switch floatStackController.currentFloatingMode {
                        case .middle:
                            return .fullScreen
                        case .fullScreen:
                            return .fullScreen
                        case .bottom:
                            return .middle
                        case .progressing:
                            return .progressing
                        }
                    }()
                    self.move(mode: toMode, notification: notification)
                } else if velocity.y > 100 {
                    let toMode: FloatingMode = {
                        switch floatStackController.currentFloatingMode {
                        case .middle:
                            return .bottom
                        case .fullScreen:
                            return .middle
                        case .bottom:
                            return .bottom
                        case .progressing:
                            return .progressing
                        }
                    }()
                    self.move(mode: toMode, notification: notification)
                }
            }
            
            
        }
    }
    
    func move(mode: FloatingMode, notification: Notification? = nil) {
        
        /*
         Use standard UIView animation with layoutIfNeeded
         Always deactivate constraints first
         Hold to your deactivated constraints strongly
         */
        
        guard
            let currentParameter = self.stackController?.currentParameter,
            let topSpaceConstraint = currentParameter.activeTopConstraint
            else {
                return
        }
        
        let topSpaceConstraintConstantForMode = TopLayoutConstraintCaluculator.calculatedConstant(for: mode, containerViewController: self.stackController?.containerViewController)
        let merginBetweenTopConstraints = abs(topSpaceConstraint.constant - topSpaceConstraintConstantForMode)
        
        NSLayoutConstraint.activate([topSpaceConstraint])
        topSpaceConstraint.constant = topSpaceConstraintConstantForMode
        self.stackController?.currentFloatingMode = mode
        
        let velocity: CGFloat = {
            guard
                let recognizer = (notification?.userInfo?[FloatNotificationProperty.recognizer] as? UIPanGestureRecognizer) else
            {
                return 0.0
            }
            
            let velocityFromGesture: CGPoint = recognizer.velocity(in: self.stackController?.containerViewController.view)
            
            return abs(velocityFromGesture.y / merginBetweenTopConstraints)
        }()
        
        let duration: Double = (notification?.userInfo?[FloatNotificationProperty.duration] as? NSNumber)?.doubleValue ?? 0.5
                
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: velocity, options: [.allowUserInteraction], animations: {
            self.stackController?.containerViewController.view.layoutIfNeeded()
            
            if self.stackController?.containerViewController.traitCollection.verticalSizeClass == .regular {
                self.delegate?.didChangeBackgroundShadowViewVisibility((mode != .fullScreen), percentage: nil)
            }
            
        }, completion: { finished in
            if finished {
                currentParameter.floatingViewHeightConstraint?.constant = self.stackController?.currentFloatingViewController?.view.bounds.height ?? 0
                self.stackController?.currentFloatingViewHeightConstant = self.stackController?.currentFloatingViewController?.view.bounds.height ?? 0
            }
        })
    }
    
    func present(completionHandler: ((Bool) -> Void)?) {
        guard
            let container = self.stackController?.containerViewController,
            let _ = self.stackController?.currentFloatingViewController,
            let parameter = self.stackController?.currentParameter
            else {
                return
        }

        #warning("In iOS12, it causes presentation with wrong animation")
        // layoutIfNeeded のタイミングのせいか、この call の前後で parameter.activeTC が変化してる・・
        // By calling layoutIfNeeded at once, let view layout be confirmed
        self.stackController?.containerViewController.view.layoutIfNeeded()
        
        parameter.activeTopConstraint?.constant = container.view.bounds.height / 2
        
        // For Previous
        if let previousViewController = self.stackController?.previousFloatingViewController as? Floatable {
            UIView.animate(withDuration: 0.3, animations: {
                previousViewController.shadowView.isHiddenShadowView = false
            }) { (isFinished) in
                if isFinished {
                    UIView.animate(withDuration: 0.3, animations: {
                        previousViewController.view.layer.opacity = 0.0
                    }, completion: nil)
                }
            }
        }
        
        
        // For Current
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.allowUserInteraction], animations: {
            
            self.stackController?.containerViewController.view.layoutIfNeeded()
            
        }, completion: { finished in
            completionHandler?(finished)
        })
    }
    
    func remove(completionHandler: ((Bool) -> Void)?) {
        
        guard
            let container = self.stackController?.containerViewController,
            let _ = self.stackController?.currentFloatingViewController,
            let parameter = self.stackController?.currentParameter
            else {
                return
        }

        // By calling layoutIfNeeded at once, let view layout be confirmed
        self.stackController?.containerViewController.view.layoutIfNeeded()
        
        parameter.activeTopConstraint?.constant = container.view.bounds.height
        
        if let previousViewController = self.stackController?.previousFloatingViewController as? Floatable {
            previousViewController.shadowView.isHiddenShadowView = false
            previousViewController.view.layer.opacity = 1.0
            UIView.animate(withDuration: 0.3, animations: {
                previousViewController.shadowView.isHiddenShadowView = true
            }, completion: nil)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [], animations: {
            self.stackController?.containerViewController.view.layoutIfNeeded()
            
            if self.stackController?.containerViewController.traitCollection.verticalSizeClass == .regular {
                self.delegate?.didChangeBackgroundShadowViewVisibility(true, percentage: nil)
            }
            
        }, completion: { finished in
            completionHandler?(finished)
        })
    }
    
}

extension FloatViewTransitionCoordinator {
    
    internal func handleTraitcollectionWillChange(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {

    }
    
    internal func handleTraitcollectionDidChange(_ previousTraitCollection: UITraitCollection?, currentTraitCollection: UITraitCollection) {
        
        guard
            let currentViewController = self.stackController?.currentFloatingViewController
        else { return }
        
        self.updateConstraints()
        self.updateShadowView(with: currentTraitCollection)
        
        if currentTraitCollection.verticalSizeClass == .compact { // landscape
            #warning("NOT OPTIMIZED FOR NON FULL EDGE PHONE")
            
            self.stackController?.currentParameter?.portraitTopConstraint?.isActive = false
            self.stackController?.currentParameter?.portraitLeftConstraint?.isActive = false
            self.stackController?.currentParameter?.portraitRightConstraint?.isActive = false
            self.stackController?.currentParameter?.portraitBottomConstraint?.isActive = false
            
            self.stackController?.currentParameter?.landscapeTopConstraint?.isActive = true
            self.stackController?.currentParameter?.landscapeLeftConstraint?.isActive = true
            self.stackController?.currentParameter?.landscapeWidthConstraint?.isActive = true
            self.stackController?.currentParameter?.landscapeBottomConstraint?.isActive = true
            
        } else if currentTraitCollection.verticalSizeClass == .regular { // portrait
            
            self.stackController?.currentParameter?.landscapeTopConstraint?.isActive = false
            self.stackController?.currentParameter?.landscapeLeftConstraint?.isActive = false
            self.stackController?.currentParameter?.landscapeWidthConstraint?.isActive = false
            self.stackController?.currentParameter?.landscapeBottomConstraint?.isActive = false
            
            self.stackController?.currentParameter?.portraitTopConstraint?.isActive = true
            self.stackController?.currentParameter?.portraitLeftConstraint?.isActive = true
            self.stackController?.currentParameter?.portraitRightConstraint?.isActive = true
            self.stackController?.currentParameter?.portraitBottomConstraint?.isActive = true
        }
        
        self.stackController?.containerViewController.view.layoutIfNeeded()
        currentViewController.view.layoutIfNeeded()
    }
    
    private func updateConstraints() {
        
        guard
            let mode =  self.stackController?.currentFloatingMode
        else { return }
        let constant = TopLayoutConstraintCaluculator.calculatedConstant(for: mode, containerViewController: self.stackController?.containerViewController)
        if let current = self.stackController?.currentParameter {
            current.portraitTopConstraint?.constant = constant
            current.landscapeTopConstraint?.constant = constant
            self.stackController?.setCurrentParameter(current)
        }
    }
    
    private func updateShadowView(with traitCollection: UITraitCollection) {
        UIView.animate(withDuration: 0.3) {
            if traitCollection.verticalSizeClass == .compact {
                self.delegate?.didChangeBackgroundShadowViewVisibility(true, percentage: nil)
            } else {
                self.delegate?.didChangeBackgroundShadowViewVisibility((self.stackController?.currentFloatingMode != .fullScreen), percentage: nil)
                
            }
        }
    }
}


private final class TopLayoutConstraintCaluculator {
    class func calculatedConstant(for mode:FloatingMode, containerViewController: UIViewController?) -> CGFloat {
        
        guard let container = containerViewController else { return 0.0}
        
        #warning("NEED TO CHANGE TO PRACTICAL VALUE")
        switch mode {
        case .fullScreen:
            return container.view.safeAreaInsets.top
        case .middle:
            return container.view.bounds.height / 2
        case .bottom:
            return container.view.bounds.height / 1.3
        case .progressing:
            return 0
        }
    }
}
