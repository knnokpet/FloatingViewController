import UIKit

class FloatViewTransitionCoordinator: NSObject, FloatViewTransitionObservable, FloatViewTransitionable {
    
    weak var stackController: FloatStackController?
    
    var beginningTopConstraintConstant: CGFloat = 0
    
    init(stackController: FloatStackController) {
        super.init()
        self.stackController = stackController
        self.registerNotifications()
        self.registerNofiticationForTraitCollection()
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
            
            let fullScreenConstant = TopLayoutConstraintCaluculator.calculatedConstant(for: .fullScreen, parentViewController: self.stackController?.parentViewController)
            let middleConstant = TopLayoutConstraintCaluculator.calculatedConstant(for: .middle, parentViewController: self.stackController?.parentViewController)
            
            let topSpaceConstant: CGFloat = {
                let absolutedTranslationY = beginningTopConstraintConstant + translation.y
                
                // Set upper and lower limit
                let mergin: CGFloat = 12.0
                let bottomConstant = TopLayoutConstraintCaluculator.calculatedConstant(for: .bottom, parentViewController: self.stackController?.parentViewController)
                
                if absolutedTranslationY < fullScreenConstant {
                    let difference = abs(absolutedTranslationY - fullScreenConstant) + mergin
                    let percentage = mergin / difference
                    return beginningTopConstraintConstant + (translation.y * percentage)
                } else if absolutedTranslationY > bottomConstant {
                    let difference = abs(absolutedTranslationY - bottomConstant) + mergin
                    let percentage = mergin / difference
                    return beginningTopConstraintConstant + (translation.y * percentage)
                } else {
                    return absolutedTranslationY
                }
            }()
            
            // shadow
            if self.stackController?.parentViewController?.traitCollection.verticalSizeClass == .regular {
                if (fullScreenConstant...middleConstant).contains(topSpaceConstant) {
                    let max = middleConstant - fullScreenConstant
                    let current = topSpaceConstant - fullScreenConstant
                    let percentage = 1 - current / max
                    self.stackController?.shadowView?.setShadowVisibility(percentage)
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
        
        let velocity: CGPoint = recognizer.velocity(in: self.stackController?.parentViewController?.view)
        
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
                    }
                }()
                self.move(mode: toMode, notification: notification)
            }
        } else {
            if translation.y < -50 {
                let toMode: FloatingMode = {
                    switch floatStackController.currentFloatingMode {
                    case .middle:
                        return .fullScreen
                    case .fullScreen:
                        return .fullScreen
                    case .bottom:
                        return .middle
                    }
                }()
                self.move(mode: toMode, notification: nil)
            } else if translation.y > 50 {
                let toMode: FloatingMode = {
                    switch floatStackController.currentFloatingMode {
                    case .middle:
                        return .bottom
                    case .fullScreen:
                        return .middle
                    case .bottom:
                        return .bottom
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
        
        let topSpaceConstraintConstantForMode = TopLayoutConstraintCaluculator.calculatedConstant(for: mode, parentViewController: self.stackController?.parentViewController)
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
            
            let velocityFromGesture: CGPoint = recognizer.velocity(in: self.stackController?.parentViewController?.view)
            
            return abs(velocityFromGesture.y / merginBetweenTopConstraints)
        }()
                
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: velocity, options: [.allowUserInteraction], animations: {
            self.stackController?.parentViewController?.view.layoutIfNeeded()
            
            if self.stackController?.parentViewController?.traitCollection.verticalSizeClass == .regular {
                self.stackController?.shadowView?.isHiddenShadowView = mode != .fullScreen
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
            let parent = self.stackController?.parentViewController,
            let _ = self.stackController?.currentFloatingViewController,
            let parameter = self.stackController?.currentParameter
            else {
                return
        }

        #warning("In iOS12, it causes presentation with wrong animation")
        // layoutIfNeeded のタイミングのせいか、この call の前後で parameter.activeTC が変化してる・・
        // By calling layoutIfNeeded at once, let view layout be confirmed
        self.stackController?.parentViewController?.view.layoutIfNeeded()
        
        parameter.activeTopConstraint?.constant = parent.view.bounds.height / 2
        
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
            
            self.stackController?.parentViewController?.view.layoutIfNeeded()
            
        }, completion: { finished in
            completionHandler?(finished)
        })
    }
    
    func remove(completionHandler: ((Bool) -> Void)?) {
        
        guard
            let parent = self.stackController?.parentViewController,
            let _ = self.stackController?.currentFloatingViewController,
            let parameter = self.stackController?.currentParameter
            else {
                return
        }

        // By calling layoutIfNeeded at once, let view layout be confirmed
        self.stackController?.parentViewController?.view.layoutIfNeeded()
        
        parameter.activeTopConstraint?.constant = parent.view.bounds.height
        
        if let previousViewController = self.stackController?.previousFloatingViewController as? Floatable {
            previousViewController.shadowView.isHiddenShadowView = false
            previousViewController.view.layer.opacity = 1.0
            UIView.animate(withDuration: 0.3, animations: {
                previousViewController.shadowView.isHiddenShadowView = true
            }, completion: nil)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [], animations: {
            self.stackController?.parentViewController?.view.layoutIfNeeded()
            
            if self.stackController?.parentViewController?.traitCollection.verticalSizeClass == .regular {
                self.stackController?.shadowView?.isHiddenShadowView = true
            }
            
        }, completion: { finished in
            completionHandler?(finished)
        })
    }
    
}

extension FloatViewTransitionCoordinator {
    private func registerNofiticationForTraitCollection() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTraitcollectionWillChange), name: .willChangeTraitCollection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTraitcollectionDidChange), name: .didChangeTraitCollection, object: nil)
    }
    
    @objc public func handleTraitcollectionWillChange(_ notification: Notification) {
        guard let _ = notification.userInfo?[FloatNotificationProperty.traitcollection] as? UITraitCollection else {
            return
        }
    }
    
    @objc public func handleTraitcollectionDidChange(_ notification: Notification) {
        guard let traitCollection = notification.userInfo?[FloatNotificationProperty.traitcollection] as? UITraitCollection else {
            return
        }
        
        guard
            let currentViewController = self.stackController?.currentFloatingViewController,
            let parentViewController = self.stackController?.parentViewController
        else { return }
        
        self.updateConstraints()
        self.updateShadowView(with: traitCollection)
        
        if traitCollection.verticalSizeClass == .compact { // landscape
            #warning("NOT OPTIMIZED FOR NON FULL EDGE PHONE")
            
            self.stackController?.currentParameter?.portraitTopConstraint?.isActive = false
            self.stackController?.currentParameter?.portraitLeftConstraint?.isActive = false
            self.stackController?.currentParameter?.portraitRightConstraint?.isActive = false
            self.stackController?.currentParameter?.portraitBottomConstraint?.isActive = false
            
            self.stackController?.currentParameter?.landscapeTopConstraint?.isActive = true
            self.stackController?.currentParameter?.landscapeLeftConstraint?.isActive = true
            self.stackController?.currentParameter?.landscapeWidthConstraint?.isActive = true
            self.stackController?.currentParameter?.landscapeBottomConstraint?.isActive = true
            
        } else if traitCollection.verticalSizeClass == .regular { // portrait
            
            self.stackController?.currentParameter?.landscapeTopConstraint?.isActive = false
            self.stackController?.currentParameter?.landscapeLeftConstraint?.isActive = false
            self.stackController?.currentParameter?.landscapeWidthConstraint?.isActive = false
            self.stackController?.currentParameter?.landscapeBottomConstraint?.isActive = false
            
            self.stackController?.currentParameter?.portraitTopConstraint?.isActive = true
            self.stackController?.currentParameter?.portraitLeftConstraint?.isActive = true
            self.stackController?.currentParameter?.portraitRightConstraint?.isActive = true
            self.stackController?.currentParameter?.portraitBottomConstraint?.isActive = true
        }
        
        parentViewController.view.layoutIfNeeded()
        currentViewController.view.layoutIfNeeded()
    }
    
    private func updateConstraints() {
        
        guard
            let mode =  self.stackController?.currentFloatingMode,
            let parent = self.stackController?.parentViewController
        else { return }
        
        let constant = TopLayoutConstraintCaluculator.calculatedConstant(for: mode, parentViewController: parent)
        if let current = self.stackController?.currentParameter {
            current.portraitTopConstraint?.constant = constant
            current.landscapeTopConstraint?.constant = constant
            self.stackController?.setCurrentParameter(current)
        }
    }
    
    private func updateShadowView(with traitCollection: UITraitCollection) {
        UIView.animate(withDuration: 0.3) {
            if traitCollection.verticalSizeClass == .compact {
                self.stackController?.shadowView?.isHiddenShadowView = true
            } else {
                if self.stackController?.currentFloatingMode == .fullScreen {
                    self.stackController?.shadowView?.isHiddenShadowView = false
                } else {
                    self.stackController?.shadowView?.isHiddenShadowView = true
                }
                
            }
        }
    }
}


private final class TopLayoutConstraintCaluculator {
    class func calculatedConstant(for mode:FloatingMode, parentViewController: UIViewController?) -> CGFloat {
        
        guard let parent = parentViewController else { return 0.0}
        
        #warning("NEED TO CHANGE TO PRACTICAL VALUE")
        switch mode {
        case .fullScreen:
            return parent.view.safeAreaInsets.top
        case .middle:
            return parent.view.bounds.height / 2
        case .bottom:
            return parent.view.bounds.height / 1.3
        }
    }
}
