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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "historyItemCell") {
            if transaction.amount < 0 {
                cell.backgroundColor = UIColor.systemRed
            } else {
                cell.backgroundColor = UIColor.systemGreen
            }
            
            if let label = cell.textLabel {
                label.text = transaction.toString()
            }
            
            if let detailLabel = cell.detailTextLabel {
                detailLabel.text = "(\(String (format: "%.2f", transaction.balance)))"
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
        let balancePart = "( \(String (format: "%.2f", balance)) )"
        
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
    
    private func updateViewFromModel() {
        historicalTransactions = self.achievementsDataModel?.groupedHistoricalTransactions ?? [:]
        updateSections()
        
        historyTableView.reloadData()
    }
    
    private func updateSections() {
        var result = Array(historicalTransactions.keys)
        result.sort(by: >)
        
        self.historicalTransactionsDates = result
    }
}
