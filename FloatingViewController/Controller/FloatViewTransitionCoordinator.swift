import UIKit

class FloatViewTransitionCoordinator: NSObject, FloatViewTransitionObservable, FloatViewTransitionable {
    
    weak var stackController: FloatStackController?
    
    var beginningTopConstraintConstant: CGFloat = 0
    
    init(stackController: FloatStackController) {
        super.init()
        self.stackController = stackController
        self.registerNotifications()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFloatViewControllerBegan(_:)), name: didBeginFloatViewTranslation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFloatViewControllerTranslation(_:)), name: didChangeFloatViewTranslation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFloatViewControllerEnd(_:)), name: didEndFloatViewTranslation, object: nil)
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
        
        beginningTopConstraintConstant = currentParameter.floatingViewTopSpaceConstraint?.constant ?? 0
    }
    
    @objc public func handleFloatViewControllerTranslation(_ notification: Notification) {
        guard
            let translation = notification.userInfo?[FloatNotificationProperty.translation] as? CGPoint,
            let currentParameter = self.stackController?.currentParameter
            else {
                return
        }
        
        if let topSpaceConstraint = currentParameter.floatingViewTopSpaceConstraint, topSpaceConstraint.isActive {
            
            let topSpaceConstant: CGFloat = {
                let absolutedTranslationY = beginningTopConstraintConstant + translation.y
                
                // Set upper and lower limit
                let mergin: CGFloat = 12.0
                let fullScreenConstant = TopLayoutConstraintCaluculator.calculatedConstant(for: .fullScreen, parentViewController: self.stackController?.parentViewController)
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
            let topSpaceConstraint = currentParameter.floatingViewTopSpaceConstraint
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
            let currentFloatingViewController = self.stackController?.currentFloatingViewController,
            let parameter = self.stackController?.currentParameter
            else {
                return
        }
        
        
        
        let shadowView: UIView? = {
            if
                let previousParameter = self.stackController?.previousParameter
            {
                let shadowView = UIView()
                shadowView.translatesAutoresizingMaskIntoConstraints = false
                parent.view.insertSubview(shadowView, belowSubview: currentFloatingViewController.view)
                shadowView.backgroundColor = .black
                shadowView.layer.cornerRadius = 10.0
                shadowView.layer.masksToBounds = true
                shadowView.layer.opacity = 0.0
                shadowView.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor, constant: 0.0).isActive = true
                shadowView.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor, constant: 0.0).isActive = true
                shadowView.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0.0).isActive = true
                shadowView.heightAnchor.constraint(equalToConstant: (previousParameter.floatingViewHeightConstraint?.constant ?? 0)).isActive = true
                return shadowView
            }
            return nil
        }()
        
        // By calling layoutIfNeeded at once, let view layout be confirmed
        self.stackController?.parentViewController?.view.layoutIfNeeded()
        
        parameter.floatingViewTopSpaceConstraint?.constant = parent.view.bounds.height / 2
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.allowUserInteraction], animations: {
            
            shadowView?.layer.opacity = 0.1
            self.stackController?.parentViewController?.view.layoutIfNeeded()
            
        }, completion: { finished in
            if finished {
                shadowView?.removeFromSuperview()
                self.stackController?.previousFloatingViewController?.view.isHidden = true
            }
            completionHandler?(finished)
        })
    }
    
    func remove(completionHandler: ((Bool) -> Void)?) {
        
        guard
            let parent = self.stackController?.parentViewController,
            let currentFloatingViewController = self.stackController?.currentFloatingViewController,
            let parameter = self.stackController?.currentParameter
            else {
                return
        }
        
        let shadowView: UIView? = {
            if
                let previousParameter = self.stackController?.previousParameter
            {
                let shadowView = UIView()
                shadowView.translatesAutoresizingMaskIntoConstraints = false
                parent.view.insertSubview(shadowView, belowSubview: currentFloatingViewController.view)
                shadowView.backgroundColor = .black
                shadowView.layer.cornerRadius = 10.0
                shadowView.layer.masksToBounds = true
                shadowView.layer.opacity = 0.1
                shadowView.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor, constant: 0.0).isActive = true
                shadowView.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor, constant: 0.0).isActive = true
                shadowView.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0.0).isActive = true
                shadowView.heightAnchor.constraint(equalToConstant: (previousParameter.floatingViewHeightConstraint?.constant ?? 0)).isActive = true
                return shadowView
            }
            return nil
        }()
        // By calling layoutIfNeeded at once, let view layout be confirmed
        self.stackController?.parentViewController?.view.layoutIfNeeded()
        
        if let _ = shadowView {
            self.stackController?.previousFloatingViewController?.view.isHidden = false
        }
        
        let activeConstraints = [
            parameter.floatingViewTopSpaceConstraint
            ]
            .compactMap { $0 }
            .filter { $0.isActive == true }
        
        NSLayoutConstraint.deactivate(activeConstraints)
        parameter.floatingViewHeightConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [], animations: {
            shadowView?.layer.opacity = 0.0
            self.stackController?.parentViewController?.view.layoutIfNeeded()
        }, completion: { finished in
            completionHandler?(finished)
        })
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
