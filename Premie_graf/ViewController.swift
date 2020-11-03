//
//  ViewController.swift
//  Premie_graf
//
//  Created by Bjørn Reitzer on 26/10/2020.
//  Copyright © 2020 Bjørn Reitzer. All rights reserved.
//

import UIKit
import Highcharts

// This is the class for the graph of the initial purchase of an insurance

class ViewController: UIViewController {
    var chartView: HIChartView!, chartView2: HIChartView!
    
    
    // Toggle dynamic/static premium
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBAction func ToggleSegment(_ sender: Any) {
        
        if(segmentController.selectedSegmentIndex == 0){
            UIView.animate(withDuration: 0.3, animations: {
                self.chartView.alpha = 1
                self.chartView2.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.chartView.alpha = 0
                self.chartView2.alpha = 1
            })
        } 
    }
    
    // Premium history from insurance object (https://www.tillit.eu/api/v1/insuranceobjects/iPhone%20XS%20Max/)
    struct Premium {
        var id: Int
        var premium_base: Int
        var created: String
    }
    
    struct StaticPercent {
        var id: Int
        var percent: Double
        var created: String
    }
    
    let premium_set: [Premium]  = [
        Premium(id: 85, premium_base: 1600, created: "2020-10-29T12:28:09.793201Z"),
        Premium(id: 85, premium_base: 1500, created: "2020-09-28T12:28:09.793201Z"),
        Premium(id: 85, premium_base: 1900, created: "2020-08-20T12:28:09.793201Z"),
    ]
    
    let static_percent = StaticPercent(id: 2, percent: 0.8, created: "2020-10-12T08:22:45.663451Z")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Date of period start
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        // Tick intervals (Each 30 days)
        // let currentPremiumDate = (formatter.date(from: premium_set.first!.created))!.timeIntervalSince1970*1000
        let period_start = Date().timeIntervalSince1970*1000
        
        let previous_60_days = period_start - (60 * 86400000)
        let previous_30_days = period_start - (30 * 24 * 60 * 60 * 1000)
        let next_30_days = period_start + (30 * 24 * 60 * 60 * 1000)
        let next_60_days = period_start + (60 * 24 * 60 * 60 * 1000)
        
        let today = period_start
        
        // Premium history
        var premium_60_days_ago: Int = 0, premium_30_days_ago: Int = 0, premium_current: Int = 0, premium_next_high: Int = 0, premium_next_low: Int = 0
        
        for premium in premium_set {
            // What was the premium 60 days ago?
            if((formatter.date(from: premium.created))!.timeIntervalSince1970*1000 < previous_60_days && premium_60_days_ago == 0){
                premium_60_days_ago = premium.premium_base / 100
            } else if((formatter.date(from: premium.created))!.timeIntervalSince1970*1000 < previous_30_days && premium_30_days_ago == 0){
                // What was the premium 30 days ago?
                premium_30_days_ago = premium.premium_base / 100
            }
        }
        
        // Current premium is the first premium object
        premium_current = premium_set.first!.premium_base / 100
        // Next can increase / decrease 20%
        premium_next_high = Int((Double(premium_current) * 1.20).rounded(.awayFromZero))
        premium_next_low = Int((Double(premium_current) * 0.80).rounded(.towardZero))
        
