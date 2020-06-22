import UIKit

enum KetjuBackgroundStyle: Int {
    case normal
    case warning
}

@IBDesignable
class KetjuBackgroundView: UIView {

    private let gradientLayer = CAGradientLayer()

    var style: KetjuBackgroundStyle = .normal {
        didSet {
            configure()
        }
    }

    @IBInspectable
    var backgroundStyle: Int {
        get {
            return style.rawValue
        }
        set {
            style = KetjuBackgroundStyle(rawValue: newValue) ?? .normal
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
        update()
    }

    private func configure() {
        switch style {
        case .normal:
            gradientLayer.colors = [UIColor.ketjuTurquoise.cgColor, UIColor.ketjuNaturalWhite.cgColor, UIColor.ketjuNaturalWhite.cgColor]
        case .warning:
            gradientLayer.colors = [UIColor.ketjuPink.cgColor, UIColor.ketjuLightPink.cgColor, UIColor.ketjuLightPink.cgColor]
        }

        gradientLayer.locations = [0.0, 0.4, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        self.layer.insertSublayer(gradientLayer, at: 0)

        update()
    }

    private func update() {
        gradientLayer.frame = self.bounds
    }

}
