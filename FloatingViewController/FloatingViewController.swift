import UIKit

class FloatingViewController: UIViewController {
    
    private var visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    let shadowView: CoverShadowView = CoverShadowView()
    
    // MARK: - Load
    override func loadView() {
        super.loadView()
        self.configureVisualEffectView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureShadowView()
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
    
    private func configureShadowView() {
        self.view.addSubview(shadowView)
        
        shadowView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0) .isActive = true
        shadowView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        shadowView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        shadowView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
    }

    private func configureVisualEffectView() {
        self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.visualEffectView.layer.cornerRadius = 12
        self.visualEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.visualEffectView.layer.masksToBounds = true
        self.view.insertSubview(self.visualEffectView, at: 0)
        
        self.visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.2).isActive = true
        self.visualEffectView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        self.visualEffectView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
        self.visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
    }

}

