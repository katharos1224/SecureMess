//
//  LoginViewController.swift
//  Messenger
//
//  Created by Katharos on 16/11/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let forgotPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Forgot Password?"
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .secondarySystemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTaped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(forgotPasswordLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 2
        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: (scrollView.height - size) / 3, width: size, height: size)
        emailField.frame = CGRect(x: 50, y: imageView.bottom + 50, width: scrollView.width - 100, height: 50)
        passwordField.frame = CGRect(x: 50, y: emailField.bottom + 10, width: scrollView.width - 100, height: 50)
        loginButton.frame = CGRect(x: 50, y: passwordField.bottom + 30, width: scrollView.width - 100, height: 50)
        forgotPasswordLabel.frame = CGRect(x: (scrollView.width - size) / 2 + 45, y: loginButton.bottom + 15, width: size - 60, height: 20)
    }
    
    @objc private func loginButtonTaped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        // Firebase Log In Method
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            guard !exists else {
                //user already exsists
                strongSelf.alertUserLoginError(message: "Looks like a user account for that email address already exsists!")
                return
            }
            
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
                guard let result = authResult, error == nil else {
                    print("Failedto log in user with email: \(email)" )
                    return
                }
                
                let user = result.user
                print("Logged in user \(user)")
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func alertUserLoginError(message: String = "Please enter all information to log in.") {
        let alert = UIAlertController(title: "Woops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: UITextField Delegate Methods

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
            
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            loginButtonTaped()
        }
        
        return true
    }
}
