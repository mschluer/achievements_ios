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
    
    // MARK: Variables
    public var flipSignOnShow = false
    public var transactionTemplate : TransactionTemplate?

    // MARK: Outlets
    @IBOutlet weak var amountInputField: UITextField!
    @IBOutlet weak var recurringSwitch: UISwitch!
    @IBOutlet weak var titleInputField: UITextField!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleInputField.delegate = self
        
        if let template = self.transactionTemplate {
            populateFormWith(template)
        }
        
        if flipSignOnShow {
            signButtonPressed(self)
        }
        
        amountInputField.becomeFirstResponder()
    }
    
    // MARK: TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
    }
    
    // MARK: Action Handlers
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Make sure to accept ',' instead of '.'
        amountInputField.text? = amountInputField.text!.replacingOccurrences(of: ",", with: ".")
        
        let template = achievementsDataModel?.createTransactionTemplate()
        
        template?.text = titleInputField.text!
        template?.amount = (amountInputField.text as NSString?)?.floatValue ?? 0.0
        template?.recurring = recurringSwitch.isOn
        
        // Check whether it was an edit
        if let oldTransactionTemplate = self.transactionTemplate {
            achievementsDataModel?.remove(transactionTemplate: oldTransactionTemplate)
        }
        
        achievementsDataModel?.save()
        
        self.navigationController!.popViewController(animated: true)
    }
    
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
    
    // MARK: Private Functions
    private func invertSign(_ signedString: String) -> String {
        if signedString.contains("-") {
            return signedString.replacingOccurrences(of: "-", with: "")
        } else {
            return "-\(signedString)"
        }
    }
    
    private func populateFormWith(_ template: TransactionTemplate) {
        if template.amount != 0 {
            amountInputField.text = "\(String (format: "%.2f", template.amount))"
            
            if template.amount < 0 {
                amountInputField.textColor = .systemRed
            } else if template.amount == 0 {
                amountInputField.textColor = .none
            }
        } else {
            amountInputField.text = ""
        }
        
        if template.text != nil {
            titleInputField.text = template.text
        }
        
        recurringSwitch.isOn = template.recurring
    }
}
