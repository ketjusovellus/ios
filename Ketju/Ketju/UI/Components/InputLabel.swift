import UIKit

@IBDesignable
class InputLabel: UILabel {

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

    private func configure() {
        font = UIFont.input()
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
        textColor = AppAppearance.LabelTextColor
    }
    
}
