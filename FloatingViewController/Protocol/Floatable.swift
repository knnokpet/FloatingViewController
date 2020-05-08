import UIKit

protocol Floatable where Self: UIViewController {
    var visualEffectView: UIVisualEffectView { get }
    var shadowView: CoverShadowView { get }
    
    func setupViews()
    func configureGesture()
    
    func panGesture() -> UIPanGestureRecognizer?
    
    func dismissFloatViewController()
    func move(_ info: [AnyHashable: Any]?)
    
}

private let cornerRadius: CGFloat = 12.0
private let hairLineWidth: CGFloat = 0.2
private let panGestureName: String = "pan_gesture_recognizer_to_translate"

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
        
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    func configureGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanning(_:)))
        panGestureRecognizer.name = panGestureName
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func panGesture() -> UIPanGestureRecognizer? {
        return self.view.gestureRecognizers?.first(where: { (gesture) -> Bool in
            gesture.name == panGestureName
        }) as? UIPanGestureRecognizer
    }
    
    func dismissFloatViewController() {
        NotificationCenter.default.post(name: .dismissFloatView, object: self, userInfo: nil)
    }
    
    func move(_ info: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: .moveFloatView, object: self, userInfo: info)
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
