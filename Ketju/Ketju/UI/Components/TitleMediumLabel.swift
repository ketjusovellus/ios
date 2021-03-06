import UIKit

@IBDesignable
class TitleMediumLabel: UILabel {

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
        font = UIFont.titleMedium()
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
        textColor = AppAppearance.LabelTextColor
    }
    
}
