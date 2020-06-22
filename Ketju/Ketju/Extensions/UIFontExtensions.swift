import UIKit

extension UIFont {

    class func titleBig() -> UIFont {
        return UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: boldFont(size: 36))
    }

    class func titleMedium() -> UIFont {
        return UIFontMetrics(forTextStyle: .headline).scaledFont(for: boldFont(size: 22))
    }

    class func titleSmall() -> UIFont {
        return UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: boldFont(size: 18))
    }

    class func body() -> UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: regularFont(size: 16))
    }

    class func label() -> UIFont {
        return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: boldFont(size: 16))
    }

    class func input() -> UIFont {
        return UIFontMetrics(forTextStyle: .callout).scaledFont(for: regularFont(size: 22))
    }

    private class func regularFont(size: CGFloat) -> UIFont {
        return UIFont(name: "DMSans-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }

    private class func boldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "DMSans-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

}
