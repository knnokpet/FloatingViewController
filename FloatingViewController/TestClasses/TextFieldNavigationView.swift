import UIKit

protocol TextFieldNavigationViewDelegate: class {
    func didBeginEditingTextField(_ textFieldNavigationView: TextFieldNavigationView,  textField: UITextField)
    func didPushCloseButton(_ textFieldNavigationView: TextFieldNavigationView)
}

class TextFieldNavigationView: FloatingNavigationView, UITextFieldDelegate {
    
    var textField: UITextField!
    var cancelButton: UIButton!
    
    weak var delegate: TextFieldNavigationViewDelegate?

    override func configureView() {
        self.backgroundColor = .white
        
        let mergin: CGFloat = 8
        let textField = UITextField()
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            textField.backgroundColor = UIColor.systemGray5
        } else {
            // Fallback on earlier versions
        }
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textField)
        textField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: mergin * 2).isActive = true
        textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -mergin * 2 - 40).isActive = true
        //textField.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor, constant: -mergin * 2).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(NotchView.height + mergin + 6)).isActive = true
        textField.topAnchor.constraint(equalTo: self.notchView.topAnchor, constant: (NotchView.height + mergin)).isActive = true
        self.textField = textField
        self.textField.delegate = self
        
        
        if #available(iOS 13.0, *) {
            let cancelButton = UIButton(type: .close)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
            self.addSubview(cancelButton)
            cancelButton.centerYAnchor.constraint(equalTo: self.textField.centerYAnchor).isActive = true
            cancelButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -mergin * 2).isActive = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.didBeginEditingTextField(self, textField: textField)
    }
    
    @objc func close(_ sender: Any) {
        self.textField.resignFirstResponder()
        self.delegate?.didPushCloseButton(self)
    }

}
