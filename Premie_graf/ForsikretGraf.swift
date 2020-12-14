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

class ForsikretGraf: UIViewController {
    var chartView: HIChartView!
    
    // Premium history from insurance object
    // (https://www.tillit.eu/api/v1/insuranceobjects/iPhone%20XS%20Max/)
    struct Premium {
        var id: Int
        var premium_base: Int
        var created: String
    }
    
    let premium_set: [Premium]  = [
        Premium(id: 85, premium_base: 1800, created: "2020-10-29T12:28:09.793201Z"),
        Premium(id: 85, premium_base: 1500, created: "2020-09-28T12:28:09.793201Z"),
        Premium(id: 85, premium_base: 1900, created: "2020-08-20T12:28:09.793201Z"),
    ]
    
    struct UserInsurance {
        var price: Int
        var has_dynamic_price: Bool
    }
    
    struct Charge {
        var amount: Int
        var due_date: String
        var status: String
    }
    
    // Static: If 12-1 charges with same prices -> Be ready for update
    // https://www.tillit.eu/api/v1/insurances/677/
    let insurance = UserInsurance(price: 2100, has_dynamic_price: false)
    
    // First charge, next premium not set | ["CHARGED"]
//        let charges = [
//            Charge(amount: 1500, due_date: "2020-12-14T07:30:31Z", status: "CHARGED"),
//        ]
    
    // Next premium has been set | ["CHARGED", "WAITING"]
//        let charges = [
//            Charge(amount: 1500, due_date: "2020-12-13T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1500, due_date: "2021-01-12T07:30:31Z", status: "WAITING"),
//        ]
    
    // New charge, next premium not set | ["CHARGED", "CHARGED"] Set second index bold
//        let charges = [
//            Charge(amount: 1500, due_date: "2020-11-14T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1500, due_date: "2020-12-14T07:30:31Z", status: "CHARGED"),
//        ]
    
    // Multiple charges, next premium not set | ["CHARGED", "WAITING"]
//        let charges = [
//            Charge(amount: 1600, due_date: "2020-09-14T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1600, due_date: "2020-10-14T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1500, due_date: "2020-11-13T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1500, due_date: "2020-12-13T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1500, due_date: "2021-01-12T07:30:31Z", status: "WAITING"),
//        ]
    
    // Multiple charges, next premium not set | ["CHARGED", "WAITING"]
//    let charges = [
//        Charge(amount: 1600, due_date: "2020-09-15T07:30:31Z", status: "CHARGED"),
//        Charge(amount: 1600, due_date: "2020-10-15T07:30:31Z", status: "CHARGED"),
//        Charge(amount: 1500, due_date: "2020-11-14T07:30:31Z", status: "CHARGED"),
//        Charge(amount: 1500, due_date: "2020-12-14T07:30:31Z", status: "WAITING"),
//    ]
    
