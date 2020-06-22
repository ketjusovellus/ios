import UIKit

@IBDesignable
class BodyLabel: UILabel {

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

    override var text: String? {
        didSet {
            if let text = self.text {
                let attributedString = NSMutableAttributedString(string: text)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.15
                paragraphStyle.alignment = textAlignment
                attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                self.attributedText = attributedString
            }
        }
    }

    private func configure() {
        font = UIFont.body()
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
        textColor = AppAppearance.LabelTextColor
    }
    
}
