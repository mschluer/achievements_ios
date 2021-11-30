//
//  HistoryTableViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 02.09.21.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?
    
    // MARK: Variables
    private var historicalTransactions : [Date : [HistoricalTransaction]] = [:]
    private var historicalTransactionsDates : [Date] = []
    private var emptyScreenLabel : UILabel?
    
    
    // MARK: Outlets
    @IBOutlet var historyTableView: UITableView!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewFromModel()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTransactionDetailViewSegue" {
            let destination = segue.destination as! TransactionDetailViewController
            destination.transaction = sender as? HistoricalTransaction
        }
    }

    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return historicalTransactionsDates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = historicalTransactionFor(indexPath: indexPath)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "historyItemCell") as! HistoryItemTableViewCell? {
            if let amountLabel = cell.amountLabel {
                if transaction.amount < 0 {
                    amountLabel.textColor = UIColor.systemRed
                } else {
                    amountLabel.textColor = UIColor.systemGreen
                }
                
                amountLabel.text = NumberHelper.formattedString(for: transaction.amount)
            }
            
            if let historicalBalanceLabel = cell.historicalBalanceLabel {
                if transaction.balance < 0 {
                    historicalBalanceLabel.textColor = UIColor.systemRed
                } else {
                    historicalBalanceLabel.textColor = UIColor.systemGreen
                }
                
                historicalBalanceLabel.text = "(\(NumberHelper.formattedString(for: transaction.balance)))"
            }
            
            if let timeLabel = cell.timeLabel {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let dateString = formatter.string(for: transaction.date)
                 
                timeLabel.text = dateString!
            }
            
            if let titleLabel = cell.titleLabel {
                titleLabel.text = transaction.text
            }
            
            return cell
        }
        
        return UITableViewCell();
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transactionCellPressed(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = historicalTransactionsDates[section]
        let dictionaryEntry = historicalTransactions[date]
        
        return dictionaryEntry?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = historicalTransactionsDates[section]
        
        // Date Part
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let datePart = formatter.string(for: date)!
        
        // Balance Part
        let dictionaryItem = historicalTransactions[date]!
        let balance = calculateBalanceFor(array: dictionaryItem)
        let balancePart = "( \(NumberHelper.formattedString(for: balance)) )"
        
        return "\(datePart) - \(balancePart)"
    }
    
    // MARK: Action Handlers
    private func transactionCellPressed(_ indexPath: IndexPath) {
        AchievementTransactionsPresenter(achievevementsDataModel: achievementsDataModel!).showTransactionDetails(from: self, transaction: historicalTransactionFor(indexPath: indexPath))
    }
    
    // MARK: Private Functions
    private func calculateBalanceFor(array: [HistoricalTransaction]) -> Float {
        var result : Float = 0.0
        
        for element in array {
            result += element.amount
        }
        
        return result
    }
    
    private func historicalTransactionFor(indexPath: IndexPath) -> HistoricalTransaction {
        let date = historicalTransactionsDates[indexPath.section]
        let dictionaryEntry = historicalTransactions[date]!
        return dictionaryEntry[indexPath.item]
    }
    
    private func updateEmptyScreenState() {
        if(historicalTransactions.isEmpty) {
            if(emptyScreenLabel != nil) { return }
            
            let label = UILabel()
            label.text = NSLocalizedString("Nothing to show.\n\nCurrently, there are no history items to display. This will change, once you add Transactions.", comment: "Description for empty History")
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.addConstraints([
                NSLayoutConstraint(
                    item: label,
                    attribute: NSLayoutConstraint.Attribute.width,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: nil,
                    attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                    multiplier: 1,
                    constant: 200),
                NSLayoutConstraint(
                    item: label,
                    attribute: NSLayoutConstraint.Attribute.height,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: nil,
                    attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                    multiplier: 1,
                    constant: 200),
            ])
            
            self.historyTableView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: historyTableView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: historyTableView.centerYAnchor).isActive = true
            
            self.emptyScreenLabel = label
        } else {
            if let label = self.emptyScreenLabel {
                label.removeFromSuperview()
                self.emptyScreenLabel = nil
            }
        }
    }
    
    private func updateViewFromModel() {
        historicalTransactions = self.achievementsDataModel?.groupedHistoricalTransactions ?? [:]
        updateSections()
        
        historyTableView.reloadData()
        
        updateEmptyScreenState()
    }
    
    private func updateSections() {
        var result = Array(historicalTransactions.keys)
        result.sort(by: >)
        
        self.historicalTransactionsDates = result
    }
}

class HistoryItemTableViewCell : UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var historicalBalanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
}
