//
//  VideoProcessingManager.swift
//  SLR data annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import AVFoundation

final class VideoProcessingManager {
    ///
    /// Processes all of the frames from the given video as a list of CGFrames.
    ///
    /// - Parameters:
    ///   - videoUrl: URL of the video to be annotated
    ///   - fps: Frames per second to be annotated
    ///
    /// - Returns: Array of frames as CGImages
    ///
    static func getAllFrames(videoUrl: URL, fps: Int) -> [CGImage] {
        // Import the video into AVFoundation
        let asset = AVURLAsset(url: videoUrl)
        let duration = CMTimeGetSeconds(asset.duration)
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 100)
        
        var frames = [CGImage]()
        
        // Process the frames for given frames per second rate at every second
        for secondsIndex in 0 ..< Int(ceil(duration)) {
            for frameIndex in 0 ..< fps {
                let timeForFrame = Double(secondsIndex) + Double(frameIndex) * (1.0 / Double(fps))
                if timeForFrame < duration, let frame = self.getFrame(fromTime: Float64(timeForFrame), generator: generator) {
                    frames.append(frame)
                }
            }
        }
        
        // Prevent additional crashes with the AVFoundation processing
        generator.cancelAllCGImageGeneration()
        return frames
        
    }
    
    ///
    /// Converts the frame from the given AVAssetImageGenerator at the given time within
    /// the encoded video.
    ///
    /// - Parameters:
    ///   - fromTime: Float64 of the time to extract the frame from
    ///   - generator: AVAssetImageGenerator with the video already encoded
    ///
    /// - Returns: Desired frame as CGImage
    ///
    static func getFrame(fromTime: Float64, generator: AVAssetImageGenerator) -> CGImage? {
        let image: CGImage
        
        // Convert the time to the supported CMTime
        let time = CMTimeMakeWithSeconds(fromTime, preferredTimescale: 60)
        
        do {
            // Convert the image at the given time
            try image = generator.copyCGImage(at: time, actualTime: nil)
        } catch {
            return nil
        }
        
        return image
    }
    
    ///
    /// Calculates the given video's size.
    ///
    /// - Parameters:
    ///   - videoUrl: URL of the video to be annotated
    ///
    /// - Returns: CGSize of the given video
    ///
    static func getVideoSize(videoUrl: URL) -> CGSize {
        // Import the video into AVFoundation
        let asset = AVAsset(url: videoUrl)
        guard let track = asset.tracks(withMediaType: AVMediaType.video).first else { return CGSize() }
        
        // Calculate the size using the transformation from the track
        let size = track.naturalSize.applying(track.preferredTransform)
        
        // Convert the data into CGSize
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
