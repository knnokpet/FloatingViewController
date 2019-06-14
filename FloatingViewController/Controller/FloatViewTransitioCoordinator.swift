import UIKit

class FloatViewTransitioCoordinator: NSObject, FloatViewTransitionObservable, FloatViewTransitionable {
    
    weak var stackController: FloatStackController?
    
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
            let currentParameter = self.stackController?.currentParameter,
            let shorterHeightConstraint = currentParameter.floatingViewShorterHeightConstraint,
            let tallerHeightConstraint = currentParameter.floatingViewTallerHeightConstraint,
            let heightConstraint = currentParameter.floatingViewHeightConstraint,
            let topSpaceConstraint = currentParameter.floatingViewTopSpaceConstraint
            else {
                return
        }
        
        NSLayoutConstraint.deactivate([tallerHeightConstraint, shorterHeightConstraint, topSpaceConstraint])
        NSLayoutConstraint.activate([heightConstraint])
        currentParameter.floatingViewHeightConstraint?.constant = currentFloatingViewController.view.bounds.height
        self.stackController?.currentFloatingViewHeightConstant = currentFloatingViewController.view.bounds.height
    }
    
    @objc public func handleFloatViewControllerTranslation(_ notification: Notification) {
        guard
            let translation = notification.userInfo?[FloatNotificationProperty.translation] as? CGPoint
            else {
                return
        }
        guard
            let currentParameter = self.stackController?.currentParameter
            else {
                return
        }
        
        if let topSpaceConstraint = currentParameter.floatingViewTopSpaceConstraint, topSpaceConstraint.isActive {
            NSLayoutConstraint.deactivate([topSpaceConstraint])
            if let heightConstraint = currentParameter.floatingViewHeightConstraint, !heightConstraint.isActive {
                self.stackController?.currentFloatingViewHeightConstant = self.stackController?.currentFloatingViewController?.view.bounds.height ?? 0
                NSLayoutConstraint.activate([heightConstraint])
            }
        }
        
        currentParameter.floatingViewHeightConstraint?.constant =  (self.stackController?.currentFloatingViewHeightConstant ?? 0) + (-translation.y)
    }
    
    @objc public func handleFloatViewControllerEnd(_ notification: Notification) {
        guard
            let floatStackController = self.stackController,
            let translation = notification.userInfo?[FloatNotificationProperty.translation] as? CGPoint, let velocity = notification.userInfo?[FloatNotificationProperty.velocity] as? CGPoint
            else {
                return
        }
        
        if abs(translation.y) < 50 {
            if (-100...100).contains(velocity.y) {
                self.move(mode: floatStackController.currentFloatingMode)
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
                self.move(mode: toMode)
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
                self.move(mode: toMode)
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
                self.move(mode: toMode)
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
                self.move(mode: toMode)
            } else {
                if (-100...100).contains(velocity.y) {
                    self.move(mode: floatStackController.currentFloatingMode)
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
                    self.move(mode: toMode)
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
                    self.move(mode: toMode)
                }
            }
            
            
        }
    }
    
    func move(mode: FloatingMode) {
        
        /*
         Use standard UIView animation with layoutIfNeeded
         Always deactivate constraints first
         Hold to your deactivated constraints strongly
         */
        
        guard
            let currentFloatingViewController = self.stackController?.currentFloatingViewController,
            let currentParameter = self.stackController?.currentParameter,
            let shorterHeightConstraint = currentParameter.floatingViewShorterHeightConstraint,
            let tallerHeightConstraint = currentParameter.floatingViewTallerHeightConstraint,
            let heightConstraint = currentParameter.floatingViewHeightConstraint,
            let topSpaceConstraint = currentParameter.floatingViewTopSpaceConstraint
            else {
                return
        }
        
        switch mode {
        case .fullScreen:
            NSLayoutConstraint.deactivate([shorterHeightConstraint, tallerHeightConstraint, heightConstraint])
            NSLayoutConstraint.activate([topSpaceConstraint])
        case .middle:
            NSLayoutConstraint.deactivate([topSpaceConstraint, shorterHeightConstraint, heightConstraint])
            NSLayoutConstraint.activate([tallerHeightConstraint])
            
        case .bottom:
            NSLayoutConstraint.deactivate([topSpaceConstraint, tallerHeightConstraint, heightConstraint])
            NSLayoutConstraint.activate([shorterHeightConstraint])
            
        }
        self.stackController?.currentFloatingMode = mode
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.allowUserInteraction], animations: {
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
            var parameter = self.stackController?.currentParameter
            else {
                return
        }
        
        
        
        let shadowView: UIView? = {
            if
                let previous = self.stackController?.previousFloatingViewController,
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
        
        parameter.floatingViewHeightConstraint?.constant = tallerHeight
        
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
            var parameter = self.stackController?.currentParameter
            else {
                return
        }
        
        let shadowView: UIView? = {
            if
                let previous = self.stackController?.previousFloatingViewController,
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
            parameter.floatingViewTopSpaceConstraint, parameter.floatingViewShorterHeightConstraint, parameter.floatingViewTallerHeightConstraint
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
