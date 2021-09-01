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
    public var achievementTransactionModel : AchievementTransactionModel?

    // MARK: Outlets
    @IBOutlet weak var amountInputField: UITextField!
    @IBOutlet weak var titleInputField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        titleInputField.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
            achievementTransaction?.amount = (amountInputField.text as NSString?)?.floatValue ?? 0.0
            achievementTransaction?.text = titleInputField.text!
            achievementTransaction?.date = datePicker.date
            achievementTransactionModel?.save()
            
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
}
