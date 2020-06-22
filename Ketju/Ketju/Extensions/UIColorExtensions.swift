import UIKit

extension UIColor {

    convenience init(hex: String) {
        guard hex.hasPrefix("#") && (hex.count == 7 || hex.count == 9) else {
            fatalError("Invalid hex color value '\(hex)'")
        }

        let startIndex = hex.index(hex.startIndex, offsetBy: 1)
        var hexColor = String(hex[startIndex...])

        if hexColor.count == 6 {
            hexColor.append("FF")
        }

        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else {
            fatalError("Invalid hex color value '\(hex)'")
        }

        self.init(red: CGFloat((hexNumber & 0xff000000) >> 24) / 255,
                  green: CGFloat((hexNumber & 0x00ff0000) >> 16) / 255,
                  blue: CGFloat((hexNumber & 0x0000ff00) >> 8) / 255,
                  alpha: CGFloat(hexNumber & 0x000000ff) / 255)
    }

    static var ketjuBlue: UIColor {
        return UIColor(hex: "#002EA2")
    }

    static var ketjuDarkGray: UIColor {
        return UIColor(hex: "#8097AD")
    }

    static var ketjuFullWhite: UIColor {
        return UIColor.white
    }

    static var ketjuGreen: UIColor {
        return UIColor(hex: "#179B8B")
    }

    static var ketjuLightGray: UIColor {
        return UIColor(hex: "#C1D0DE")
    }

    static var ketjuMatteBlack: UIColor {
        return UIColor(hex: "#232425")
    }

    static var ketjuNaturalWhite: UIColor {
        return UIColor(hex: "#FAFFFF")
    }

    static var ketjuPitchBlack: UIColor {
        return UIColor.black
    }

    static var ketjuRed: UIColor {
        return UIColor(hex: "#A1332C")
    }

    static var ketjuTurquoise: UIColor {
        return UIColor(hex: "#EFFEFF")
    }

    static var ketjuDarkTurquoise: UIColor {
        return UIColor(hex: "#D9F4FF")
    }

    static var ketjuPink: UIColor {
        return UIColor(hex: "#FFB8B2")
    }

    static var ketjuLightPink: UIColor {
        return UIColor(hex: "#FFF1F0")
    }

}
