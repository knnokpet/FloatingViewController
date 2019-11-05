import UIKit

public enum FloatingMode {
    case fullScreen, middle, bottom
}

let tallerHeight: CGFloat = 360
let shorterHeight: CGFloat = 120

class FloatStackController: NSObject {
    
    weak var parentViewController: UIViewController?
    var transitionCoordinator: FloatViewTransitionCoordinator?
    
    init(parentViewController: UIViewController) {
        super.init()
        self.parentViewController = parentViewController
        self.transitionCoordinator = FloatViewTransitionCoordinator(stackController: self)
    }
    
    
    internal var currentFloatingViewController: UIViewController? {
        guard viewControllers.count > 0 else {
            return nil
        }
        return viewControllers[0]
    }
    
    internal var currentParameter: FloatingViewLayoutConstraintParameter? {
        guard parameters.count > 0 else {
            return nil
        }
        return parameters[0]
    }
    
    internal var previousFloatingViewController: UIViewController? {
        guard viewControllers.count > 1 else {
            return nil
        }
        return viewControllers[1]
    }
    
    internal var previousParameter: FloatingViewLayoutConstraintParameter? {
        guard parameters.count > 1 else {
            return nil
        }
        return parameters[1]
    }
    
    var numberOfViewControllers: Int {
        return self.viewControllers.count
    }
    
    var currentFloatingViewHeightConstant: CGFloat = 0
    
    private var viewControllers: [UIViewController] = []
    private var parameters: [FloatingViewLayoutConstraintParameter] = []
    
    internal var currentFloatingMode: FloatingMode = .middle
    
    internal func add(childViewController viewController: UIViewController) {
        
        guard let parent = self.parentViewController else { return }
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(viewController)
        if parent is UITabBarController {
            parent.view.insertSubview(viewController.view, belowSubview: (parent as! UITabBarController).tabBar)
        } else {
            parent.view.addSubview(viewController.view)
        }
        
        
        //TODO: REFACTOR
        let topSpaceConstraint = viewController.view.topAnchor.constraint(equalTo: parent.view.topAnchor, constant: parent.view.safeAreaInsets.top)
        topSpaceConstraint.priority = .defaultHigh
        topSpaceConstraint.isActive = false
        
        let shorterHeightConstraint =  viewController.view.heightAnchor.constraint(equalToConstant: shorterHeight)
        shorterHeightConstraint.priority = .defaultHigh
        shorterHeightConstraint.isActive = false
        
        let strechingHeightConstraint =  viewController.view.heightAnchor.constraint(equalToConstant: 0.0)
        strechingHeightConstraint.priority = .defaultHigh
        strechingHeightConstraint.isActive = true
        
        let tallerHeightConstraint =  viewController.view.heightAnchor.constraint(equalToConstant: tallerHeight)
        tallerHeightConstraint.priority = .defaultHigh
        tallerHeightConstraint.isActive = false
        
        let parameter: FloatingViewLayoutConstraintParameter = FloatingViewLayoutConstraintParameter(floatingViewShorterHeightConstraint: shorterHeightConstraint, floatingViewTallerHeightConstraint: tallerHeightConstraint, floatingViewHeightConstraint: strechingHeightConstraint, floatingViewTopSpaceConstraint: topSpaceConstraint)
        self.add(viewController: viewController, parameter: parameter)
        
        viewController.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor, constant: 0.0).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor, constant: 0.0).isActive = true
        
        if parent is UITabBarController {
            viewController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: -(parent as! UITabBarController).tabBar.bounds.height).isActive = true
        } else {
            viewController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0.0).isActive = true
        }
        
        
        viewController.didMove(toParent: parent)
        
        self.transitionCoordinator?.present(completionHandler: { (finished) in
            if finished {
                
            }
        })

    }
    
    private func add(viewController: UIViewController, parameter: FloatingViewLayoutConstraintParameter) {
        self.viewControllers.insert(viewController, at: 0)
        self.parameters.insert(parameter, at: 0)
    }
    
    //TODO: Fix a crash bug. Remove while adding animation, parameters store wrong value.
    internal func removeCurrentViewController() {
        
        guard
            self.viewControllers.count > 0,
            self.parameters.count > 0
            else
        { return }
        
        self.transitionCoordinator?.remove(completionHandler: { (isFinished) in
            if isFinished {
                
            }
            self.viewControllers.remove(at: 0)
            self.parameters.remove(at: 0)
        })
    }
}
