//
//  PlannedExpensesViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 08.10.21.
//

import UIKit

class PlannedExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?
    
    // MARK: Variables
    private var plannedExpenses: [TransactionTemplate] = []

    // MARK: Outlets
    @IBOutlet weak var plannedExpensesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlannedExpensesTable()
    }

    // MARK: Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plannedExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "templateCell") {
            let template = plannedExpenseFor(indexPath: indexPath)
            
            // Populate Cell
            cell.textLabel?.text = template.text
            if template.amount < 0 {
                cell.detailTextLabel?.textColor = UIColor.systemRed
                cell.detailTextLabel?.text = String (format: "%.2f", template.amount)
            } else if template.amount > 0 {
                cell.detailTextLabel?.textColor = UIColor.systemGreen
                cell.detailTextLabel?.text = String (format: "%.2f", template.amount)
            } else {
                cell.detailTextLabel?.text = ""
            }
            
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        // Element am Index.item wieder einsetzen
        // Speichern
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Setup Steps
    private func setupPlannedExpensesTable() {
        self.plannedExpensesTable.dataSource = self
        self.plannedExpensesTable.delegate = self
        
        updateViewFromModel()
    }
    
    // MARK: Private functions
    private func updateViewFromModel() {
        refreshData()
        plannedExpensesTable.reloadData()
    }
    
    private func refreshData() {
        plannedExpenses = achievementsDataModel?.plannedExpenses ?? []
    }
    
    private func plannedExpenseFor(indexPath : IndexPath) -> TransactionTemplate {
        return plannedExpenses[indexPath.item]
    }
}
