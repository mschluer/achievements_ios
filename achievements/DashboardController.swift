//
//  DashboardController.swift
//  achievements
//
//  Created by Maximilian Schluer on 27.08.21.
//

import UIKit

class DashboardController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let achievementsTransactionsModel = AchievementsTransactionsModel()
    
    private var balance: Float = 0 {
        didSet {
            if balance < 0 {
                balanceLabel.text = "\(String (format: "%.2f", balance))"
                balanceLabel.textColor = .systemRed
            } else if balance == 0 {
                balanceLabel.text = "+/- \(String (format: "%.2f", balance))"
                balanceLabel.textColor = .none
            } else {
                balanceLabel.text = "+\(String (format: "%.2f", balance))"
                balanceLabel.textColor = .systemGreen
            }
        }
    }
    private var recentTransactionsTableViewData: [AchievementTransaction] = [] {
        didSet {
            // Recalculate Balance
            var newBalance : Float = 0;
            
            for transaction in recentTransactionsTableViewData {
                newBalance += transaction.amount
            }
            
            balance = newBalance
            
            // Reload Data
            recentTransactionsTableView.reloadData()
        }
    }
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Setup for TransactionsTable
        recentTransactionsTableViewData = achievementsTransactionsModel.achievementTransactions
        self.recentTransactionsTableView.dataSource = self
        self.recentTransactionsTableView.delegate = self
        
        // Setup for MenuBott
        let mainMenuDestruct = UIAction(title: "Reset", image: UIImage(systemName: "trash.circle"), attributes: .destructive) { _ in }
        let mainMenuItems = UIMenu(title: "Main Menu", options: .displayInline, children: [
            UIAction(title: "Transaktionen Verrechnen", image: UIImage(systemName: "arrow.left.arrow.right.circle"), handler: { _ in }),
            UIAction(title: "Historie", image: UIImage(systemName: "clock.arrow.circlepath"), handler: { _ in }),
            UIAction(title: "Statistiken", image: UIImage(systemName: "chart.bar"), handler: { _ in })
        ])
        menuButton.menu = UIMenu(title: "", children: [mainMenuItems, mainMenuDestruct])
    }
    
    @IBAction func addTransaction(_ sender: Any) {
        let alert = UIAlertController(title: "Amount", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Please enter an amount"
            textField.keyboardType = .decimalPad
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let amount = (alert.textFields?.first?.text as NSString?)?.floatValue {
                self.balance += amount
                
                let achievementsTransaction = self.achievementsTransactionsModel.createAchievementTransaction()
                achievementsTransaction.amount = amount
                achievementsTransaction.text = "Transaction"
                achievementsTransaction.date = Date()
                self.achievementsTransactionsModel.save()
                
                self.recentTransactionsTableViewData.append(achievementsTransaction)
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentTransactionsTableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") {
            if recentTransactionsTableViewData[indexPath.item].amount < 0 {
                cell.backgroundColor = UIColor.systemRed
            } else {
                cell.backgroundColor = UIColor.systemGreen
            }
            
            if let label = cell.textLabel {
                label.text = (recentTransactionsTableViewData[indexPath.item].toString())
            }
            
            return cell
        }
        
        return UITableViewCell();
    }
}
