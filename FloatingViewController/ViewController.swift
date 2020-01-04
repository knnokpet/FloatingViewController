import UIKit

class ViewController: UIViewController {
    
    let tallerHeight: CGFloat = 360
    let shorterHeight: CGFloat = 120
    
    var floatStackViewController: FloatStackViewController?
    var floatStackController: FloatStackController!// = FloatStackController(parentViewController: self)
    
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.floatStackController = FloatStackController(parentViewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "FloatStackViewController":
            self.floatStackViewController = segue.destination as? FloatStackViewController
        default:
            break
        }
    }
    
    
    @IBAction func remove(_ sender: Any) {
        self.floatStackController.removeCurrentViewController()
    }
    
    @IBAction func show(_ sender: Any) {
        
        self.floatStackController.add(childViewController: OverlayViewController())
    }
    
    @IBAction func moveToMiddle(_ sender: Any) {
        self.floatStackController.transitionCoordinator?.move(mode: .middle, recognizer: nil, velocity: nil, duration: nil)
    }
    
    @IBAction func moveToFullScreen(_ sender: Any) {
        self.floatStackController.transitionCoordinator?.move(mode: .fullScreen, recognizer: nil, velocity: nil, duration: nil)
    }
    
    @IBAction func moveTobottom(_ sender: Any) {
        self.floatStackController.transitionCoordinator?.move(mode: .bottom, recognizer: nil, velocity: nil, duration: nil)
    }
    
}

