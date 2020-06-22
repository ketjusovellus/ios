import UIKit

enum KetjuButtonStyle: Int {
    case primaryAction // the blue
    case confirmAction // the green
    case secondaryAction // the bordered
    case upload
    case primaryInfo // without borders
    case secondaryInfo // without borders
}

@IBDesignable
class KetjuButton: UIButton {

    var style: KetjuButtonStyle = .primaryAction {
        didSet {
            configure()
        }
    }

    @IBInspectable
    var buttonStyle: Int {
        get {
            return style.rawValue
        }
        set {
            style = KetjuButtonStyle(rawValue: newValue) ?? .primaryAction
        }
    }

    override var isHighlighted: Bool {
        didSet {
            update()
        }
    }

    override var isEnabled: Bool {
        didSet {
            update()
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

    override func layoutSubviews() {
        super.layoutSubviews()

        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 35), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: imageView!.bounds.size.width)
        }
    }

    private func configure() {
        layer.cornerRadius = AppAppearance.ButtonCornerRadius
        titleLabel?.font = AppAppearance.buttonFont(for: style)
        titleLabel?.adjustsFontForContentSizeCategory = true

        let titleColor = AppAppearance.buttonTextColor(for: style)
        setTitleColor(titleColor , for: .normal)

        if let borderColor = AppAppearance.buttonBorderColor(for: style) {
            layer.borderWidth = 2.0
            layer.borderColor = borderColor.cgColor
        }

        imageView?.tintColor = titleColor

        update()
    }

    private func update() {
        if isEnabled {
            if isHighlighted {
                backgroundColor = AppAppearance.buttonPressedColor(for: style)
            } else {
                backgroundColor = AppAppearance.buttonBackgroundColor(for: style)
            }
        } else {
            backgroundColor = AppAppearance.buttonDisabledColor(for: style)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Bit of a hack to make title text to respond to size change correctly
        let text = currentTitle
        setTitle(nil, for: .normal)
        setTitle(text, for: .normal)
    }
    
}
