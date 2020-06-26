//
//  ViewController.swift
//  Drawing
//
//  Created by Hemang on 15/06/20.
//  Copyright © 2020 Hemang Sharma. All rights reserved.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var canvasview: PKCanvasView!
    @IBOutlet weak var pencil: UIBarButtonItem!
    
    let canvasWidth: CGFloat = 768
    let canvasoverscrollHeight: CGFloat = 500
    
    var drawing = PKDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        canvasview.delegate = self
        canvasview.drawing = drawing
        
        canvasview.alwaysBounceVertical = true
        //canvasview.alwaysBounceHorizontal = true
        canvasview.allowsFingerDrawing = true
        
        if let window = parent?.view.window,
            let toolpicker = PKToolPicker.shared(for: window){
            toolpicker.setVisible(true, forFirstResponder: canvasview)
            toolpicker.addObserver(canvasview)
            canvasview.becomeFirstResponder()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let canvasScale = canvasview.bounds.width / canvasWidth
        canvasview.minimumZoomScale = canvasScale
        canvasview.maximumZoomScale = canvasScale
        canvasview.zoomScale = canvasScale
        updatesizefordrawing()
        
        canvasview.contentOffset = CGPoint(x: 0, y: canvasview.adjustedContentInset.top)
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
    
    @IBAction func toggleontouch(_ sender: Any) {
        canvasview.allowsFingerDrawing.toggle()
        pencil.title = canvasview.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    

    @IBAction func savedrawing(_ sender: Any) {
        
        UIGraphicsBeginImageContextWithOptions(canvasview.bounds.size, false, UIScreen.main.scale)
        canvasview.drawHierarchy(in: canvasview.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil{
            PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAsset(from: image!)}, completionHandler: {success, error in
                //deal with it
            })
        }
        
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updatesizefordrawing()
    }
    
    func updatesizefordrawing() {
        let drawing = canvasview.drawing
        let contentheight: CGFloat
        
        if !drawing.bounds.isNull{
            contentheight = max(canvasview.bounds.height,(drawing.bounds.maxY + self.canvasoverscrollHeight) * canvasview.zoomScale)
        }else{
            contentheight = canvasview.bounds.height
        }
        
        canvasview.contentSize = CGSize(width: canvasWidth * canvasview.zoomScale, height: contentheight)
    }
    
}

