//
//  ViewController.swift
//  bible-scramble
//
//  Created by Billy Bunn on 5/4/19.
//  Copyright © 2019 Billy Bunn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    var topPlaceholderArray: [UILabel]!
    var wordBankPlaceholderArray: [UILabel]!
    var currentIndex = 0
//
//    @IBOutlet weak var dragTextField: UITextField!
//    @IBOutlet weak var dropTextField: UITextField!
    
    @IBOutlet weak var dragTextField: UITextView!
    @IBOutlet weak var dropTextField: UITextView!
    
    
    var verseArray = ["Rejoice", "always", "pray", "without", "ceasing"]
    var range: UITextRange = UITextRange()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  dropTextField.layer.borderWidth = 1
     ///   dropTextField.layer.borderColor = UIColor.lightGray.cgColor
    
//        dragTextField.textDragDelegate = self
////        dragTextField.isTextDragActive = true
////        dropTextField.textDropDelegate = self
//        dragTextField.isUserInteractionEnabled = true
//        dropTextField.isUserInteractionEnabled = true
        

        
//        let dragTextInteraction = UIDragInteraction(delegate: self)
//        dragTextField.addInteraction(dragTextInteraction)
//

        
        topPlaceholderArray = createLabels(yLoc : 150, words:verseArray)
        
        
//        let dragTextInteraction = UIDragInteraction(delegate: self)

//        dragTextField.addInteraction(dragTextInteraction)

//        let dropTextInteraction = UIDropInteraction(delegate: self)

//        dropTextField.addInteraction(dropTextInteraction)
    }
    
    // allows shake action
    override func becomeFirstResponder() -> Bool {
        return true
    }
    // shake action
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shuffleArray()
        }
    }
    
    func shuffleArray() {
        var copiedArray = verseArray.map { $0 }
        
        copiedArray.shuffle()
        
        // delete labels in wordBankPlaceholder, if not empty
        currentIndex = 0
        if wordBankPlaceholderArray != nil {
            for label in wordBankPlaceholderArray {
                label.removeFromSuperview()
            }
        }
        
        wordBankPlaceholderArray = createLabels(yLoc: 600, words:copiedArray)
        print("shuffle")
        for (index, label) in wordBankPlaceholderArray.enumerated() {
            let tapAction = UITapGestureRecognizer(target: self, action:#selector(actionTapped(_ :)))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tapAction)
            label.tag = index
        }
        
        //wordBankPlaceholderArray[0].respond
        
        topPlaceholderArray.map { $0.text = ""}
    }
    
    func createLabels(yLoc : Int, words : [String]) -> [UILabel] {
        var placeholderArray = [UILabel]()
        var xLoc = 50
        
        for  word in words {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
            label.center = CGPoint(x: xLoc, y: yLoc)
            label.textAlignment = NSTextAlignment.center
            label.textColor = .white
            label.font = UIFont(name: "SegoeUI-Bold", size: 18)
            label.text = word
            label.sizeToFit()
            xLoc += Int(label.frame.width) + 10
            self.view.addSubview(label)
            
            placeholderArray.append(label)
        }
        return placeholderArray
    }
    
    @objc
    func actionTapped(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            moveLabel(sourceIndex: tag, destinationIndex: currentIndex)
            currentIndex += 1
            
        } else {
            print ("no tag")
        }
    }
    
    func moveLabel(sourceIndex : Int, destinationIndex : Int) {
        UIView.animate(withDuration: 3, animations: {
            self.wordBankPlaceholderArray[sourceIndex].frame = self.topPlaceholderArray[destinationIndex].frame
            self.wordBankPlaceholderArray[sourceIndex].sizeToFit()
        }, completion: {
            (value: Bool) in
            if self.wordBankPlaceholderArray[sourceIndex].text != self.verseArray[destinationIndex] {
                self.wordBankPlaceholderArray[sourceIndex].textColor = .red
            }
        })
    }
    
}

extension ViewController: UITextDropDelegate {

}

extension ViewController: UITextDragDelegate {
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        let dragView = textDraggableView
        
        let selectionRange = textDraggableView.selectedTextRange
        let selectionRects = textDraggableView.selectionRects(for: selectionRange!)
        
        var array: [CGRect] = []
        
        for r in selectionRects {
            array.append(r.rect)
        }
        
        let paramaters = UIDragPreviewParameters(textLineRects: array as [NSValue])
        
        let textViewCopy = UITextView(frame: textDraggableView.frame)
        
        guard let attributedText = dragTextField.attributedText else {
            return nil
        }
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        
        guard let text = dragTextField.text else {
            return nil
        }
        let fullRange = attributedString.mutableString.range(of: text)
        let selectedRange = dragTextField.selectedTextRange
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: fullRange)
//        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: selectedRange)
        
        textViewCopy.attributedText = attributedString
        
        
        let target = UIDragPreviewTarget(container: self.view, center: dragTextField.center)
        
        let targeDragView = UITargetedDragPreview(view: textViewCopy, parameters: paramaters, target: target)
        
        return targeDragView
    }
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        
        self.range = dragRequest.dragRange
        
        if let string = dragTextField.text(in: dragRequest.dragRange) {
            let itemProvider = NSItemProvider(object: string as NSString)
            return [UIDragItem(itemProvider: itemProvider)]
        } else {
            return []
        }
        
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        print("starting drag")
    }
}

// MARK: UIDropInteractionDelegate
extension ViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        let location = session.location(in: self.view)
        let dropOperation: UIDropOperation?
        
        if session.canLoadObjects(ofClass: String.self) {
            
            if dropTextField.frame.contains(location) {
                dropOperation = .copy
            } else {
                dropOperation = .cancel
            }
        }
        else if session.canLoadObjects(ofClass: UIImage.self) {
            
            if  dropTextField.frame.contains(location) {
                dropOperation = .forbidden
            } else {
                dropOperation = .cancel
            }
        }
        else {
            dropOperation = .cancel
        }
        
        return UIDropProposal(operation: dropOperation!)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        if session.canLoadObjects(ofClass: String.self) {
            
            session.loadObjects(ofClass: String.self) { (items) in
                let values = items as [String]
                self.dropTextField.text = values.last
                
            }
        }
    }
}

extension ViewController: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        if let textView = interaction.view as? UITextView {
            let textToDrag = textView.text
            let provider = NSItemProvider(object: textToDrag! as NSString)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
        else if let imageView = interaction.view as? UIImageView {
            let imageToDrag = imageView.image
            let provider = NSItemProvider(object: imageToDrag!)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
        return []
    }
}



/*

 */


