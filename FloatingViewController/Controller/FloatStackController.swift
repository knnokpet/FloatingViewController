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
    
    func setCurrentParameter(_ parameter: FloatingViewLayoutConstraintParameter) {
        parameters[0] = parameter
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
        
        
        let topSpaceConstraint = viewController.view.topAnchor.constraint(equalTo: parent.view.topAnchor, constant: parent.view.bounds.height)
        topSpaceConstraint.priority = .defaultHigh
        topSpaceConstraint.isActive = true
        topSpaceConstraint.identifier = "portrait top"
        
        let strechingHeightConstraint =  viewController.view.heightAnchor.constraint(equalToConstant: 0.0)
        strechingHeightConstraint.priority = .defaultLow
        strechingHeightConstraint.isActive = true
        
        let left = viewController.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor, constant: 0.0)
        left.isActive = true
        left.identifier = "portrait left"
        
        let right = viewController.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor, constant: 0.0)
        right.isActive = true
        right.identifier = "portrait right"
        
        let bottom = viewController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0.0)
        bottom.isActive = true
        bottom.identifier = "portrait bottom"
        
        //
        let landscapeTop = viewController.view.topAnchor.constraint(equalTo: parent.view.topAnchor, constant: parent.view.safeAreaInsets.top)
        landscapeTop.priority = .defaultHigh
        landscapeTop.isActive = false
        landscapeTop.identifier = "landscape top"
        
        let landscapeLeft = viewController.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor, constant: parent.view.safeAreaInsets.top)
        landscapeLeft.isActive = false
        landscapeLeft.identifier = "landscape left"

        let screenPercentage: CGFloat = UIScreen.main.bounds.width / UIScreen.main.bounds.height
        
        let usableHeight: CGFloat = parent.view.bounds.width - (parent.view.safeAreaInsets.left + parent.view.safeAreaInsets.right)
        let widthConstraint = viewController.view.widthAnchor.constraint(equalToConstant: usableHeight * screenPercentage * 1.4)
        widthConstraint.isActive = false
        widthConstraint.identifier = "landscape width"
        
        let landscapeBottom = viewController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0.0)
        landscapeBottom.isActive = false
        landscapeBottom.identifier = "landscape bottom"
        
        
        let parameter = FloatingViewLayoutConstraintParameter(portraitTopConstraint: topSpaceConstraint, portraitLeftConstraint: left, portraitRightConstraint: right, portraitBottomConstraint: bottom, landscapeTopConstraint: landscapeTop, landscapeLeftConstraint: landscapeLeft, landscapeWidthConstraint: widthConstraint, landscapeBottomConstraint: landscapeBottom)

        self.add(viewController: viewController, parameter: parameter)
        
        
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
