//
//  TransactionFormController.swift
//  achievements
//
//  Created by Maximilian Schluer on 29.08.21.
//

import UIKit

class TransactionFormController: UIViewController, UITextFieldDelegate {
    // MARK: Variables
    public var achievementTransaction: AchievementTransaction?
    public var achievementTransactionModel : AchievementsDataModel?
    public var transactionTemplate : TransactionTemplate?

    // MARK: Outlets
    @IBOutlet weak var amountInputField: UITextField!
    @IBOutlet weak var titleInputField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        titleInputField.delegate = self
        
        if achievementTransaction != nil {
            populateFormWith(achievementTransaction!)
        } else if transactionTemplate != nil {
            populateFormWith(transactionTemplate!)
        }
    }
    
    // MARK: TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
    }

    // MARK: Actions
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
        // Validate Presence
        if amountInputField.text == "" || titleInputField.text == "" {
            let alert = UIAlertController(title: "Es fehlen Daten", message: "Bitte Eingabe prüfen.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            // Remove Old Items
            if let historicalTransaction = self.achievementTransaction?.historicalTransaction {
                achievementTransactionModel?.viewContext.delete(historicalTransaction)
            } else {
                if let transaction = achievementTransaction {
                    achievementTransactionModel?.viewContext.delete(transaction)
                }
            }
            
            // Insert New Item
            _ = achievementTransactionModel?.createAchievementTransactionWith(
                text: titleInputField.text!,
                amount: (amountInputField.text as NSString?)?.floatValue ?? 0.0,
                date: datePicker.date)
            
            self.navigationController!.popViewController(animated: true)
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
    
    private func populateFormWith(_ transaction: AchievementTransaction) {
        if transaction.amount != 0 {
            amountInputField.text = "\(transaction.amount)"
            
            if transaction.amount < 0 {
                amountInputField.textColor = .systemRed
            } else if transaction.amount == 0 {
                amountInputField.textColor = .none
            }
        } else {
            amountInputField.text = ""
        }
        
        if transaction.text != nil {
            titleInputField.text = transaction.text
        }
        
        if transaction.date != nil {
            datePicker.date = transaction.date!
        }
    }
    
    private func populateFormWith(_ template: TransactionTemplate) {
        if template.amount != 0 {
            amountInputField.text = "\(template.amount)"
            
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
    }
}
