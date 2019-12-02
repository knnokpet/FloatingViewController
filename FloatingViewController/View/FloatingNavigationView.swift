import UIKit

class FloatingNavigationView: UIView {

    var viewHeight: CGFloat = 72.0
    var notchView: NotchView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureNotch()
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureNotch()
        configureView()
    }
    
    internal func configureNotch() {
        let notch = NotchView()
        notch.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(notch)
        notch.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        notch.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        notch.widthAnchor.constraint(equalToConstant: NotchView.width).isActive = true
        notch.heightAnchor.constraint(equalToConstant: NotchView.height).isActive = true
        self.notchView = notch
    }
    
    public func configureView() {
        // To override
        self.backgroundColor = .white
    }
    
}

class NotchView: UIView {
    
    static let width: CGFloat = 38
    static let height: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    convenience init() {
        self.init(frame: .zero)
        configure()
    }
    
    func configure() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.layer.cornerRadius = 2.5
        self.layer.masksToBounds = true
    }
}
