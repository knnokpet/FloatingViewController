import UIKit

class FloatingViewController: UIViewController, Floatable {
    
    let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    let shadowView: CoverShadowView = CoverShadowView()
    
    // MARK: - View Cucle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Layout
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        postNotificationForWillTransition(to: newCollection, with: coordinator)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        postNotificationForTraitCollectionDidChange(previousTraitCollection)
    }
}

