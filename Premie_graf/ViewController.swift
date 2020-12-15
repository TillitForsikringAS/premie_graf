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
    struct Coverage {
        var percent: Double
    }
    
    struct StaticPercent {
        var id: Int
        var percent: Double
        var created: String
    }
    
    let premium_set: [Premium]  = [
        Premium(id: 85, premium_base: 1900, created: "2020-12-04T12:28:09.793201Z"),
        Premium(id: 85, premium_base: 1500, created: "2020-11-14T12:28:09.793201Z"),
        Premium(id: 85, premium_base: 2100, created: "2020-10-13T12:28:09.793201Z"),
    ]
    
    let coverage_set: [Coverage]  = [
        Coverage(percent: 0.3),
        Coverage(percent: 0.5),
    ]
    
    var static_premium: Int = 0
    
    let static_percent = StaticPercent(id: 2, percent: 0.8, created: "2020-10-12T08:22:45.663451Z")
    
    let screenSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Date of period start
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        // Tick intervals (Each 30 days)
        // let premium_currentDate = (formatter.date(from: insuranceObject.premium_set.first!.created))!.timeIntervalSince1970*1000
        let period_start = Date().timeIntervalSince1970*1000
        
        let previous_60_days = period_start - (60 * 24 * 60 * 60 * 1000)
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
        
        self.chartView = HIChartView(frame:  CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 320))
        self.chartView2 = HIChartView(frame:  CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 320))
        self.chartView.plugins = ["pattern-fill"]
        self.chartView2.plugins = ["pattern-fill"]
        
        self.chartView.alpha = 1
        self.chartView2.alpha = 0
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.borderWidth = 1
        chart.borderColor = HIColor(hexValue: "ECECEC")
        chart.backgroundColor = HIColor(hexValue: "F8F8F8")
        chart.marginLeft = NSNumber(value: 0)
        chart.marginRight = NSNumber(value: 0)
        chart.marginBottom = NSNumber(value: 30)
        chart.marginTop = NSNumber(value: 40)
        
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
        
        
        
        
        let dynamic_range_active = dynamic_range.copy() as! HIArearange
        dynamic_range.zIndex = 1
        dynamic_range_active.zIndex = 2
        
        
        let dynamic_range_pattern = HIPatternObject()
        dynamic_range_pattern.pattern = HIPatternOptionsObject()
        dynamic_range_pattern.pattern.color = "#ECECEC"
        dynamic_range.fillColor = HIColor(pattern: dynamic_range_pattern)
        dynamic_range.lineColor = HIColor(hexValue: "ECECEC")
        dynamic_range.lineWidth = 2
        
        let dynamic_range_active_pattern = HIPatternObject()
        dynamic_range_active_pattern.pattern = HIPatternOptionsObject()
        dynamic_range_active_pattern.pattern.color = "#00FCFF"
        dynamic_range_active.fillColor = HIColor(pattern: dynamic_range_active_pattern)
        dynamic_range_active.lineColor = HIColor(hexValue: "00FCFF")
        dynamic_range_active.lineWidth = 2
        
        
        // Dynamic line
        let dynamic_line = HILine()
        dynamic_line.name = "dynamic_line"
        dynamic_line.lineWidth = 2
        
        
        dynamic_line.data = [
            [previous_60_days, premium_60_days_ago], // 60 days ago (08/29/2020)
            [previous_30_days, premium_30_days_ago], // 30 days ago (09/28/2020)
            [period_start, premium_current], // This period (10/28/2020)
            [next_30_days, premium_current], // Next 30 days (11/27/2020)
        ]
        
        dynamic_line.color = HIColor(hexValue: "ECECEC")
        let dynamic_line_active = dynamic_line.copy() as! HILine
        dynamic_line.zIndex = 1
        dynamic_line_active.zIndex = 2
        dynamic_line_active.color = HIColor(hexValue: "00FCFF")
        
        
        // Static line
        let static_line = HILine()
        if screenSelected == true {
            self.static_premium = Int((Double(premium_current) * (1.0 + (coverage_set[1].percent))).rounded(.towardZero))
        } else {
            self.static_premium = Int((Double(premium_current) * (1.0 + (coverage_set.first?.percent)!)).rounded(.towardZero))
        }
        
        static_line.name = "static_line"
        static_line.lineWidth = 2
        
        static_line.data = [
            [previous_60_days, static_premium], // 60 days ago (08/29/2020)
            [previous_30_days, static_premium], // 30 days ago (09/28/2020)
            [period_start, static_premium], // This period (10/28/2020)
            [next_30_days, static_premium], // Next 30 days (11/27/2020)
            [next_60_days, static_premium], // Next 30 days (11/27/2020)
        ]
        
        static_line.color = HIColor(hexValue: "ECECEC")
        let static_line_active = static_line.copy() as! HILine
        static_line.zIndex = 1
        static_line_active.zIndex = 2
        static_line_active.color = HIColor(hexValue: "00FCFF")
        
        let yAxis = HIYAxis()
        
        yAxis.title = HITitle()
        yAxis.title.text = ""
        
        yAxis.visible = false
        options.yAxis = [yAxis]
        
        let xAxis = HIXAxis()
        xAxis.title = HITitle()
        xAxis.title.text = ""
        xAxis.type = "datetime"
        
        xAxis.gridLineWidth = 1
        xAxis.tickLength = 40
        xAxis.lineColor = HIColor(hexValue: "ECECEC")
        xAxis.tickColor = HIColor(hexValue: "ECECEC")
        
        xAxis.labels = HILabels()
        
        xAxis.labels.align = "left"
        xAxis.labels.x = 10
        
        xAxis.labels.formatter = HIFunction(jsFunction:"function () {return Highcharts.dateFormat('%d. %b %y', this.value);}")
        
        xAxis.labels.style = HICSSObject()
        xAxis.labels.style.color = "#000000"
        xAxis.labels.style.fontFamily = "Poppins-Regular"
        
        let plotLine = HIPlotLines()
        plotLine.color = HIColor(hexValue: "000000")
        plotLine.width = 1
        plotLine.value = NSNumber(value: today)
        plotLine.label = HILabel()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d. MMM"
        let todayFormatted = dateFormatter.string(from: Date())
        plotLine.label.text = "I dag, <b>\(todayFormatted)</b>"
        plotLine.label.textAlign = "rigth"
        plotLine.label.x = 5
        plotLine.label.y = -10
        plotLine.label.verticalAlign = "bottom"
        plotLine.label.rotation = 0
        plotLine.label.style = HICSSObject()
        plotLine.label.style.color = "#666"
        //        plotLine.label.style.fontWeight = "bold"
        
        plotLine.width = 1
        plotLine.color = HIColor(hexValue: "666")
        
        plotLine.zIndex = 9
        xAxis.plotLines = [plotLine]
        
        xAxis.tickPositions = [
            NSNumber(value: previous_60_days), // 60 days ago (08/29/2020)
            NSNumber(value: previous_30_days), // 30 days ago (09/28/2020)
            NSNumber(value: period_start), // This period (10/28/2020)
            NSNumber(value: next_30_days), // Next 30 days (11/27/2020)
            NSNumber(value: next_60_days), // Next 0 days (11/27/2020)
        ]
        
        xAxis.visible = true
        xAxis.tickPixelInterval = 0
        xAxis.maxPadding = 0
        xAxis.minPadding = 0
        
        let xAxisTop = HIXAxis()
        
        xAxisTop.opposite = true
        xAxisTop.type = "category"
        
        let estimateString = "\(premium_next_low) - \(premium_next_high) kr"
        
        xAxisTop.categories = ["\(premium_60_days_ago) kr", "\(premium_30_days_ago) kr", "\(premium_current) kr", estimateString]
        
        xAxisTop.min = 0
        xAxisTop.max = NSNumber(value: xAxisTop.categories.count - 1)
        
        xAxisTop.lineColor = HIColor(hexValue: "ECECEC")
        xAxisTop.tickColor = HIColor(hexValue: "ECECEC")
        xAxisTop.tickLength = 40
        xAxisTop.tickWidth = 1
        
        xAxisTop.labels = HILabels()
        xAxisTop.labels.align = "center"
        xAxisTop.labels.style = HICSSObject()
        xAxisTop.labels.style.fontSize = "16px"
        xAxisTop.labels.useHTML = true
        
        xAxisTop.labels.formatter
            = HIFunction(jsFunction:
                            "function () {"
                            + "if(this.pos == 2){"
                            + "return '<p style=\"line-height: 1; margin: 0; color: #000000\"><b>' + this.value + '</b></p>'"
                            + "} else {"
                            + "return '<p style=\"line-height: 1; margin: 0;\">' + this.value + '</p>'"
                            + "}"
                            + "}"
            )
        
        let xAxisTopStatic = HIXAxis()
        
        xAxisTopStatic.opposite = true
        xAxisTopStatic.type = "category"
        
        xAxisTopStatic.categories = ["\(static_premium) kr", "\(static_premium) kr", "\(static_premium) kr", "\(static_premium) kr"]
        
        xAxisTopStatic.min = 0
        xAxisTopStatic.max = NSNumber(value: xAxisTop.categories.count - 1)
        
        xAxisTopStatic.lineColor = HIColor(hexValue: "ECECEC")
        xAxisTopStatic.tickColor = HIColor(hexValue: "ECECEC")
        xAxisTopStatic.tickLength = 40
        xAxisTopStatic.tickWidth = 1
        
        xAxisTopStatic.labels = HILabels()
        xAxisTopStatic.labels.align = "center"
        xAxisTopStatic.labels.style = HICSSObject()
        xAxisTopStatic.labels.style.fontSize = "16px"
        xAxisTopStatic.labels.useHTML = true
        
        xAxisTopStatic.labels.formatter
            = HIFunction(jsFunction:
                            "function () {"
                            + "if(this.pos == 2){"
                            + "return '<p style=\"line-height: 1; margin: 0; color: #000000\"><b>' + this.value + '</b></p>'"
                            + "} else {"
                            + "return '<p style=\"line-height: 1; margin: 0;\">' + this.value + '</p>'"
                            + "}"
                            + "}"
            )
        
        options.xAxis = [xAxis, xAxisTop, xAxisTopStatic]
        
        let tooltip = HITooltip()
        tooltip.enabled = false
        options.tooltip = tooltip
        
        let plotOptions = HIPlotOptions()
        
        plotOptions.arearange = HIArearange()
        plotOptions.arearange.step = "left"
        
        plotOptions.line = HILine()
        plotOptions.line.step = "left"
        
        plotOptions.series = HISeries()
        
        plotOptions.series.states = HIStates()
        plotOptions.series.states.hover = HIHover()
        plotOptions.series.states.hover.enabled = false
        plotOptions.series.enableMouseTracking = false
        
        plotOptions.series.lineWidth = 2
        plotOptions.series.marker = HIMarker()
        plotOptions.series.marker.enabled = false
        
        let patternObject = HIPatternObject()
        patternObject.pattern = HIPatternOptionsObject()
        patternObject.pattern.path = "M 0 0 L 20 20 M 18 -2 L 22 2 M -2 18 L 2 22"
        patternObject.pattern.width = 20
        patternObject.pattern.height = 20
        patternObject.pattern.opacity = 1
        patternObject.pattern.backgroundColor = "#f8f8f8"
        
        plotOptions.arearange.fillColor = HIColor(pattern: patternObject)
        
        let plotOptions2 = plotOptions.copy() as! HIPlotOptions
        let patternObject2 = patternObject.copy() as! HIPatternObject
        patternObject2.pattern.backgroundColor = "rgba(0,252,255,0.2)"
        plotOptions.arearange.fillColor = HIColor(pattern: patternObject2)
        
        
        plotOptions.series.animation = HIAnimationOptionsObject()
        plotOptions.series.animation.duration = 0
        
        options.plotOptions = plotOptions
        
        let dynamic_range_active2 = dynamic_range_active.copy() as! HIArearange
        dynamic_range_active.xAxis = 0
        dynamic_range_active2.xAxis = 1
        
        options.series = [dynamic_line_active, dynamic_range_active, dynamic_range_active2, static_line]
        
        let options2 = options.copy() as! HIOptions
        
        options2.plotOptions = plotOptions2
        
        
        
        
        let dynamic_range2 = dynamic_range.copy() as! HIArearange
        dynamic_range.xAxis = 0
        dynamic_range2.xAxis = 2
        
        
        options2.series = [dynamic_line, dynamic_range, dynamic_range2, static_line_active]
        
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
