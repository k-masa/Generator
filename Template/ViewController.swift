//
//  ViewController.swift
//  Template
//
//  Created by Kato Masaya on 5/24/15.
//  Copyright (c) 2015 Kato Masaya. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    enum ClassName: String {
        case UIViewController = "UIViewController"
        case UIView           = "UIView"
        
        func getAppendFileName() -> String {
            switch self {
            case .UIViewController: return "ViewController"
            case .UIView:           return "View"
            default:                return ""
            }
        }
    }
    
    //////////////////////////////////////////////////
    // MARK: - let -
    
    let dataArr: [ClassName] = [
        ClassName.UIViewController,
        ClassName.UIView,
    ]
    
    //////////////////////////////////////////////////
    // MARK: - var -
    
    var selectedAtIndex: Int = 0

    //////////////////////////////////////////////////
    // MARK: - IBOutlet -
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var fileNameTextField: NSTextField!
    @IBOutlet var fileNameLabel: NSTextField!
    @IBOutlet var fileNameCheckbox: NSButton!
    @IBOutlet var textView: NSTextView!
    
    //////////////////////////////////////////////////
    // MARK: - IBAction -
    
    @IBAction func createBtnTapped(sender: NSButton) {
        createAction()
    }
    
    @IBAction func reloadBtnTapped(sender: AnyObject) {
        saveTemplate()
    }
    
    @IBAction func fileNameCheckboxValueChanged(sender: NSButton) {
        changeFileName()
    }
    
    //////////////////////////////////////////////////
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fileNameTextField.delegate = self
        loadTemplate()
    }

    override var representedObject: AnyObject? {
        didSet {
        }
    }
    
    //////////////////////////////////////////////////
    // MARK: - Private Method -
    
    private func checkText() -> Bool {
        if fileNameTextField.stringValue == "" {
            showAlert(message: "ファイル名が空白です")
            return false
        }
        return true
    }
    
    private func changeFileName() {
        if fileNameCheckbox.state == NSOnState {
            fileNameLabel.stringValue = "\(fileNameTextField.stringValue)\(dataArr[selectedAtIndex].getAppendFileName())"
        } else {
            fileNameLabel.stringValue = fileNameTextField.stringValue
        }
    }
    
    private func saveTemplate() {
        if let string = textView.string {
            let count = string.utf16Count
            let textData = textView.RTFFromRange(NSRange(location: 0, length: count))
            NSUserDefaults.standardUserDefaults().setObject(textData, forKey: dataArr[selectedAtIndex].rawValue)
            showAlert(title: "更新", message: "更新しました")
        }
    }
    
    private func loadTemplate() {
        if let text = NSUserDefaults.standardUserDefaults().dataForKey(dataArr[selectedAtIndex].rawValue) {
            if let attr = NSAttributedString(data: text, options: nil, documentAttributes: nil, error: nil) {
                textView.textStorage?.appendAttributedString(attr)
            }
        }
    }
    
    private func writeToFile(path: String) {
        let filePath = "\(path)/\(self.fileNameLabel.stringValue).swift"
        if !textView.string!.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil) {
            showAlert(message: "書き込みに失敗しました")
        }
    }
    
    private func showAlert(title: String = "エラー", message: String) {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.InformationalAlertStyle
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
    
    private func clearTexts() {
        textView.string               = ""
        fileNameTextField.stringValue = ""
        fileNameLabel.stringValue     = ""
    }
    
    private func createAction() {
        if !checkText() {
            return
        }
        
        let openPanel = NSOpenPanel()
        openPanel.allowsOtherFileTypes            = false
        openPanel.treatsFilePackagesAsDirectories = false
        openPanel.canChooseFiles                  = false
        openPanel.canChooseDirectories            = true
        openPanel.canCreateDirectories            = true
        openPanel.prompt                          = "Choose"
        openPanel.beginSheetModalForWindow(self.view.window!,
            completionHandler: { (button : Int) -> Void in
                if button == NSFileHandlingPanelOKButton{
                    self.writeToFile(openPanel.URL!.path!)
                }
        })
    }
}

//////////////////////////////////////////////////
// MARK: - NSTextFieldDelegate -

extension ViewController: NSTextFieldDelegate {
    override func controlTextDidChange(obj: NSNotification) {
        changeFileName()
    }
}

//////////////////////////////////////////////////
// MARK: - NSTableViewDataSource, NSTableViewDelegate -

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataArr.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let displayName = dataArr[row].rawValue
        return displayName
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        selectedAtIndex = row
        clearTexts()
        loadTemplate()
        return true
    }
    
}