    // Multiple charges, next premium not set | ["CHARGED", "CHARGED"]
//        let charges = [
//            Charge(amount: 1500, due_date: "2020-09-15T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1500, due_date: "2020-10-15T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1500, due_date: "2020-11-14T07:30:31Z", status: "CHARGED"),
//            Charge(amount: 1500, due_date: "2020-12-14T07:30:31Z", status: "CHARGED"),
//        ]

    
    // Multiple charges, next premium not set | ["CHARGED", "CHARGED"]
        let charges = [
            Charge(amount: 1500, due_date: "2020-01-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-02-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-03-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-04-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-05-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-06-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-07-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-08-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-09-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-10-15T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-11-14T07:30:31Z", status: "CHARGED"),
            Charge(amount: 1500, due_date: "2020-12-14T07:30:31Z", status: "CHARGED"),
            Charge(amount: 2300, due_date: "2021-01-13T07:30:31Z", status: "WAITING"),
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Date of period start
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        // Current Period start date
        var currentPremium = 0,
            currentPremiumDate = 0.00,
            previousPremium = 0,
            previousPremiumDate = 0.00,
            nextPremium = 0,
            nextPremiumDate = 0.00,
            premiumEstimateHigh = 0,
            premiumEstimateLow = 0,
            premiumEstimateDate = 0.00,
            chargedCount = 0
        
        
        // Set charge status scenario
        if(charges.count == 1){
            // First charge, next premium not set | ["CHARGED"]
            currentPremiumDate = (formatter2.date(from: charges[0].due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
            nextPremium = charges[0].amount / 100
            nextPremiumDate = currentPremiumDate
            premiumEstimateHigh = Int((Double(nextPremium) * 1.20).rounded(.awayFromZero))
            premiumEstimateLow = Int((Double(nextPremium) * 0.80).rounded(.towardZero))
            premiumEstimateDate = nextPremiumDate + (30 * 24 * 60 * 60 * 1000) + (2 * 60 * 60 * 1000)
            
            chargedCount+=1
            
        } else if (charges.count == 2 ){
            // New charge, next premium not set | ["CHARGED", "CHARGED"]
            print("New charge, next premium not set")
            currentPremium = charges[charges.count - 2].amount / 100
            currentPremiumDate = (formatter2.date(from: charges[charges.count - 2].due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
            nextPremium = charges[charges.count - 1].amount / 100
            nextPremiumDate = (formatter2.date(from: charges[charges.count - 1].due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
            premiumEstimateHigh = Int((Double(nextPremium) * 1.20).rounded(.awayFromZero))
            premiumEstimateLow = Int((Double(nextPremium) * 0.80).rounded(.towardZero))
            premiumEstimateDate = nextPremiumDate + (30 * 24 * 60 * 60 * 1000) + (2 * 60 * 60 * 1000)
            chargedCount = charges.count
            //            charges[charges.count - 1].status == "CHARGED"
        } else if (charges.count > 2){
            print("New charge, next premium not set")
            previousPremium = charges[charges.count - 3].amount / 100
            previousPremiumDate = (formatter2.date(from: charges[charges.count - 3].due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
            
            currentPremium = charges[charges.count - 2].amount / 100
            currentPremiumDate = (formatter2.date(from: charges[charges.count - 2].due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
            nextPremium = charges[charges.count - 1].amount / 100
            nextPremiumDate = (formatter2.date(from: charges[charges.count - 1].due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
            premiumEstimateHigh = Int((Double(nextPremium) * 1.20).rounded(.awayFromZero))
            premiumEstimateLow = Int((Double(nextPremium) * 0.80).rounded(.towardZero))
            premiumEstimateDate = nextPremiumDate + (30 * 24 * 60 * 60 * 1000) + (2 * 60 * 60 * 1000)
            chargedCount = charges.count
        }
        
        let today = Date().timeIntervalSince1970*1000
        
        self.chartView = HIChartView(frame:  CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 320))
        
        self.chartView.plugins = ["pattern-fill"]
        
        self.chartView.alpha = 1
        
        let options = HIOptions()
        
        let chart = HIChart()
        
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
        
        let nextPremiumDateBeforeBefore = nextPremiumDate - (60 * 24 * 60 * 60 * 1000)
        let nextPremiumDateBefore = nextPremiumDate - (30 * 24 * 60 * 60 * 1000)
        let premiumEstimateDateNext = premiumEstimateDate + (30 * 24 * 60 * 60 * 1000)
        
        // Initial purchase
        
        // Dynamic range
        let dynamic_range = HIArearange()
        dynamic_range.name = "dynamic_range"
        if(self.insurance.has_dynamic_price || ((charges.count % 12 == 0) || (chargedCount + 1) % 12 == 0)){
            dynamic_range.data = [
                [nextPremiumDate, nextPremium, nextPremium], // This period (10/28/2020)
                [premiumEstimateDate, premiumEstimateLow, premiumEstimateHigh], // Next 30 days (11/27/2020)
                [premiumEstimateDateNext, premiumEstimateLow, premiumEstimateHigh] // Next 60 days (12/27/2020)
            ]
        }
        
        // Dynamic line
        let dynamic_line = HILine()
        
        dynamic_line.lineWidth = 2
        if(self.insurance.has_dynamic_price || ((charges.count % 12 == 0) || (chargedCount + 1) % 12 == 0)){
            
            if(currentPremium == 0 && previousPremium == 0) {
                dynamic_line.data = [
                    [nextPremiumDate, nextPremium], // This period (10/28/2020)
                    [premiumEstimateDate, nextPremium], // Next 30 days (11/27/2020)
                ]
            } else if(nextPremium > 0 && previousPremium == 0){
                dynamic_line.data = [
                    [currentPremiumDate, currentPremium as Any], // 30 days ago (09/28/2020)
                    [nextPremiumDate, nextPremium], // This period (10/28/2020)
                    [premiumEstimateDate, nextPremium], // Next 30 days (11/27/2020)
                ]
            } else if(nextPremium > 0 && previousPremium > 0) {
                dynamic_line.data = [
                    [previousPremiumDate, previousPremium], // 60 days ago (08/29/2020)
                    [currentPremiumDate, currentPremium], // 30 days ago (09/28/2020)
                    [today, currentPremium],
                    [nextPremiumDate, nextPremium], // This period (10/28/2020)
                    [premiumEstimateDate, nextPremium], // Next 30 days (11/27/2020)
                ]
            }
        } else {
            if(currentPremium == 0 && previousPremium == 0) {
                dynamic_line.data = [
                    [nextPremiumDate, nextPremium], // This period (10/28/2020)
                    [premiumEstimateDate, nextPremium], // Next 30 days (11/27/2020)
                    [premiumEstimateDateNext, nextPremium], // Next 60 days (11/27/2020)
                ]
            } else if(nextPremium > 0 && previousPremium == 0){
                dynamic_line.data = [
                    [currentPremiumDate, currentPremium as Any], // 30 days ago (09/28/2020)
                    [nextPremiumDate, nextPremium], // This period (10/28/2020)
                    [premiumEstimateDate, nextPremium], // Next 30 days (11/27/2020)
                    [premiumEstimateDateNext, nextPremium], // Next 60 days (11/27/2020)
                ]
            } else if(nextPremium > 0 && previousPremium > 0) {
                dynamic_line.data = [
                    [previousPremiumDate, previousPremium as Any], // 60 days ago (08/29/2020)
                    [currentPremiumDate, currentPremium as Any], // 30 days ago (09/28/2020)
                    [nextPremiumDate, nextPremium], // This period (10/28/2020)
                    [premiumEstimateDate, nextPremium], // Next 30 days (11/27/2020)
                    [premiumEstimateDateNext, nextPremium], // Next 60 days (11/27/2020)
                ]
            }
        }
        
        
        
        dynamic_line.color = HIColor(hexValue: "00FCFF")
        
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
        
        let plotLine = HIPlotLines()
        plotLine.color = HIColor(hexValue: "000000")
        plotLine.width = 1
        plotLine.value = NSNumber(value: today)
        plotLine.label = HILabel()
        
        //        xAxis.labels.formatter = HIFunction(jsFunction:"function () {return Highcharts.dateFormat('%d. %b %y', this.value);}")
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
            NSNumber(value: previousPremiumDate), // 60 days ago (08/29/2020)
            NSNumber(value: currentPremiumDate), // 30 days ago (09/28/2020)
            NSNumber(value: nextPremiumDate), // This period (10/28/2020)
            NSNumber(value: premiumEstimateDate), // Next 30 days (11/27/2020)
            NSNumber(value: premiumEstimateDateNext), // Next 0 days (11/27/2020)
        ]
        xAxis.tickPixelInterval = 0
        xAxis.maxPadding = 0
        xAxis.minPadding = 0
        
        let xAxisTop = HIXAxis()
        
        xAxisTop.opposite = true
        xAxisTop.type = "category"
        
        print("prev", previousPremium,"current", currentPremium, "next", nextPremium)
        
        var estimateString = ""
        if(self.insurance.has_dynamic_price || ((charges.count % 12 == 0) || (chargedCount + 1) % 12 == 0)){
            estimateString = "\(premiumEstimateLow) - \(premiumEstimateHigh) kr"
        } else {
            estimateString = "\(nextPremium) kr"
        }
        
        
        if(currentPremium == 0 && previousPremium == 0) {
            xAxisTop.categories = ["\(nextPremium) kr", estimateString]
        } else if(nextPremium > 0 && previousPremium == 0) {
            xAxisTop.categories = ["\(currentPremium) kr", "\(nextPremium) kr", estimateString]
        } else if(nextPremium > 0 && previousPremium > 0) {
            xAxisTop.categories = ["\(previousPremium) kr", "\(currentPremium) kr", "\(nextPremium) kr", estimateString]
        }
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
        
        if(charges.count > 2){
            
            if(charges[charges.count - 1].status == "WAITING"){
                xAxisTop.labels.formatter
                    = HIFunction(jsFunction:
                                    "function () {"
                                    + "if(this.pos == 1){"
                                    + "return '<p style=\"line-height: 1; margin: 0; color: #000000\"><b>' + this.value + '</b></p>'"
                                    + "} else {"
                                    + "return '<p style=\"line-height: 1; margin: 0;\">' + this.value + '</p>'"
                                    + "}"
                                    + "}"
                    )} else {
                        xAxisTop.labels.formatter
                            = HIFunction(jsFunction:
                                            "function () {"
                                            + "if(this.pos == 2){"
                                            + "return '<p style=\"line-height: 1; margin: 0; color: #000000\"><b>' + this.value + '</b></p>'"
                                            + "} else {"
                                            + "return '<p style=\"line-height: 1; margin: 0;\">' + this.value + '</p>'"
                                            + "}"
                                            + "}"
                            )}
            
        } else {
            if(charges[charges.count - 1].status == "WAITING" || charges.count == 1){
                xAxisTop.labels.formatter
                    = HIFunction(jsFunction:
                                    "function () {"
                                    + "if(this.pos == 0){"
                                    + "return '<p style=\"line-height: 1; margin: 0; color: #000000\"><b>' + this.value + '</b></p>'"
                                    + "} else {"
                                    + "return '<p style=\"line-height: 1; margin: 0;\">' + this.value + '</p>'"
                                    + "}"
                                    + "}"
                    )} else {
                        xAxisTop.labels.formatter
                            = HIFunction(jsFunction:
                                            "function () {"
                                            + "if(this.pos == 1){"
                                            + "return '<p style=\"line-height: 1; margin: 0; color: #000000\"><b>' + this.value + '</b></p>'"
                                            + "} else {"
                                            + "return '<p style=\"line-height: 1; margin: 0;\">' + this.value + '</p>'"
                                            + "}"
                                            + "}"
                            )
                    }}
        
        options.xAxis = [xAxis, xAxisTop]
        
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

        plotOptions.series.animation = HIAnimationOptionsObject()
        plotOptions.series.animation.duration = 0
        
        let patternObject = HIPatternObject()
        patternObject.pattern = HIPatternOptionsObject()
        patternObject.pattern.path = "M 0 0 L 20 20 M 18 -2 L 22 2 M -2 18 L 2 22"
        patternObject.pattern.width = 20
        patternObject.pattern.height = 20
        patternObject.pattern.opacity = 1
        patternObject.pattern.backgroundColor = "rgba(0,252,255,0.2)"
        
        plotOptions.arearange.fillColor = HIColor(pattern: patternObject)
        
        options.plotOptions = plotOptions
        
        dynamic_range.color = HIColor(hexValue: "00FCFF")
        let dynamic_rangePatternObject = HIPatternObject()
        dynamic_rangePatternObject.pattern = HIPatternOptionsObject()
        dynamic_rangePatternObject.pattern.color = "#00FCFF"
        dynamic_range.fillColor = HIColor(pattern: dynamic_rangePatternObject)
        dynamic_range.lineColor = HIColor(hexValue: "00FCFF")
        dynamic_range.lineWidth = 2
        
        let dynamic_range2 = dynamic_range.copy() as! HIArearange
        dynamic_range.xAxis = 0
        dynamic_range2.xAxis = 1
        
        options.series = [dynamic_range, dynamic_range2, dynamic_line]
        
        self.chartView.options = options
        self.view.addSubview(self.chartView)
        
    }
    
}
