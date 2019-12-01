import UIKit

protocol Floatable where Self: UIViewController {
    var visualEffectView: UIVisualEffectView { get }
    var shadowView: CoverShadowView { get }
    
    func setupViews()
    func configureGesture()
    
    func postNotificationForWillTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
    func postNotificationForTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
}

private let cornerRadius: CGFloat = 12.0
private let hairLineWidth: CGFloat = 0.2

// MARK: Configure View
extension Floatable {
    
    func setupViews() {
        configureVisualEffectView()
        configureView()
        configureShadowView()
        
        configureGesture()
    }
    
    func configureShadowView() {
        self.view.addSubview(shadowView)
        
        shadowView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0) .isActive = true
        shadowView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        shadowView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        shadowView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
    }
    
    func configureVisualEffectView() {
        self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.visualEffectView.layer.cornerRadius = cornerRadius
        self.visualEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.visualEffectView.layer.masksToBounds = true
        self.view.insertSubview(self.visualEffectView, at: 0)
        
        self.visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: hairLineWidth).isActive = true
        self.visualEffectView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        self.visualEffectView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
        self.visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
    }
    
    func configureView() {
        self.view.layer.cornerRadius = cornerRadius
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.layer.masksToBounds = true
        self.view.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.view.layer.borderWidth = hairLineWidth
        
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    }
    
    func configureGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanning(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
}

// MARK: Gesture
private extension UIViewController {
    @objc func handlePanning(_ sender: Any) {
        guard let panRecognizer = sender as? UIPanGestureRecognizer else { return }
        let translation = panRecognizer.translation(in: self.view)
        
        switch panRecognizer.state {
        case .began:
            NotificationCenter.default.post(name: .didBeginFloatViewTranslation, object: self, userInfo: nil)
        case .changed:
            NotificationCenter.default.post(name: .didChangeFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: translation,
                                                                                                          FloatNotificationProperty.recognizer: panRecognizer])
        case .ended:
            NotificationCenter.default.post(name: .didEndFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: translation,
                                                                                                       FloatNotificationProperty.recognizer: panRecognizer])
        case .failed:
            break
        case .cancelled:
            break
        default:
            break
        }
    }
}

// MARK: Notification
extension Floatable {
    func postNotificationForWillTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        NotificationCenter.default.post(name: .willChangeTraitCollection, object: self, userInfo: [FloatNotificationProperty.traitcollection: newCollection as Any])
    }
    
    func postNotificationForTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        NotificationCenter.default.post(name: .didChangeTraitCollection, object: self, userInfo: [FloatNotificationProperty.traitcollection: self.traitCollection as Any])
    }
}