        // If previous aren't set, use current or the most recent
        if(premium_60_days_ago == 0){
            if (premium_30_days_ago == 0) {
                premium_60_days_ago = premium_current
                premium_30_days_ago = premium_current
            } else {
                premium_60_days_ago = premium_30_days_ago
            }
        } else {
            if (premium_30_days_ago == 0) {
                premium_30_days_ago = premium_60_days_ago
            }
        }
        
        
        self.chartView = HIChartView(frame:  CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 400))
        self.chartView2 = HIChartView(frame:  CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 400))
        
        self.chartView.alpha = 0
        self.chartView2.alpha = 0
        
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.borderWidth = 1
        chart.borderColor = HIColor(hexValue: "ECECEC")
        chart.backgroundColor = HIColor(hexValue: "F8F8F8")
        options.chart = chart
        
        let title = HITitle()
        title.text = ""
        options.title = title
        
        let exporting = HIExporting()
        exporting.enabled = false
        options.exporting = exporting
        
        let credits = HICredits()
        credits.enabled = false
        options.credits = credits
        
        let legend = HILegend()
        legend.enabled = false
        options.legend = legend
        
        
        // Initial purchase
        
        // Dynamic range
        let dynamic_range = HIArearange()
        dynamic_range.name = "dynamic_range"
        dynamic_range.lineWidth = 0
        dynamic_range.data = [
            [period_start, premium_current, premium_current], // This period (10/28/2020)
            [next_30_days, premium_next_low, premium_next_high], // Next 30 days (11/27/2020)
            [next_60_days, premium_next_low, premium_next_high] // Next 60 days (12/27/2020)
        ]
        dynamic_range.dataLabels = HIDataLabels()
        dynamic_range.dataLabels.xHigh = 20
        dynamic_range.dataLabels.xLow = 20
        dynamic_range.dataLabels.yHigh = 45
        dynamic_range.dataLabels.yLow = -45
        
        dynamic_range.color = HIColor(hexValue: "ECECEC")
        dynamic_range.fillColor = HIColor(hexValue: "ECECEC")
        
        let dynamic_range_active = dynamic_range.copy() as! HIArearange
        dynamic_range_active.color = HIColor(linearGradient: ["x1": 0, "y1": 0, "x2": 1, "y2": 0], stops: [[0, "#82FFA0"], [1, "#3FFFFF"]])
        dynamic_range_active.fillColor = HIColor(linearGradient: ["x1": 0, "y1": 0, "x2": 1, "y2": 0], stops: [[0, "#82FFA0"], [1, "#3FFFFF"]])
        
        // Dynamic line
        let dynamic_line = HILine()
        dynamic_line.name = "dynamic_line"
        dynamic_line.lineWidth = 4
        dynamic_line.data = [
            [previous_60_days, premium_60_days_ago], // 60 days ago (08/29/2020)
            [previous_30_days, premium_30_days_ago], // 30 days ago (09/28/2020)
            [period_start, premium_current], // This period (10/28/2020)
            [next_30_days, premium_current], // Next 30 days (11/27/2020)
        ]
        
        dynamic_line.color = HIColor(hexValue: "ECECEC")
        let dynamic_line_active = dynamic_line.copy() as! HILine
        dynamic_line_active.color = HIColor(hexValue: "82FFA0")
        
        
        // Static line
        let static_line = HILine()
        let static_premium = Int((Double(premium_current) * (1.0 + static_percent.percent)).rounded(.towardZero))
        static_line.name = "static_line"
        static_line.lineWidth = 4
        
        static_line.data = [
            [previous_60_days, static_premium], // 60 days ago (08/29/2020)
            [previous_30_days, static_premium], // 30 days ago (09/28/2020)
            [period_start, static_premium], // This period (10/28/2020)
            [next_30_days, static_premium], // Next 30 days (11/27/2020)
            [next_60_days, static_premium], // Next 30 days (11/27/2020)
        ]
        
        static_line.color = HIColor(hexValue: "ECECEC")
        let static_line_active = static_line.copy() as! HILine
        static_line_active.color = HIColor(hexValue: "82FFA0")
        
        let yAxis = HIYAxis()
        
        yAxis.title = HITitle()
        yAxis.title.text = ""
        
        yAxis.visible = false
        options.yAxis = [yAxis]
        
        let xAxis = HIXAxis()
        xAxis.gridLineWidth = 1
        xAxis.title = HITitle()
        xAxis.title.text = ""
        xAxis.type = "datetime"
        xAxis.lineColor = HIColor(hexValue: "ECECEC")
        xAxis.tickColor = HIColor(hexValue: "ECECEC")
        
        xAxis.labels = HILabels()
        xAxis.labels.align = "left"
        xAxis.labels.x = 5
        xAxis.labels.formatter = HIFunction(jsFunction:"function () {return Highcharts.dateFormat('%d.%m', this.value);}")
        
        xAxis.tickPositions = [
            NSNumber(value: previous_60_days), // 60 days ago (08/29/2020)
            NSNumber(value: previous_30_days), // 30 days ago (09/28/2020)
            NSNumber(value: period_start), // This period (10/28/2020)
            NSNumber(value: next_30_days), // Next 30 days (11/27/2020)
            NSNumber(value: next_60_days), // Next 0 days (11/27/2020)
        ]
        
        let plotLine = HIPlotLines()
        plotLine.color = HIColor(hexValue: "000000")
        plotLine.width = 1
        plotLine.value = NSNumber(value: today)
        plotLine.label = HILabel()
        plotLine.label.text = "I dag"
        plotLine.label.rotation = 0
        plotLine.label.align = "center"
        plotLine.label.x = 0
        plotLine.label.style = HIStyle()
        plotLine.label.useHTML = true
        plotLine.label.style.backgroundColor = "#F8F8F8"
        
        plotLine.dashStyle = "dotted"
        plotLine.zIndex = 9
        xAxis.plotLines = [plotLine]
        
        xAxis.visible = true
        options.xAxis = [xAxis]
        
        let tooltip = HITooltip()
        tooltip.enabled = false
        options.tooltip = tooltip
        
        let plotOptions = HIPlotOptions()
        
        plotOptions.arearange = HIArearange()
        plotOptions.arearange.step = "left"
        
        plotOptions.line = HILine()
        plotOptions.line.step = "left"
        
        plotOptions.series = HISeries()
        plotOptions.series.dataLabels = HIDataLabels()
        plotOptions.series.dataLabels.enabled = true
        plotOptions.series.dataLabels.zIndex = 10
        plotOptions.series.dataLabels.x = 30
        
        plotOptions.series.lineWidth = 2
        plotOptions.series.marker = HIMarker()
        plotOptions.series.marker.enabled = false
        
        plotOptions.series.dataLabels.color = HIColor(hexValue: "000000")
        plotOptions.series.dataLabels.style = HIStyle()
        plotOptions.series.dataLabels.style.fontSize = "14px"
        plotOptions.series.dataLabels.style.fontWeight = "normal"
        plotOptions.series.dataLabels.allowOverlap = true
        plotOptions.series.dataLabels.useHTML = true
        
        plotOptions.series.dataLabels.formatter = HIFunction(jsFunction:
            "function () {"
                + "if(this.series.name == 'dynamic_line'){"
                    + "if(this.point.index < this.series.yData.length - 2){"
                        + "return '<p style=\"color: #666666; background-color: #F8F8F8\">' + this.y + ',-</p>'"
                    + "}else if (this.point.index == this.series.yData.length - 2){"
                        + "return '<p style=\"background-color: #F8F8F8\"><b>' + this.y + ',-</b></p>'"
                    + "}"
                + "} else if(this.series.name == 'dynamic_range') {"
                    + "if(this.point.index !== 0 && this.point.index < this.series.yData.length - 1){"
                        + "if(this.point.below){"
                            + "return '<p style=\"color: #666666;\"><img style=\"margin-right: 3px;transform: rotate(-90deg)\" src=\"https://assets.tillit.eu/static/public/images/back.svg\"></img>' + this.y + ',-</p>'"
                        + "} else {"
                            + "return '<p style=\"color: #666666;\"><img style=\"margin-right: 3px;transform: rotate(90deg)\" src=\"https://assets.tillit.eu/static/public/images/back.svg\"></img>' + this.y + ',-</p>'"
                        + "}"
                    + "}"
                + "}"
            + "}"
        )
        
        let plotOptions2 = plotOptions.copy() as! HIPlotOptions
        plotOptions2.series.dataLabels.formatter = HIFunction(jsFunction:
            "function () {"
                + "if(this.series.name == 'static_line'){"
                    + "if(this.point.index < this.series.yData.length - 3 || this.point.index == this.series.yData.length - 2){"
                        + "return '<p style=\"color: #666666;\">' + this.y + ',-</p>'"
                    + "}else if (this.point.index == this.series.yData.length - 3){"
                        + "return '<p style=\"background-color: #F8F8F8\"><b>' + this.y + ',-</b></p>'"
                    + "} else if (this.point.index == this.series.yData.length - 1){"
                        + "return"
                    + "}"
                + "}"
            + "}"
        )
        
        plotOptions.series.animation = HIAnimation()
        plotOptions.series.animation.duration = 0
        
        options.plotOptions = plotOptions
        
        options.series = [dynamic_line_active, dynamic_range_active, static_line]
        
        let options2 = options.copy() as! HIOptions
        options2.plotOptions = plotOptions2
        
        options2.series = [dynamic_line, dynamic_range, static_line_active]
        
        self.chartView.options = options
        self.chartView2.options = options2
        self.view.addSubview(self.chartView)
        self.view.addSubview(self.chartView2)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
            self.chartView.alpha = 1
            self.chartView2.alpha = 0
        })
    }
}
