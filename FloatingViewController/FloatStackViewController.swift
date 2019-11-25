import UIKit

protocol FloatStackViewControllerDelegate: class {
    func handleTranslation(viewController: FloatStackViewController, translation: CGPoint, velocity: CGPoint)
}

class FloatStackViewController: UIViewController {
    
    weak var delegate: FloatStackViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    internal func showFloatingViewController(_ viewController: FloatingViewController) {
        self.add(childViewController: viewController)
    }
    
    private func add(childViewController viewController: UIViewController) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        
        viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16.0).isActive = true
        viewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
        
        viewController.didMove(toParent: self)
    }
    
    
    @IBAction func handlePanning(_ sender: Any) {
        guard let panRecognizer = sender as? UIPanGestureRecognizer else { return }
        let translation = panRecognizer.translation(in: self.view)
        let velocity = panRecognizer.velocity(in: self.view)
        
        switch panRecognizer.state {
        case .began:
            NotificationCenter.default.post(name: .didBeginFloatViewTranslation, object: self, userInfo: nil)
        case .changed:
            
            //debugPrint(panRecognizer.translation(in: self.view), panRecognizer.velocity(in: self.view))
            NotificationCenter.default.post(name: .didChangeFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: translation,
                                                                                                          FloatNotificationProperty.velocity: velocity])
        case .ended:
            NotificationCenter.default.post(name: .didEndFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: translation,
                                                                                                       FloatNotificationProperty.velocity: velocity])
        case .failed:
            break
        case .cancelled:
            break
        default:
            break
        }
       
       
    }
    
}
