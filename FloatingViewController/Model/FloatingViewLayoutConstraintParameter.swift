import UIKit

struct FloatingViewLayoutConstraintParameter: Hashable {
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: FloatingViewLayoutConstraintParameter, rhs: FloatingViewLayoutConstraintParameter) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    internal var floatingViewHeightConstraint: NSLayoutConstraint?
    
    internal var portraitTopConstraint: NSLayoutConstraint? = nil
    internal var portraitLeftConstraint: NSLayoutConstraint? = nil
    internal var portraitRightConstraint: NSLayoutConstraint? = nil
    internal var portraitBottomConstraint: NSLayoutConstraint? = nil
    
    internal var landscapeTopConstraint: NSLayoutConstraint? = nil
    internal var landscapeLeftConstraint: NSLayoutConstraint? = nil
    internal var landscapeWidthConstraint: NSLayoutConstraint? = nil
    internal var landscapeBottomConstraint: NSLayoutConstraint? = nil
    
    var activeTopConstraint: NSLayoutConstraint? {
        if let portrait = self.portraitTopConstraint, portrait.isActive {
            return portrait
        } else if let landscape = self.landscapeTopConstraint, landscape.isActive {
            return landscape
        }
        return nil
    }
    
    var activeLeftConstraint: NSLayoutConstraint? {
        if let portrait = self.portraitLeftConstraint, portrait.isActive {
            return portrait
        } else if let landscape = self.landscapeLeftConstraint, landscape.isActive {
            return landscape
        }
        return nil
    }
    
    var activeRightConstraint: NSLayoutConstraint? {
        if let portrait = self.portraitRightConstraint, portrait.isActive {
            return portrait
        }
        return nil
    }
    
    var activeBottomConstraint: NSLayoutConstraint? {
        if let portrait = self.portraitBottomConstraint, portrait.isActive {
            return portrait
        } else if let landscape = self.landscapeBottomConstraint, landscape.isActive {
            return landscape
        }
        return nil
    }
}
