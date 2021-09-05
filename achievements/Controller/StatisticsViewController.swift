//
//  StatisticsViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 05.09.21.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?
    
    // MARK: Variables
    
    // MARK: Outlets
    @IBOutlet weak var totalRecentIncomesLabel: UILabel!
    @IBOutlet weak var totalRecentExpensesLabel: UILabel!
    @IBOutlet weak var amountRecentIncomesLabel: UILabel!
    @IBOutlet weak var amountRecentExpensesLabel: UILabel!
    @IBOutlet weak var totalIncomesLabel: UILabel!
    @IBOutlet weak var totalExpensesLabel: UILabel!
    @IBOutlet weak var amountIncomesLabel: UILabel!
    @IBOutlet weak var amountExpensesLabel: UILabel!
    @IBOutlet weak var balanceLineChart: LineChartView!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupRecentStatistics()
        self.setupHistoricalStatistics()
        self.setupBalanceLineChart()
    }
    
    // MARK: Setup Steps
    private func setupRecentStatistics() {
        if let model = achievementsDataModel {
            totalRecentIncomesLabel.text = String(format: "%.2f", model.totalRecentIncomes)
            totalRecentExpensesLabel.text = String(format: "%.2f", model.totalRecentExpenses)
            amountRecentIncomesLabel.text = "\(model.recentIncomes.count)"
            amountRecentExpensesLabel.text = "\(model.recentExpenses.count)"
        }
    }
    
    private func setupHistoricalStatistics() {
        if let model = achievementsDataModel {
            totalIncomesLabel.text = String(format: "%.2f", model.totalHistoricalIncomes)
            totalExpensesLabel.text = String(format: "%.2f", model.totalHistoricalExpenses)
            amountIncomesLabel.text = "\(model.historicalIncomes.count)"
            amountExpensesLabel.text = "\(model.historicalExpenses.count)"
        }
    }
    
    private func setupBalanceLineChart() {
        if let model = achievementsDataModel {
            
            var chartEntries = [ChartDataEntry]()
            for i in 0..<model.historicalTransactions.count {
                chartEntries.append(ChartDataEntry(x: Double(i), y: Double(model.historicalTransactionsReverse[i].balance)))
            }
            let balanceLine = LineChartDataSet(entries: chartEntries)
            balanceLine.colors = [NSUIColor.blue]
            balanceLine.drawCirclesEnabled = false
            balanceLine.drawValuesEnabled = false
            
            var zeroLineEntries = [ChartDataEntry]()
            for i in 0..<model.historicalTransactions.count {
                zeroLineEntries.append(ChartDataEntry(x: Double(i), y: 0.0))
            }
            let zeroLine = LineChartDataSet(entries: zeroLineEntries)
            zeroLine.colors = [NSUIColor.black]
            zeroLine.drawCirclesEnabled = false
            zeroLine.drawValuesEnabled = false
            
            let data = LineChartData()
            data.addDataSet(balanceLine)
            data.addDataSet(zeroLine)
            
            balanceLineChart.data = data
            
            balanceLineChart.rightAxis.enabled = false
            balanceLineChart.drawGridBackgroundEnabled = false
            
            balanceLineChart.leftAxis.enabled = false
            balanceLineChart.xAxis.enabled = false
            balanceLineChart.legend.enabled = false
            balanceLineChart.doubleTapToZoomEnabled = false
            balanceLineChart.highlightPerTapEnabled = false
            balanceLineChart.highlightPerDragEnabled = false
            
        }
    }
    
    // MARK: Private Functions
}
