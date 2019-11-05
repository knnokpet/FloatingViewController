import UIKit

class FloatingViewController: UIViewController {
    
    private var visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    override func loadView() {
        super.loadView()
        self.configureVisualEffectView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        let maskPath = UIBezierPath(roundedRect: self.view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.view.bounds
        maskLayer.path = maskPath.cgPath
        self.view.layer.mask = maskLayer
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

