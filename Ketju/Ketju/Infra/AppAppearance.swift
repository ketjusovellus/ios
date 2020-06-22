import UIKit

class AppAppearance {

    static let BannerHeight: CGFloat = 42.0

    static let ButtonFont = UIFont.label()
    static let ButtonCornerRadius: CGFloat = 8
    static let ButtonHeight: CGFloat = 56.0
    static let ButtonHeightS: CGFloat = 40.0

    static let CardCornerRadius: CGFloat = 32.0
    
    static let HomeButtonFont = UIFont.titleBig()
    static let HomeButtonHeight: CGFloat = 160.0
    static let HomeIconWidth: CGFloat = 50.0

    static let TitleTextColor = UIColor.ketjuBlue
    static let LabelTextColor = UIColor.ketjuMatteBlack

    static let MarginL: CGFloat = 32.0
    static let MarginM: CGFloat = 16.0
    static let MarginS: CGFloat = 8.0

    static let TextFieldFont = UIFont.input()
    static let TextFieldHeight: CGFloat = 64.0
    static let TextFieldBorderWidth: CGFloat = 1
    static let TextFieldCornerRadius: CGFloat = 8
    static let TextFieldTextColor = UIColor.ketjuBlue
    static let TextFieldBackgroundColor = UIColor.ketjuFullWhite
    static let TextFieldBorderColor = UIColor.ketjuDarkGray
    static let TextFieldSelectedColor = UIColor.ketjuBlue
    static let TextFieldCompletedColor = UIColor.ketjuGreen

    static let ShadowColor = UIColor(red: 0.141, green: 0.318, blue: 0.533, alpha: 1.0).cgColor

    class func buttonFont(for style: KetjuButtonStyle) -> UIFont {
        switch style {
        case .primaryAction, .confirmAction, .secondaryAction, .primaryInfo:
            return UIFont.label()
        case .secondaryInfo:
            return UIFont.body()
        case .upload:
            return UIFont.titleMedium()
        }
    }

    class func buttonTextColor(for style: KetjuButtonStyle) -> UIColor {
        switch style {
        case .primaryAction, .confirmAction:
            return UIColor.ketjuFullWhite
        case .secondaryAction, .primaryInfo, .secondaryInfo, .upload:
            return UIColor.ketjuBlue
        }
    }

    class func buttonBorderColor(for style: KetjuButtonStyle) -> UIColor? {
        switch style {
        case .primaryAction, .confirmAction, .primaryInfo, .secondaryInfo, .upload:
            return nil
        case .secondaryAction:
            return UIColor.ketjuBlue
        }
    }

    class func buttonBackgroundColor(for style: KetjuButtonStyle) -> UIColor {
        switch style {
        case .primaryAction:
            return UIColor.ketjuBlue
        case .confirmAction:
            return UIColor.ketjuGreen
        case .secondaryAction, .primaryInfo, .secondaryInfo, .upload:
            return UIColor.clear
        }
    }

    class func buttonPressedColor(for style: KetjuButtonStyle) -> UIColor {
        switch style {
        case .primaryAction:
            return UIColor.ketjuBlue
        case .confirmAction:
            return UIColor.ketjuGreen
        case .secondaryAction, .primaryInfo, .secondaryInfo, .upload:
            return UIColor.clear
        }
    }

    class func buttonDisabledColor(for style: KetjuButtonStyle) -> UIColor {
        return UIColor.ketjuDarkGray
    }

}
