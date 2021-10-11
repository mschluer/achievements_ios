//
//  TransactionDetailViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 02.09.21.
//

import UIKit

class TransactionDetailViewController: UIViewController {
    // MARK: Variables
    public var transaction: HistoricalTransaction?
    
    // MARK: Outlets
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var historicalBalanceLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    

    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        populateViewWith(transaction!)
    }

    // MARK: Private Functions
    private func populateViewWith(_ transaction: HistoricalTransaction) {
        if transaction.amount < 0 {
            amountLabel.text = "\(String (format: "%.2f", transaction.amount))"
            amountLabel.textColor = .systemRed
        } else if transaction.amount == 0 {
            amountLabel.text = "+/- \(String (format: "%.2f", transaction.amount))"
            amountLabel.textColor = .none
        } else {
            amountLabel.text = "+\(String (format: "%.2f", transaction.amount))"
            amountLabel.textColor = .systemGreen
        }
        
        if transaction.balance < 0 {
            historicalBalanceLabel.text = "( \(String (format: "%.2f", transaction.balance)) )"
            historicalBalanceLabel.textColor = .systemRed
        } else if transaction.balance == 0 {
            historicalBalanceLabel.text = "( +/- \(String (format: "%.2f", transaction.balance)) )"
            historicalBalanceLabel.textColor = .none
        } else {
            historicalBalanceLabel.text = "( +\(String (format: "%.2f", transaction.balance)) )"
            historicalBalanceLabel.textColor = .systemGreen
        }
        
        textLabel.text = transaction.text
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        
        let dateString = formatter.string(for: transaction.date)
        
        dateLabel.text = dateString
    }
}
