import UIKit

class ViewController: UIViewController {
    
    let tallerHeight: CGFloat = 360
    let shorterHeight: CGFloat = 120
    
    var floatStackViewController: FloatStackViewController?
    var floatStackController: FloatStackController!// = FloatStackController(parentViewController: self)
    
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parent: UIViewController = self.parent ?? self
        self.floatStackController = FloatStackController(parentViewController: parent)
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
        
        let test = UIStoryboard(name: "TestTableViewController", bundle: nil).instantiateInitialViewController() as! TestTableViewController
        let number = self.floatStackController.numberOfViewControllers
        test.number = number
        self.floatStackController.add(childViewController: test)
    }
    
    @IBAction func moveToMiddle(_ sender: Any) {
        self.floatStackController.transitionCoordinator?.move(mode: .middle)
    }
    
    @IBAction func moveToFullScreen(_ sender: Any) {
        self.floatStackController.transitionCoordinator?.move(mode: .fullScreen)
    }
    
    @IBAction func moveTobottom(_ sender: Any) {
        self.floatStackController.transitionCoordinator?.move(mode: .bottom)
    }
    
}

