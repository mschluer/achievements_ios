//
//  TransactionDetailViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 02.09.21.
//

import UIKit

class TransactionDetailViewController: BaseViewController {
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
            amountLabel.text = "\(NumberHelper.formattedString(for: transaction.amount))"
            amountLabel.textColor = .systemRed
        } else if transaction.amount == 0 {
            amountLabel.text = "+/- 0,00"
            amountLabel.textColor = .none
        } else {
            amountLabel.text = "+\(NumberHelper.formattedString(for: transaction.amount))"
            amountLabel.textColor = .systemGreen
        }
        
        if transaction.balance < 0 {
            historicalBalanceLabel.text = "( \(NumberHelper.formattedString(for: transaction.balance)) )"
            historicalBalanceLabel.textColor = .systemRed
        } else if transaction.balance == 0 {
            historicalBalanceLabel.text = "( +/- 0,00 )"
            historicalBalanceLabel.textColor = .none
        } else {
            historicalBalanceLabel.text = "( +\(NumberHelper.formattedString(for: transaction.balance)) )"
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
