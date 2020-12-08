//
//  ObservationTerminology.swift
//  SLR_Data_Annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import Vision

public class ObservationTerminology {

    ///
    /// Dictionary for conversion bewteen the `VNRecognizedPointKey` and custom methodology
    /// `String` identifiers for the body landmarks.
    ///
    public static let bodyLandmarksKeysToLabels: [VNHumanBodyPoseObservation.JointName: String] = [
        .nose : "nose",
        .rightEye : "rightEye",
        .leftEye: "leftEye",
        .rightEar: "rightEar",
        .leftEar: "leftEar",
        .rightShoulder: "rightShoulder",
        .leftShoulder: "leftShoulder",
        .rightElbow: "rightElbow",
        .leftElbow: "leftElbow",
        .rightWrist: "rightWrist",
        .leftWrist: "leftWrist"
    ]

    ///
    /// Dictionary for conversion bewteen the `VNRecognizedPointKey` and custom methodology
    /// `String` identifiers for the hand landmarks.
    ///
    public static let handLandmarksKeysToLabels: [VNHumanHandPoseObservation.JointName: String] = [
        .wrist: "wrist",
        .indexTip: "indexTip",
        .indexDIP: "indexDip",
        .indexPIP: "indexPip",
        .indexMCP: "indexMcp",
        .middleTip: "middleTip",
        .middleDIP: "middleDip",
        .middlePIP: "middlePip",
        .middleMCP: "middleMcp",
        .ringTip: "ringTip",
        .ringDIP: "ringDip",
        .ringPIP: "ringPip",
        .ringMCP: "ringMcp",
        .littleTip: "littleTip",
        .littleDIP: "littleDip",
        .littlePIP: "littlePip",
        .littleMCP: "littleMcp",
        .thumbTip: "thumbTip",
        .thumbIP: "thumbIp",
        .thumbMP: "thumbMp",
        .thumbCMC: "thumbCmc"
    ]

    ///
    /// Order of the hand landmarks key order in the String CSV format for the training data.
    ///
    public static let handLandmarksKeyOrder = ["indexDip0X", "indexDip0Y", "indexDip1X", "indexDip1Y", "indexMcp0X", "indexMcp0Y", "indexMcp1X", "indexMcp1Y", "indexPip0X", "indexPip0Y", "indexPip1X", "indexPip1Y", "indexTip0X", "indexTip0Y", "indexTip1X", "indexTip1Y", "littleDip0X", "littleDip0Y", "littleDip1X", "littleDip1Y", "littleMcp0X", "littleMcp0Y", "littleMcp1X", "littleMcp1Y", "littlePip0X", "littlePip0Y", "littlePip1X", "littlePip1Y", "littleTip0X", "littleTip0Y", "littleTip1X", "littleTip1Y", "middleDip0X", "middleDip0Y", "middleDip1X", "middleDip1Y", "middleMcp0X", "middleMcp0Y", "middleMcp1X", "middleMcp1Y", "middlePip0X", "middlePip0Y", "middlePip1X", "middlePip1Y", "middleTip0X", "middleTip0Y", "middleTip1X", "middleTip1Y", "ringDip0X", "ringDip0Y", "ringDip1X", "ringDip1Y", "ringMcp0X", "ringMcp0Y", "ringMcp1X", "ringMcp1Y", "ringPip0X", "ringPip0Y", "ringPip1X", "ringPip1Y", "ringTip0X", "ringTip0Y", "ringTip1X", "ringTip1Y", "thumbCmc0X", "thumbCmc0Y", "thumbCmc1X", "thumbCmc1Y", "thumbIp0X", "thumbIp0Y", "thumbIp1X", "thumbIp1Y", "thumbMp0X", "thumbMp0Y", "thumbMp1X", "thumbMp1Y", "thumbTip0X", "thumbTip0Y", "thumbTip1X", "thumbTip1Y", "wrist0X", "wrist0Y", "wrist1X", "wrist1Y"]

    ///
    /// Order of the body landmarks key order in the String CSV format for the training data.
    ///
    public static let bodyLandmarksKeyOrder = ["leftEarX", "leftEarY", "leftElbowX", "leftElbowY", "leftEyeX", "leftEyeY", "leftShoulderX", "leftShoulderY", "leftWristX", "leftWristY", "noseX", "noseY", "rightEarX", "rightEarY", "rightElbowX", "rightElbowY", "rightEyeX", "rightEyeY", "rightShoulderX", "rightShoulderY", "rightWristX", "rightWristY"]

    ///
    /// Order of the face landmarks key order in the String CSV format for the training data.
    ///
    public static let faceLandmarksKeyOrder = ["landmark0X", "landmark0Y", "landmark10X", "landmark10Y", "landmark11X", "landmark11Y", "landmark12X", "landmark12Y", "landmark13X", "landmark13Y", "landmark14X", "landmark14Y", "landmark15X", "landmark15Y", "landmark16X", "landmark16Y", "landmark17X", "landmark17Y", "landmark18X", "landmark18Y", "landmark19X", "landmark19Y", "landmark1X", "landmark1Y", "landmark20X", "landmark20Y", "landmark21X", "landmark21Y", "landmark22X", "landmark22Y", "landmark23X", "landmark23Y", "landmark24X", "landmark24Y", "landmark25X", "landmark25Y", "landmark26X", "landmark26Y", "landmark27X", "landmark27Y", "landmark28X", "landmark28Y", "landmark29X", "landmark29Y", "landmark2X", "landmark2Y", "landmark30X", "landmark30Y", "landmark31X", "landmark31Y", "landmark32X", "landmark32Y", "landmark33X", "landmark33Y", "landmark34X", "landmark34Y", "landmark35X", "landmark35Y", "landmark36X", "landmark36Y", "landmark37X", "landmark37Y", "landmark38X", "landmark38Y", "landmark39X", "landmark39Y", "landmark3X", "landmark3Y", "landmark40X", "landmark40Y", "landmark41X", "landmark41Y", "landmark42X", "landmark42Y", "landmark43X", "landmark43Y", "landmark44X", "landmark44Y", "landmark45X", "landmark45Y", "landmark46X", "landmark46Y", "landmark47X", "landmark47Y", "landmark48X", "landmark48Y", "landmark49X", "landmark49Y", "landmark4X", "landmark4Y", "landmark50X", "landmark50Y", "landmark51X", "landmark51Y", "landmark52X", "landmark52Y", "landmark53X", "landmark53Y", "landmark54X", "landmark54Y", "landmark55X", "landmark55Y", "landmark56X", "landmark56Y", "landmark57X", "landmark57Y", "landmark58X", "landmark58Y", "landmark59X", "landmark59Y", "landmark5X", "landmark5Y", "landmark60X", "landmark60Y", "landmark61X", "landmark61Y", "landmark62X", "landmark62Y", "landmark63X", "landmark63Y", "landmark64X", "landmark64Y", "landmark65X", "landmark65Y", "landmark66X", "landmark66Y", "landmark67X", "landmark67Y", "landmark68X", "landmark68Y", "landmark69X", "landmark69Y", "landmark6X", "landmark6Y", "landmark70X", "landmark70Y", "landmark71X", "landmark71Y", "landmark72X", "landmark72Y", "landmark73X", "landmark73Y", "landmark74X", "landmark74Y", "landmark75X", "landmark75Y", "landmark76X", "landmark76Y", "landmark7X", "landmark7Y", "landmark8X", "landmark8Y", "landmark9X", "landmark9Y"]

}
