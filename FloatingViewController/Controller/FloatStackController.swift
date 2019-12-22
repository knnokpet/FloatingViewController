import UIKit

public enum FloatingMode {
    case fullScreen, middle, bottom, progressing
}

let tallerHeight: CGFloat = 360
let shorterHeight: CGFloat = 120

class FloatStackController: NSObject {
    
    // MARK: - Properties
    weak var parentViewController: UIViewController?
    var transitionCoordinator: FloatViewTransitionCoordinator?
    private(set) lazy var containerViewController = FloatViewContainerViewController()
    
    private var viewControllers: [UIViewController] = []
    private var parameters: [FloatingViewLayoutConstraintParameter] = []
    
    var currentFloatingViewHeightConstant: CGFloat = 0
    internal var currentFloatingMode: FloatingMode = .middle
    var floatingModeBeforeProgressing: FloatingMode = .middle
    
    // MARK: Calculated Properties
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
    
    // MARK: - Initialize
    init(parentViewController: UIViewController) {
        super.init()
        self.parentViewController = parentViewController
        self.transitionCoordinator = FloatViewTransitionCoordinator(stackController: self)
        self.transitionCoordinator?.delegate = self
        
        configureContainerViewController()
        configureNotification()
    }
    
    private func configureContainerViewController() {
        
        guard let parentViewController = self.parentViewController else { return }
        
        parentViewController.addChild(self.containerViewController)
        parentViewController.view.addSubview(self.containerViewController.view)
        self.containerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.containerViewController.view.topAnchor.constraint(equalTo: parentViewController.view.topAnchor).isActive = true
        self.containerViewController.view.leftAnchor.constraint(equalTo: parentViewController.view.leftAnchor).isActive = true
        self.containerViewController.view.rightAnchor.constraint(equalTo: parentViewController.view.rightAnchor).isActive = true
        self.containerViewController.view.bottomAnchor.constraint(equalTo: parentViewController.view.bottomAnchor).isActive = true
        self.containerViewController.didMove(toParent: self.parentViewController)
        self.containerViewController.delegate = self
    }
    
    private func configureNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(removeCurrentViewController), name: .dismissFloatView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(move(_:)), name: .moveFloatView, object: nil)
    }
    
    // MARK: - Setter
    func setCurrentParameter(_ parameter: FloatingViewLayoutConstraintParameter) {
        parameters[0] = parameter
    }
    
    // MARK: - Manage Floating View Controller
    internal func add(childViewController viewController: UIViewController) {
        
        guard let _ = self.parentViewController else { return }
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        containerViewController.addChild(viewController)
        containerViewController.view.addSubview(viewController.view)
        
        let topSpaceConstraint = viewController.view.topAnchor.constraint(equalTo: containerViewController.view.topAnchor, constant: containerViewController.view.bounds.height)
        topSpaceConstraint.priority = .required
        topSpaceConstraint.isActive = true
        topSpaceConstraint.identifier = "portrait top"
        
        let strechingHeightConstraint =  viewController.view.heightAnchor.constraint(equalToConstant: 0.0)
        strechingHeightConstraint.priority = .defaultLow
        strechingHeightConstraint.isActive = true
        
        let left = viewController.view.leftAnchor.constraint(equalTo: containerViewController.view.leftAnchor, constant: 0.0)
        left.isActive = true
        left.identifier = "portrait left"
        
        let right = viewController.view.rightAnchor.constraint(equalTo: containerViewController.view.rightAnchor, constant: 0.0)
        right.isActive = true
        right.identifier = "portrait right"
        
        let bottom = viewController.view.bottomAnchor.constraint(equalTo: containerViewController.view.bottomAnchor, constant: 0.0)
        bottom.priority = .defaultHigh
        bottom.isActive = true
        bottom.identifier = "portrait bottom"
        
        //
        let landscapeTop = viewController.view.topAnchor.constraint(equalTo: containerViewController.view.topAnchor, constant: containerViewController.view.safeAreaInsets.top)
        landscapeTop.priority = .defaultHigh
        landscapeTop.isActive = false
        landscapeTop.identifier = "landscape top"
        
        let landscapeLeft = viewController.view.leftAnchor.constraint(equalTo: containerViewController.view.leftAnchor, constant: containerViewController.view.safeAreaInsets.top)
        landscapeLeft.isActive = false
        landscapeLeft.identifier = "landscape left"

        let screenPercentage: CGFloat = containerViewController.view.bounds.width / containerViewController.view.bounds.height
        
        let usableHeight: CGFloat = containerViewController.view.bounds.width - (containerViewController.view.safeAreaInsets.left + containerViewController.view.safeAreaInsets.right)
        let widthConstraint = viewController.view.widthAnchor.constraint(equalToConstant: usableHeight * screenPercentage * 1.4)
        widthConstraint.isActive = false
        widthConstraint.identifier = "landscape width"
        
        let landscapeBottom = viewController.view.bottomAnchor.constraint(equalTo: containerViewController.view.bottomAnchor, constant: 0.0)
        landscapeBottom.isActive = false
        landscapeBottom.identifier = "landscape bottom"
        
        
        let parameter = FloatingViewLayoutConstraintParameter(portraitTopConstraint: topSpaceConstraint, portraitLeftConstraint: left, portraitRightConstraint: right, portraitBottomConstraint: bottom, landscapeTopConstraint: landscapeTop, landscapeLeftConstraint: landscapeLeft, landscapeWidthConstraint: widthConstraint, landscapeBottomConstraint: landscapeBottom)

        self.add(viewController: viewController, parameter: parameter)
        
        
        viewController.didMove(toParent: containerViewController)
        
        if viewController is OverlayViewController {
            (viewController as! OverlayViewController).delegate = self
        }
        
        self.transitionCoordinator?.present(completionHandler: { (finished) in
            if finished {
                
            }
        })

    }
    
    private func add(viewController: UIViewController, parameter: FloatingViewLayoutConstraintParameter) {
        self.viewControllers.insert(viewController, at: 0)
        self.parameters.insert(parameter, at: 0)
    }
    
    @objc internal func removeCurrentViewController() {

        guard
            self.viewControllers.count > 0,
            self.parameters.count > 0
            else
        { return }
        
        self.transitionCoordinator?.remove(completionHandler: { (isFinished) in
            if isFinished {
                self.viewControllers[0].willMove(toParent: nil)
                self.viewControllers[0].view.removeFromSuperview()
                self.viewControllers[0].removeFromParent()
                self.viewControllers.remove(at: 0)
                self.parameters.remove(at: 0)
            }
            
        })
    }
    
    @objc internal func move(_ notification: Notification) {
        guard let toMode = notification.userInfo?[FloatNotificationProperty.mode] as? FloatingMode else { return }
        self.transitionCoordinator?.move(mode: toMode, recognizer: nil, velocity: nil, duration: nil)
    }
    
}

