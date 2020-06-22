import UIKit

protocol KetjuTextFieldDelegate: UITextFieldDelegate {
    func textFieldDidReceiveBackspace(_ textfField: KetjuTextField)
}

extension KetjuTextFieldDelegate {
    func textFieldDidReceiveBackspace(_ textfField: KetjuTextField) {
        // Empty default implementation.
    }
}

@IBDesignable
class KetjuTextField: UITextField {

    @IBInspectable
    public var isCompleted: Bool = false {
        didSet {
            configure()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textAlignment == NSTextAlignment.center ? bounds : bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return textAlignment == NSTextAlignment.center ? bounds : bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textAlignment == NSTextAlignment.center ? bounds : bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }

    override func deleteBackward() {
        super.deleteBackward()

        if let delegate = self.delegate as? KetjuTextFieldDelegate {
            delegate.textFieldDidReceiveBackspace(self)
        }
    }

    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        update()
        return result
    }

    @discardableResult
    override open func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        update()
        return result
    }

    @objc private func clearTapped(sender: UIButton) {
        self.text = nil
    }

    private func configure() {
        self.borderStyle = .none
        self.layer.borderWidth = AppAppearance.TextFieldBorderWidth
        self.layer.cornerRadius = AppAppearance.TextFieldCornerRadius
        self.backgroundColor = AppAppearance.TextFieldBackgroundColor
        self.font = AppAppearance.TextFieldFont
        self.textColor = AppAppearance.TextFieldTextColor

        let clearButton = UIButton()
        clearButton.setImage(UIImage(named: "delete"), for: .normal)
        clearButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = self.clearButtonMode
        self.tintColor = AppAppearance.TextFieldSelectedColor

        update()
    }

    private func update() {
        if isEditing {
            self.textColor = AppAppearance.TextFieldTextColor
            self.layer.borderColor = AppAppearance.TextFieldSelectedColor.cgColor
        } else if isCompleted {
            self.textColor = AppAppearance.TextFieldCompletedColor
            self.layer.borderColor = AppAppearance.TextFieldCompletedColor.cgColor
        } else {
            self.textColor = AppAppearance.TextFieldTextColor
            self.layer.borderColor = AppAppearance.TextFieldBorderColor.cgColor
        }
    }

}
