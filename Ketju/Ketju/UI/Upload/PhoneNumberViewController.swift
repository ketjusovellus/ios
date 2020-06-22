import UIKit
import SnapKit

class PhoneNumberViewController: UIViewController {

    private let mainTitleLabel: TitleMediumLabel = TitleMediumLabel()
    private let titleLabel: TitleMediumLabel = TitleMediumLabel()
    private let subtitleLabel: BodyLabel = BodyLabel()
    private let phoneNumberTextField: KetjuTextField = KetjuTextField()
    private let confirmButton: KetjuButton = KetjuButton()
    private let closeButton: UIButton = UIButton(type: .custom)

    private var phoneNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ketjuFullWhite

        closeButton.setImage(UIImage(named: "down-arrow"), for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.contentMode = .scaleAspectFit
        closeButton.tintColor = UIColor.ketjuBlue
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

        phoneNumberTextField.delegate = self
        phoneNumberTextField.placeholder = "+358"
        phoneNumberTextField.textContentType = .telephoneNumber
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.clearButtonMode = .always
        phoneNumberTextField.rightViewMode = .always
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberEditingChanged), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberEditingDidBegin), for: .editingDidBegin)

        mainTitleLabel.text = NSLocalizedString("Upload_title", comment: "")
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.textColor = AppAppearance.TitleTextColor
        titleLabel.text = NSLocalizedString("Phone_number_title", comment: "")
        subtitleLabel.text = NSLocalizedString("Phone_number_subtitle", comment: "")
        
        confirmButton.isEnabled = false
        confirmButton.style = .primaryAction
        confirmButton.setImage(UIImage(named: "right-arrow"), for: .normal)
        confirmButton.setTitle(NSLocalizedString("Next_button", comment: ""), for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        view.addGestureRecognizer(tap)

        view.addSubview(mainTitleLabel)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(phoneNumberTextField)
        view.addSubview(confirmButton)

        makeConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        phoneNumberTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func makeConstraints() {
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(AppAppearance.MarginM)
            make.height.width.equalTo(40.0)
        }

        mainTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(AppAppearance.MarginM)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainTitleLabel.snp.bottom).offset(AppAppearance.MarginL)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.top.equalTo(titleLabel.snp.bottom).offset(AppAppearance.MarginM)
        }

        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(AppAppearance.MarginM)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.height.equalTo(AppAppearance.TextFieldHeight)
        }

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.height.equalTo(AppAppearance.ButtonHeight)
            make.bottom.equalToSuperview().inset(AppAppearance.MarginL)
        }
    }

    @objc private func phoneNumberEditingDidBegin(_ sender: KetjuTextField) {
        if phoneNumberTextField.text?.isEmpty ?? true {
            phoneNumberTextField.text = "+358 "
        }
    }

    @objc private func phoneNumberEditingChanged(_ sender: KetjuTextField) {
        validatePhoneNumber()
    }

    @objc private func backgroundViewTapped(_ sender: UITapGestureRecognizer) {
        phoneNumberTextField.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            confirmButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(AppAppearance.MarginL + keyboardFrame.height)
            }

            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            confirmButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(AppAppearance.MarginL)
            }

            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    private func validatePhoneNumber() {
        phoneNumber = phoneNumberTextField.text

        if let phoneNumber = phoneNumber?.replacingOccurrences(of: " ", with: "") {
            let isValid = phoneNumber.count > 10
            phoneNumberTextField.isCompleted = isValid
            confirmButton.isEnabled = isValid
        }
    }

    // MARK: - Navigation

    @objc private func confirmTapped(_ sender: KetjuButton) {
        let vc = PhoneVerificationViewController()
        vc.phoneNumber = phoneNumber
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func close() {
        navigationController?.dismiss(animated: true)
    }

}

extension PhoneNumberViewController: KetjuTextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.allSatisfy({ $0.isNumber || $0.isWhitespace || $0 == "+" })
    }

}
