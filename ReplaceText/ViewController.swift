//
//  ViewController.swift
//  ReplaceText
//
//  Created by Elsayed Hussein on 6/17/19.
//  Copyright © 2019 Elsayed Hussein. All rights reserved.
//

import UIKit
import MobileCoreServices
import PDFKit

class ViewController: UIViewController {
    
    //MARK: Variables
    var pdfFileURL: URL?
    var newPDFFileURL: URL?
    
    //MARK: Outlets
    @IBOutlet weak var choosePDFFileButton: UIButton!
    @IBOutlet weak var textToReplaceTextField: UITextField!
    @IBOutlet weak var textToReplaceWithTextField: UITextField!
    @IBOutlet weak var replaceAllOccerrencesButton: UIButton!
    
    
    //MARK: View lifcycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Actions
    fileprivate func openPDFViewer(_ pdfFileURL: URL, pdfDocument: PDFDocument? = nil) {
        
        let pdfDocument = pdfDocument == nil ? PDFDocument(url: pdfFileURL) : pdfDocument!
        
        performSegue(withIdentifier: "showPDFFile", sender: pdfDocument)
    }
    
    @IBAction func choosePDFFIleDidTapped(_ sender: UIButton) {
        if let pdfFileURL = pdfFileURL {
            openPDFViewer(pdfFileURL)
        } else {
            let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true)
        }
    }
    
    @IBAction func replaceAllOccrrencesDidTapped(_ sender: Any) {
        if let pdfFileURL = pdfFileURL, let textToReplace = textToReplaceTextField.text, let textToReplaceWith = textToReplaceWithTextField.text {
            
            if let url = newPDFFileURL {
                openPDFViewer(url)
            } else {
                if let pdfFile = PDFDocument(url: pdfFileURL) {
                    createPDFFile(pdfFile: pdfFile, textToReplace: textToReplace, textToReplaceWith: textToReplaceWith)
                }
            }
        }
    }
    
    fileprivate func saveDataToFiles(_ data: Data) {
        let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = replaceAllOccerrencesButton
        activityController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        activityController.popoverPresentationController?.sourceRect = CGRect(x: (replaceAllOccerrencesButton.bounds.midX - (replaceAllOccerrencesButton.bounds.width/2)), y: (replaceAllOccerrencesButton.bounds.midY - (replaceAllOccerrencesButton.bounds.height/2)), width: replaceAllOccerrencesButton.bounds.width, height: replaceAllOccerrencesButton.bounds.height)
        activityController.popoverPresentationController?.sourceView = replaceAllOccerrencesButton
        self.present(activityController, animated: true, completion: nil)
    }
    
    private func createPDFFile(pdfFile: PDFDocument, textToReplace: String, textToReplaceWith: String) {
        do {
            
            let DocumentDirURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent("NewFile").appendingPathExtension("pdf")
            
            guard let box = pdfFile.page(at: 0)?.pageRef?.getBoxRect(.mediaBox) else {
                return
            }
            let pageRect = CGRect(x: 0, y: 0, width: box.width, height: box.height)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            
            let data = renderer.pdfData { ctx in
                
                let pageCount = pdfFile.pageCount
                for i in 0..<pageCount {
                    ctx.beginPage()
                    guard let page = pdfFile.page(at: i) else { continue }
                    guard var pageContent = page.attributedString?.mutableCopy() as? NSMutableAttributedString else { continue }
                    pageContent = pageContent.stringWithString(stringToReplace: textToReplace, replacedWithString: textToReplaceWith)
                    pageContent.draw(in: pageRect.insetBy(dx: 50, dy: 50))
                }
            }
            saveDataToFiles(data)
            
            newPDFFileURL = fileURL
            replaceAllOccerrencesButton.setTitle("Process done, show", for: .normal)
            
        } catch {
            print("Error 2 \(error)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPDFFile" {
            let pdfViewerVC = segue.destination as! PDFViewerViewController
            pdfViewerVC.pdfDocument = sender as? PDFDocument
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pdfFileURL = urls.first
        choosePDFFileButton.setTitle("PDF file selected, Show", for: .normal)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textToReplaceTextField {
            textToReplaceWithTextField.returnKeyType = .done
            textToReplaceWithTextField.becomeFirstResponder()
        } else if textField == textToReplaceWithTextField {
            view.endEditing(true)
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        newPDFFileURL = nil
//        pdfFileURL = nil
//        choosePDFFileButton.setTitle("Choose PDF file..", for: .normal)
//        replaceAllOccerrencesButton.setTitle("Text to replace with", for: .normal)
    }
}
extension NSAttributedString {
    func stringWithString(stringToReplace: String, replacedWithString newStringPart: String) -> NSMutableAttributedString
    {
        let mutableAttributedString = mutableCopy() as! NSMutableAttributedString
        let mutableString = mutableAttributedString.mutableString
        while mutableString.contains(stringToReplace) {
            let rangeOfStringToBeReplaced = mutableString.range(of: stringToReplace)
            mutableAttributedString.replaceCharacters(in: rangeOfStringToBeReplaced, with: newStringPart)
        }
        return mutableAttributedString
    }
}
