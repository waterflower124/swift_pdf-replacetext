//
//  PDFViewerViewController.swift
//  ReplaceText
//
//  Created by Elsayed Hussein on 6/17/19.
//  Copyright © 2019 Elsayed Hussein. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {

    //MARK: Variables
    var pdfDocument: PDFDocument?
    
    //MARK: Outlets
    @IBOutlet weak var pdfView: PDFView!
    
    
    //MARK: View lifcycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pdfDocument = pdfDocument else {
            return
        }

         pdfView.document = pdfDocument
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
