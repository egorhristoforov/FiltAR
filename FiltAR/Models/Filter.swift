//
//  Filter.swift
//  FiltAR
//
//  Created by Egor on 25/08/2019.
//  Copyright © 2019 Egor. All rights reserved.
//

import Foundation
import CoreImage

enum FilterType {
    case gaussianBlur
    case boxBlur
    case motionBlur
    case saturationControl
    case brightnessControl
    case contrastControl
    case exposureAdjust
    case hueAdjest
    case vibrance
    case sepiaTone
    case straightenFilter
    case sharpenLuminance
    case edges
    case edgeWork
    case hexagonalPixellate
    case pixellate
    case kaleidoscope
}

class Filter {
    var filter: CIFilter!
    var inputKey: String!
    var name: String!
    var startValue: Float!
    var endValue: Float!
    
    required init(filterType: FilterType) {
        switch filterType {
        case .gaussianBlur:
            self.filter = CIFilter(name: "CIGaussianBlur")
            self.inputKey = kCIInputRadiusKey
            self.name = "Gaussian Blur"
            self.startValue = 0
            self.endValue = 20
        case .boxBlur:
            self.filter = CIFilter(name: "CIBoxBlur")
            self.inputKey = kCIInputRadiusKey
            self.name = "Box Blur"
            self.startValue = 0
            self.endValue = 20
        case .motionBlur:
            self.filter = CIFilter(name: "CIMotionBlur")
            self.inputKey = kCIInputRadiusKey
            self.name = "Motion Blur"
            self.startValue = 0
            self.endValue = 20
        case .saturationControl:
            self.filter = CIFilter(name: "CIColorControls")
            self.inputKey = kCIInputSaturationKey
            self.name = "Saturation"
            self.startValue = -2
            self.endValue = 2
        case .brightnessControl:
            self.filter = CIFilter(name: "CIColorControls")
            self.inputKey = kCIInputBrightnessKey
            self.name = "Brightness"
            self.startValue = -1
            self.endValue = 1
        case .contrastControl:
            self.filter = CIFilter(name: "CIColorControls")
            self.inputKey = kCIInputContrastKey
            self.name = "Contrast"
            self.startValue = -5
            self.endValue = 5
        case .exposureAdjust:
            self.filter = CIFilter(name: "CIExposureAdjust")
            self.inputKey = kCIInputEVKey
            self.name = "Exposure Adjust"
            self.startValue = -8
            self.endValue = 8
        case .hueAdjest:
            self.filter = CIFilter(name: "CIHueAdjust")
            self.inputKey = kCIInputAngleKey
            self.name = "Hue Adjust"
            self.startValue = -5
            self.endValue = 5
        case .vibrance:
            self.filter = CIFilter(name: "CIVibrance")
            self.inputKey = kCIInputAmountKey
            self.name = "Vibrance"
            self.startValue = -10
            self.endValue = 10
        case .sepiaTone:
            self.filter = CIFilter(name: "CISepiaTone")
            self.inputKey = kCIInputIntensityKey
            self.name = "Sepia Tone"
            self.startValue = -10
            self.endValue = 10
        case .straightenFilter:
            self.filter = CIFilter(name: "CIStraightenFilter")
            self.inputKey = kCIInputAngleKey
            self.name = "Straighten Filter"
            self.startValue = -5
            self.endValue = 5
        case .sharpenLuminance:
            self.filter = CIFilter(name: "CISharpenLuminance")
            self.inputKey = kCIInputSharpnessKey
            self.name = "Sharpen Luminance"
            self.startValue = -10
            self.endValue = 10
        case .edges:
            self.filter = CIFilter(name: "CIEdges")
            self.inputKey = kCIInputIntensityKey
            self.name = "Edges"
            self.startValue = 0
            self.endValue = 10
        case .edgeWork:
            self.filter = CIFilter(name: "CIEdgeWork")
            self.inputKey = kCIInputRadiusKey
            self.name = "Edge Work"
            self.startValue = 0
            self.endValue = 10
        case .hexagonalPixellate:
            self.filter = CIFilter(name: "CIHexagonalPixellate")
            self.inputKey = kCIInputScaleKey
            self.name = "Hexagonal Pixellate"
            self.startValue = -10
            self.endValue = 10
        case .pixellate:
            self.filter = CIFilter(name: "CIPixellate")
            self.inputKey = kCIInputScaleKey
            self.name = "Pixellate"
            self.startValue = -10
            self.endValue = 10
        case .kaleidoscope:
            self.filter = CIFilter(name: "CIKaleidoscope")
            self.inputKey = kCIInputAngleKey
            self.name = "Kaleidoscope"
            self.startValue = -5
            self.endValue = 5
        }
    }
    
    func updateKeyValue(newValue: Float) {
        filter.setValue(newValue, forKey: inputKey)
    }
}
