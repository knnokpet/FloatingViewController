import UIKit

class TestTableViewController: FloatingViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let datasource: [String] = [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    ]
    
    
    @IBOutlet weak var numberLabel: UILabel!
    var number: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.numberLabel.text = "\(number)"
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let myCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as? MyCell else {
            return UITableViewCell()
        }
        
        myCell.titleLabel.text = datasource[indexPath.row]
        return myCell
    }
    
    @IBAction func handlePanning(_ sender: Any) {
        guard let panRecognizer = sender as? UIPanGestureRecognizer else { return }
        let translation = panRecognizer.translation(in: self.view)
        let velocity = panRecognizer.velocity(in: self.view)
        
        switch panRecognizer.state {
        case .began:
            NotificationCenter.default.post(name: didBeginFloatViewTranslation, object: self, userInfo: nil)
        case .changed:
            
            //debugPrint(panRecognizer.translation(in: self.view), panRecognizer.velocity(in: self.view))
            NotificationCenter.default.post(name: didChangeFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: translation,
                                                                                                          FloatNotificationProperty.velocity: velocity])
        case .ended:
            NotificationCenter.default.post(name: didEndFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: translation,
                                                                                                       FloatNotificationProperty.velocity: velocity])
        case .failed:
            break
        case .cancelled:
            break
        default:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y < 0 else {
            return
        }

        let velocity: CGPoint = .zero
        
        if scrollView.isDragging {
            
            let recognizer = scrollView.panGestureRecognizer
            let translation = recognizer.translation(in: self.view)
            
            NotificationCenter.default.post(name: didChangeFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: translation,
                                                                                                          FloatNotificationProperty.velocity: velocity])
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let recognizer = scrollView.panGestureRecognizer
        let translation = recognizer.translation(in: self.view)
        
        NotificationCenter.default.post(name: didEndFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: translation,
                                                                                                      FloatNotificationProperty.velocity: velocity])
    }
    
}

class MyCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
}
