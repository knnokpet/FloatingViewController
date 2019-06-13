import UIKit

public enum FloatingMode {
    case fullScreen, middle, bottom
}

let tallerHeight: CGFloat = 360
let shorterHeight: CGFloat = 120

class FloatStackController: NSObject {
    
    weak var parentViewController: UIViewController?
    var translationController: FloatViewTranslationController?
    
    init(parentViewController: UIViewController) {
        super.init()
        self.parentViewController = parentViewController
        self.translationController = FloatViewTranslationController(stackController: self)
    }
    
    
    internal var currentFloatingViewController: UIViewController? {
        guard viewControllers.count > 0 else {
            return nil
        }
        return viewControllers[0]
    }
    
    internal var currentParameter: FloatingViewParameter? {
        guard parameters.count > 0 else {
            return nil
        }
        return parameters[0]
    }
    
    var numberOfViewControllers: Int {
        return self.viewControllers.count
    }
    
    var currentFloatingViewHeightConstant: CGFloat = 0
    
    private var viewControllers: [UIViewController] = []
    private var parameters: [FloatingViewParameter] = []
    
    internal var currentFloatingMode: FloatingMode = .middle
    
    internal func add(childViewController viewController: UIViewController) {
        
        guard let parent = self.parentViewController else { return }
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(viewController)
        parent.view.addSubview(viewController.view)
        
        //TODO: REFACTOR
        let topSpaceConstraint = viewController.view.topAnchor.constraint(equalTo: parent.view.topAnchor, constant: parent.view.safeAreaInsets.top)
        topSpaceConstraint.priority = .defaultHigh
        topSpaceConstraint.isActive = true
        
        let shorterHeightConstraint =  viewController.view.heightAnchor.constraint(equalToConstant: shorterHeight)
        shorterHeightConstraint.priority = .defaultHigh
        shorterHeightConstraint.isActive = true
        
        let strechingHeightConstraint =  viewController.view.heightAnchor.constraint(equalToConstant: tallerHeight)
        strechingHeightConstraint.priority = .defaultHigh
        strechingHeightConstraint.isActive = true
        
        let tallerHeightConstraint =  viewController.view.heightAnchor.constraint(equalToConstant: tallerHeight)
        tallerHeightConstraint.priority = .defaultHigh
        tallerHeightConstraint.isActive = true
        
        let parameter: FloatingViewParameter = FloatingViewParameter(floatingViewShorterHeightConstraint: shorterHeightConstraint, floatingViewTallerHeightConstraint: tallerHeightConstraint, floatingViewHeightConstraint: strechingHeightConstraint, floatingViewTopSpaceConstraint: topSpaceConstraint)
        self.add(viewController: viewController, parameter: parameter)
        
        viewController.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor, constant: 0.0).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor, constant: 0.0).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0.0).isActive = true
        
//        self.translationController?.present(completionHandler: { (finished) in
//            if finished {
//
//            }
//        })
        
        viewController.didMove(toParent: parent)
        
    }
    
    private func add(viewController: UIViewController, parameter: FloatingViewParameter) {
        self.viewControllers.insert(viewController, at: 0)
        self.parameters.insert(parameter, at: 0)
    }
    
    internal func removeCurrentViewController() {
        guard
            let parent = self.parentViewController else
        {
                return
        }
    }
}


protocol FloatViewTranslationObservable {
    func handleFloatViewControllerBegan(_ notification: Notification)
    func handleFloatViewControllerTranslation(_ notification: Notification)
    func handleFloatViewControllerEnd(_ notification: Notification)
}

protocol FloatViewTranslationable {
    func present(completionHandler: ((Bool) -> Void)?)
    func remove(completionHandler: ((Bool) -> Void)?)
    func move(mode: FloatingMode)
}

class FloatViewTranslationController: NSObject, FloatViewTranslationObservable, FloatViewTranslationable {
    
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
        
        let tallerHeightConstraint =  currentFloatingViewController.view.heightAnchor.constraint(equalToConstant: 0.0)
        tallerHeightConstraint.priority = .defaultHigh
        tallerHeightConstraint.isActive = true
        parameter.floatingViewTallerHeightConstraint = tallerHeightConstraint
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.allowUserInteraction], animations: {
            self.stackController?.parentViewController?.view.layoutIfNeeded()
        }, completion: { finished in
            completionHandler?(finished)
        })
    }
    
    func remove(completionHandler: ((Bool) -> Void)?) {
        
    }
}
