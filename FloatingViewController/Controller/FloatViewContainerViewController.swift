import UIKit

protocol FloatViewContainerViewControllerDelegate: class {
    func floatViewContainerViewControllerWillTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
    func floatViewContainerViewControllertraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?, currentTraitCollection: UITraitCollection)
}

class FloatViewContainerViewController: UIViewController {
    
    weak var delegate: FloatViewContainerViewControllerDelegate?
    
    lazy var shadowView: CoverShadowView = {
        let shadowView = CoverShadowView()
        self.view.insertSubview(shadowView, aboveSubview: self.view)
        
        shadowView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0) .isActive = true
        shadowView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        shadowView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        shadowView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        return shadowView
    }()
    
    // MARK: - View Cycle
    override func loadView() {
        self.view = PassThroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Layout
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        delegate?.floatViewContainerViewControllerWillTransition(to: newCollection, with: coordinator)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        delegate?.floatViewContainerViewControllertraitCollectionDidChange(previousTraitCollection, currentTraitCollection: self.traitCollection)
    }
    
}
