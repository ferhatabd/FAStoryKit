//
//  TouchProgressCalculator.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 28.09.2019.
//

import Foundation
import CoreGraphics

struct TouchProgressCalculator {
    
    /* ==================================================== */
    /* MARK: Properties                                     */
    /* ==================================================== */
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    /// Origin of the calculation
    public var origin: CGPoint {
        return _o
    }
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    /**
     Current touch point
     */
    private var _p1 = CGPoint()
    
    /**
     Previous touch point
     */
    private var _p2 = CGPoint()
    
    /**
     Origin point for all calculations
     */
    private var _o = CGPoint()
    // -----------------------------------
    
    
    /* ==================================================== */
    /* MARK: Init                                           */
    /* ==================================================== */
    init(origin: CGPoint) {
        _o.x = origin.x
        _o.y = origin.y
    }
    
    /* ==================================================== */
    /* MARK: Methods                                        */
    /* ==================================================== */
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    /**
     Method to calculate and get back the progress in return
     - parameters:
        - from: old touch point
        - to: current touch point
    - returns: CGFloat: The progress of the touch
     */
    func getProgressFromPoint(_ from: CGPoint, to: CGPoint) -> CGFloat {
        // get the "from" vector
        let u = getVector(from: _o, to: from)
        
        // get the angle of the from vector
        let a = getAngleFromVector(u)
        
        // get the "to" vector
        let v = getVector(from: _o, to: to)
        
        // get the angle of the to vector
        let b = getAngleFromVector(v)
        
        // get the difference vector
        let w = substractVector(v, from: u)
        
        let magnitude = self.magnitude(of: w).toCGFloat()
        
        if a > b { // rotating in negative direction
            return -magnitude
        } else if a < b { // rotating in positive direction
            return magnitude
        } else {  // straight up or straight down
            return (a > 0) ? (magnitude) : (-magnitude)
        }
    }
    
    /// Calculates the angle of a point with respect to the origin
    /// - Parameter of: The point of interetes
    /// - returns: The positive angle in Radiants
    func getAngleToOrigin(_ of: CGPoint) -> Double {
        // get the "from" vector
        let u = getVector(from: _o, to: of)
        
        return getAngleFromVector(u)
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    /**
     Method to get a 2D vector from a given line
     */
    private func getVector(from: CGPoint, to: CGPoint) -> CGPoint {
        let x1 = from.x
        
        let y1 = from.y
        
        let x2 = to.x
        
        let y2 = to.y
        
        return CGPoint(x: x2-x1, y: y2-y1)
    }
    
    
    /**
     Gets a vector and returns its angle judging its quadrants
     */
    private func getAngleFromVector(_ u: CGPoint) -> Double {
        let x1 = u.x.toDouble()
        
        let y1 = u.y.toDouble()
        
        if x1 == 0 {
            if y1 > 0 {
                return (0 as Double).toRadiants()
            } else if y1 < 0 {
                return (-180 as Double).toRadiants()
            } else {
                return 0
            }
        }
        return atan2(x1, y1)
        
    }
    
    /**
     Gets a vector and returns its quadrant
     */
    private func getQuadrantOf(_ u: CGPoint) -> Int {
        if u.x < 0 {
            return (u.y < 0) ? (2) : (1)
        } else {
            return (u.y >= 0) ? (0) : (3)
        }
    }
    
    
    /**
     Substract vectors
     - parameters:
        - u: old point
        - v: current point
     - returns: CGPoint: Vector from the old point to the current point
     */
    private func substractVector(_ u: CGPoint, from v: CGPoint) -> CGPoint {
        let w = CGPoint(x: v.x - u.x, y: v.y - u.y)
        return w
    }
    
    
    /**
     Method to calculate the magnitude of a vector
     */
    private func magnitude(of u: CGPoint) -> Double {
        let x = u.x.toDouble()
        
        let y = u.y.toDouble()
        
        return sqrt(x*x + y*y)
    }
    // -----------------------------------
}
