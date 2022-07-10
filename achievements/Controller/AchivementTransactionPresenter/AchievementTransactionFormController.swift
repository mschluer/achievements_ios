//
//  TransactionFormController.swift
//  achievements
//
//  Created by Maximilian Schluer on 29.08.21.
//

import UIKit

class AchievementTransactionFormController: BaseViewController, UITextFieldDelegate {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?
    
    // MARK: Variables
    public var achievementTransaction: AchievementTransaction?
    public var transactionTemplate : TransactionTemplate?
    public var detailViewController : TransactionDetailViewController?

    // MARK: Outlets
    @IBOutlet weak var amountInputField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleInputField: UITextField!
    
    // MARK: Onboarding
    override var onboardingKey: String? { return "achievementTransactionForm" }
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        titleInputField.delegate = self
        
        if achievementTransaction != nil {
            populateFormWith(achievementTransaction!)
        } else if transactionTemplate != nil {
            populateFormWith(transactionTemplate!)
        }
        
        if Settings.onboardingsShown[onboardingKey!] ?? false {
            amountInputField.becomeFirstResponder()
        }
    }
    
    // MARK: TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
    }

    // MARK: Action Handlers
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Validate Presence
        if amountInputField.text == "" || titleInputField.text == "" {
            let alert = UIAlertController(title: NSLocalizedString("Data missing", comment: "The user did not enter sufficient data."), message: NSLocalizedString("Please check your input", comment: "Ask the user to check his or her input"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval"), style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            // Make sure to accept ',' instead of '.'
            amountInputField.text? = amountInputField.text!.replacingOccurrences(of: ",", with: ".")
            
            // Remove Old Items if edit
            if let transaction = self.achievementTransaction {
                if let historicalTransaciton = transaction.historicalTransaction {
                    achievementsDataModel?.remove(historicalTransaction: historicalTransaciton)
                } else {
                    achievementsDataModel?.remove(achievementTransaction: transaction)
                }
            }
            
            // Insert New Item
            let newAchievementTransaction = achievementsDataModel?.createAchievementTransactionWith(
                text: titleInputField.text!,
                amount: (amountInputField.text as NSString?)?.floatValue ?? 0.0,
                date: datePicker.date)
            
            // Detail View Repopulation
            if let detailViewController = self.detailViewController {
                detailViewController.transaction = newAchievementTransaction!.historicalTransaction
            }
            
            // Remove Template if not recurring
            if let template = self.transactionTemplate, !template.recurring {
                achievementsDataModel?.remove(transactionTemplate: template)
            }
            
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    @IBAction func signButtonPressed(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
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
    }
    
    private func populateFormWith(_ transaction: AchievementTransaction) {
        if transaction.amount != 0 {
            amountInputField.text = "\(String (format: "%.2f", transaction.amount))"
            
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
}
