import UIKit

class FloatingNavigationController: UINavigationController, Floatable {
    
    let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    let shadowView: CoverShadowView = CoverShadowView()

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
    
    // MARK: - Configure
    private func configureView() {
        self.view.layer.cornerRadius = 12
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.layer.masksToBounds = true
        self.view.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.view.layer.borderWidth = 0.2
        
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    }

}
