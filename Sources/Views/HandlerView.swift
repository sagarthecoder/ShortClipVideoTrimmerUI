//
//  HandleView.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Sagar on 9/23/22.
//

import UIKit

class HandlerView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitFrame = bounds.insetBy(dx: -20, dy: -20)
        let leftHandleView = superview?.viewWithTag(-1000)
        let rightHandleView = superview?.viewWithTag(-2000)
        let locationByLeftHandleView = self.convert(point, to: leftHandleView)
        let locationByRightHandleView = self.convert(point, to: rightHandleView)
        let locationByThubnailView = self.convert(point, to: superview?.superview)
        if hitFrame.contains(point) {
            return self
        } else if let leftHandleView = leftHandleView, leftHandleView.bounds.insetBy(dx: -20, dy: -20).contains(locationByLeftHandleView) == true {
            return leftHandleView
        } else if let rightHandleView = rightHandleView,  rightHandleView.bounds.insetBy(dx: -20, dy: -20).contains(locationByRightHandleView) == true {
            return rightHandleView
        } else if let _ = superview?.superview?.subviews[0].bounds.contains(locationByThubnailView) {
            
            return superview?.superview?.subviews[0]
        }
        else {
            return nil
        }
    }
    
}
