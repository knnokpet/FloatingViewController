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
    
    // MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Layout
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        NotificationCenter.default.post(name: .willChangeTraitCollection, object: self, userInfo: [FloatNotificationProperty.traitcollection: newCollection as Any])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        NotificationCenter.default.post(name: .didChangeTraitCollection, object: self, userInfo: [FloatNotificationProperty.traitcollection: self.traitCollection as Any])
    }
}
