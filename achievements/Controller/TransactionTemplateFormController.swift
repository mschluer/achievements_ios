//
//  TransactionTemplateFormController.swift
//  achievements
//
//  Created by Maximilian Schluer on 04.09.21.
//

import UIKit

class TransactionTemplateFormController: UIViewController, UITextFieldDelegate {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?

    // MARK: Outlets
    @IBOutlet weak var amountInputField: UITextField!
    @IBOutlet weak var titleInputField: UITextField!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleInputField.delegate = self
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK: TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
    }
    
    // MARK: Action Handlers
    @IBAction func signButtonPressed(_ sender: Any) {
        amountInputField.text = invertSign(amountInputField.text ?? "")
        
        if let text = amountInputField.text {
            if (text.contains("-")) {
                amountInputField.textColor = .systemRed
            } else {
                amountInputField.textColor = .systemGreen
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let template = achievementsDataModel?.createTransactionTemplate()
        
        template?.text = titleInputField.text!
        template?.amount = (amountInputField.text as NSString?)?.floatValue ?? 0.0
        template?.recurring = true
        achievementsDataModel?.save()
        
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: Setup Steps
    
    // MARK: Private Functions
    private func invertSign(_ signedString: String) -> String {
        if signedString.contains("-") {
            return signedString.replacingOccurrences(of: "-", with: "")
        } else {
            return "-\(signedString)"
        }
    }
}
