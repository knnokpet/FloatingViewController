
import UIKit

class MyMyCell: UITableViewCell {
    
}

class MyTableViewController: UITableViewController, Floatable {
    let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    let shadowView: CoverShadowView = CoverShadowView()
    
    
    override func loadView() {
        self.tableView = MyTableView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.register(MyMyCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        self.title = "\(Self.Type.self)"
        self.navigationItem.largeTitleDisplayMode = .always
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = UIColor.clear
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        if cell is MyMyCell {
            cell.textLabel?.text = "\(indexPath.row)"
            cell.backgroundColor = UIColor.clear
        }
        // Configure the cell...

        return cell
    }
    
    var isFloating: Bool = false
        
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //debugPrint("scrollViewDidScroll")
        return
        if scrollView.isDragging && scrollView.contentOffset.y < (-scrollView.safeAreaInsets.top) {
            
            isFloating = true
            
            guard let navi = self.navigationController else { return }
            debugPrint("goth", scrollView.panGestureRecognizer.translation(in: self.view.window?.rootViewController?.view))
            NotificationCenter.default.post(name: .didChangeFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: scrollView.panGestureRecognizer.translation(in: navi.view),
            FloatNotificationProperty.recognizer: scrollView.panGestureRecognizer])
            //debugPrint(scrollView.panGestureRecognizer.translation(in: self.view))
        } else if isFloating && scrollView.isDragging && scrollView.contentOffset.y > (-scrollView.safeAreaInsets.top) {
            guard let navi = self.navigationController else { return }
            debugPrint("goth", scrollView.panGestureRecognizer.translation(in: self.view.window?.rootViewController?.view))
            NotificationCenter.default.post(name: .didChangeFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: scrollView.panGestureRecognizer.translation(in: navi.view),
            FloatNotificationProperty.recognizer: scrollView.panGestureRecognizer])
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        return
        guard let navi = self.navigationController else { return }
        NotificationCenter.default.post(name: .didEndFloatViewTranslation, object: self, userInfo: [FloatNotificationProperty.translation: scrollView.panGestureRecognizer.translation(in: navi.view),
        FloatNotificationProperty.recognizer: scrollView.panGestureRecognizer])
        
        isFloating = false
    }
    

}