extension FloatStackController: OverlayViewControllerDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.floatingModeBeforeProgressing = self.currentFloatingMode
        self.transitionCoordinator?.beginFloatViewTranslation()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldTranslateView(following: scrollView) else { return }
        self.currentFloatingMode = .progressing
        translateView(following: scrollView)
    }
    
    func scrollView(_ scrollView: UIScrollView, willEndScrollingWithVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        switch self.currentFloatingMode {
        case .fullScreen:
            break
        case .bottom, .middle, .progressing:
            targetContentOffset.pointee = .zero
        }
        let translation = scrollView.panGestureRecognizer.translation(in: self.currentFloatingViewController?.view)
        self.transitionCoordinator?.endFloatViewTranslation(translation, recognizer: scrollView.panGestureRecognizer)
    }
    
    func shouldTranslateView(following scrollView: UIScrollView) -> Bool {
        guard scrollView.isTracking else { return false }
        
        let offset = scrollView.contentOffset.y
        switch self.currentFloatingMode {
        case .progressing:
            return true
        case .fullScreen:
            return offset < 0
        case .bottom:
            return offset > 0
        case .middle:
            return true
        }
    }
    
    func translateView(following scrollView: UIScrollView) {
        scrollView.contentOffset = .zero
        let translation = scrollView.panGestureRecognizer.translation(in: self.currentFloatingViewController?.view)
        self.transitionCoordinator?.translateFloatView(translation)
    }
}

extension FloatStackController: FloatViewContainerViewControllerDelegate {
    func floatViewContainerViewControllerWillTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    
    func floatViewContainerViewControllertraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?, currentTraitCollection: UITraitCollection) {
        self.transitionCoordinator?.handleTraitcollectionDidChange(previousTraitCollection, currentTraitCollection: currentTraitCollection)
    }
    
    
}

extension FloatStackController: FloatViewTransitionCoordinatorDelegate {
    func didChangeBackgroundShadowViewVisibility(_ isHidden: Bool, percentage: Float?) {
        if let percentage = percentage {
            self.containerViewController.shadowView.setShadowVisibility(CGFloat(percentage))
        } else {
            self.containerViewController.shadowView.isHiddenShadowView = isHidden
        }
    }
}
