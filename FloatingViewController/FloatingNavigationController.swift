import UIKit

class FloatingNavigationController: UINavigationController, Floatable {
    
    let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    let shadowView: CoverShadowView = CoverShadowView()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    convenience init(rootViewController: UIViewController, navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        self.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.viewControllers = [rootViewController]
    }
    
    // MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationView()
        setupViews()
    }
    
    private func configureNavigationView() {
        
        self.navigationBar.isHidden = true
        
        let navigationView = TextFieldNavigationView()
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navigationView)
        navigationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        navigationView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        navigationView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: navigationView.viewHeight).isActive = true
        navigationView.delegate = self
        
        self.additionalSafeAreaInsets = UIEdgeInsets(top: navigationView.viewHeight, left: 0, bottom: 0, right: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: - Layout
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    }
    
    // MARK: -
    @objc func keyboardWillShow(_ notification: Notification) {
        let duration = notification.userInfo?[UIWindow.keyboardAnimationDurationUserInfoKey]
        let info: [AnyHashable: Any] = {
            let dict: [AnyHashable: Any] = [FloatNotificationProperty.mode: FloatingMode.fullScreen]
            if let _ = duration {
                // too fast. 
                //dict[FloatNotificationProperty.duration] = duration
            }
            return dict
        }()
        self.move(info)
    }
}

extension FloatingNavigationController: TextFieldNavigationViewDelegate {
    func didBeginEditingTextField(_ textFieldNavigationView: TextFieldNavigationView, textField: UITextField) {
        //self.move(.fullScreen)
    }
    
    func didPushCloseButton(_ textFieldNavigationView: TextFieldNavigationView) {
        self.dismissFloatViewController()
    }
    
    
}
