import UIKit

class FloatingViewController: UIViewController {
    
    private var visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    
    // MARK: - Load
    override func loadView() {
        super.loadView()
        self.configureVisualEffectView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
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
    }

    private func configureVisualEffectView() {
        self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(self.visualEffectView, at: 0)
        
        self.visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        self.visualEffectView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        self.visualEffectView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
        self.visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
    }

}

