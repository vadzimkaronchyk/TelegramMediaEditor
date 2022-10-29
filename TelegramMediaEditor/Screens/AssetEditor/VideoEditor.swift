//
//  VideoEditor.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/29/22.
//

import AVFoundation
import Photos
import UIKit

final class VideoEditor {
    
    static func editAndSaveAsset(
        _ asset: AVAsset,
        withOverlayImage image: CGImage,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let composition = AVMutableComposition()
        let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        addAudioCompositionTrack(toComposition: composition, asset: asset, timeRange: timeRange)
        
        if let videoTrack = asset.tracks(withMediaType: .video).first,
           let videoCompositionTrack = addVideoCompositionTrack(timeRange: timeRange, composition: composition, videoTrack: videoTrack) {
            let videoComposition = makeVideoComposition(
                composition: composition,
                videoTrack: videoTrack,
                image: image
            )
            addVideoCompositionInstruction(
                toVideoComposition: videoComposition,
                duration: composition.duration,
                videoTrack: videoTrack,
                videoCompositionTrack: videoCompositionTrack
            )
            let exportURL = makeVideoExportPathURL()
            let exportSession = makeVideoExportSession(
                asset: composition,
                videoComposition: videoComposition,
                outputURL: exportURL
            )
            if let exportSession = exportSession {
                let startTime = CFAbsoluteTimeGetCurrent()
                exportSession.exportAsynchronously {
                    print(CFAbsoluteTimeGetCurrent() - startTime)
                    switch exportSession.status {
                    case .completed:
                        self.saveToPhotoLibrary(
                            videoFileURL: exportURL,
                            completion: completion
                        ) 
                    default:
                        completion(false, nil)
                    }
                }
            } else {
                completion(false, nil)
            }
        } else {
            completion(false, nil)
        }
    }
}

private extension VideoEditor {
    
    static func addAudioCompositionTrack(
        toComposition composition: AVMutableComposition,
        asset: AVAsset,
        timeRange: CMTimeRange
    ) {
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            return
        }
        let audioCompositionTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        try? audioCompositionTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)
    }
    
    static func addVideoCompositionTrack(
        timeRange: CMTimeRange,
        composition: AVMutableComposition,
        videoTrack: AVAssetTrack
    ) -> AVMutableCompositionTrack? {
        let videoCompositionTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        videoCompositionTrack?.preferredTransform = videoTrack.preferredTransform
        do {
            try videoCompositionTrack?.insertTimeRange(timeRange, of: videoTrack, at: .zero)
        } catch {
            return nil
        }
        return videoCompositionTrack
    }
    
    static func makeVideoComposition(
        composition: AVMutableComposition,
        videoTrack: AVAssetTrack,
        image: CGImage
    ) -> AVMutableVideoComposition {
        let videoInfo = orientation(from: videoTrack.preferredTransform)
        let videoSize: CGSize = {
            if videoInfo.isPortrait {
                return .init(
                    width: videoTrack.naturalSize.height,
                    height: videoTrack.naturalSize.width
                )
            } else {
                return videoTrack.naturalSize
            }
        }()
        
        let videoLayer = CALayer()
        videoLayer.frame = .init(origin: .zero, size: videoSize)
        
        let overlayLayer = CALayer()
        overlayLayer.contents = image
        overlayLayer.contentsGravity = .resizeAspectFill
        overlayLayer.frame = .init(origin: .zero, size: videoSize)
        
        let outputLayer = CALayer()
        outputLayer.frame = .init(origin: .zero, size: videoSize)
        outputLayer.addSublayer(videoLayer)
        outputLayer.addSublayer(overlayLayer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: outputLayer
        )
        
        return videoComposition
    }
    
    static func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    static func addVideoCompositionInstruction(
        toVideoComposition videoComposition: AVMutableVideoComposition,
        duration: CMTime,
        videoTrack: AVAssetTrack,
        videoCompositionTrack: AVMutableCompositionTrack
    ) {
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: duration
        )
        videoComposition.instructions = [instruction]

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        layerInstruction.setTransform(videoTrack.preferredTransform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
    }
    
    static func makeVideoExportPathURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
    }
    
    static func makeVideoExportSession(asset: AVAsset, videoComposition: AVMutableVideoComposition, outputURL: URL) -> AVAssetExportSession? {
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.videoComposition = videoComposition
        exportSession?.outputFileType = .mov
        exportSession?.outputURL = outputURL
        exportSession?.shouldOptimizeForNetworkUse = true
        return exportSession
    }
    
    static func saveToPhotoLibrary(videoFileURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: videoFileURL)
        }, completionHandler: completion)
    }
}
