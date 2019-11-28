import UIKit

class CoverShadowView: UIView {
    
    private let visibleShadowOpacity: Float = 0.2
    var isHiddenShadowView: Bool = false {
        didSet {
            if isHiddenShadowView == true {
                self.layer.opacity = 0.0
            } else {
                self.layer.opacity = visibleShadowOpacity
            }
        }
    }
    
    func setShadowVisibility(_ percentage: CGFloat) {
        self.layer.opacity = Float(percentage) * visibleShadowOpacity
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.black
        self.layer.opacity = 0.0
        self.isUserInteractionEnabled = false
    }
}
