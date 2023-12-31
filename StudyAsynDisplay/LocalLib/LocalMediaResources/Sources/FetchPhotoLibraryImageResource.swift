import Foundation
import UIKit
import Photos
import Postbox
import SwiftSignalKit
import ImageCompression
import Accelerate.vImage

private final class RequestId {
    var id: PHImageRequestID?
    var invalidated: Bool = false
}

private func resizedImage(_ image: UIImage, for size: CGSize) -> UIImage? {
    guard let cgImage = image.cgImage else {
        return nil
    }

    var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                      bitsPerPixel: 32,
                                      colorSpace: nil,
                                      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                      version: 0,
                                      decode: nil,
                                      renderingIntent: .defaultIntent)

    var error: vImage_Error
    var sourceBuffer = vImage_Buffer()
    defer { sourceBuffer.data.deallocate() }
    error = vImageBuffer_InitWithCGImage(&sourceBuffer,
                                         &format,
                                         nil,
                                         cgImage,
                                         vImage_Flags(kvImageNoFlags))
    guard error == kvImageNoError else { return nil }

    var destinationBuffer = vImage_Buffer()
    error = vImageBuffer_Init(&destinationBuffer,
                              vImagePixelCount(size.height),
                              vImagePixelCount(size.width),
                              format.bitsPerPixel,
                              vImage_Flags(kvImageNoFlags))
    guard error == kvImageNoError else {
        return nil
    }

    error = vImageScale_ARGB8888(&sourceBuffer,
                                 &destinationBuffer,
                                 nil,
                                 vImage_Flags(kvImageHighQualityResampling))
    guard error == kvImageNoError else {
        return nil
    }

    guard let resizedImage =
        vImageCreateCGImageFromBuffer(&destinationBuffer,
                                      &format,
                                      nil,
                                      nil,
                                      vImage_Flags(kvImageNoAllocate),
                                      &error)?.takeRetainedValue(),
        error == kvImageNoError
    else {
        return nil
    }

    return UIImage(cgImage: resizedImage)
}

extension UIImage.Orientation {
    init(_ cgOrientation: CGImagePropertyOrientation) {
        switch cgOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        }
    }
}

private let fetchPhotoWorkers = ThreadPool(threadCount: 3, threadPriority: 0.2)

public func fetchPhotoLibraryResource(localIdentifier: String, width: Int32?, height: Int32?, format: MediaImageFormat?, quality: Int32?) -> Signal<MediaResourceDataFetchResult, MediaResourceDataFetchError> {
    return Signal { subscriber in
        let queue = ThreadPoolQueue(threadPool: fetchPhotoWorkers)
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        let requestId = Atomic<RequestId>(value: RequestId())
        if fetchResult.count != 0 {
            let asset = fetchResult.object(at: 0)
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            option.isNetworkAccessAllowed = true
            option.isSynchronous = false
            
            let size: CGSize
            if let width, let height {
                size = CGSize(width: CGFloat(width), height: CGFloat(height))
            } else {
                size = CGSize(width: 1280.0, height: 1280.0)
            }
            
            queue.addTask(ThreadPoolTask({ _ in
                let startTime = CACurrentMediaTime()
                
                let semaphore = DispatchSemaphore(value: 0)
                let requestIdValue = PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: { (image, info) -> Void in
                    Queue.concurrentDefaultQueue().async {
                        requestId.with { current -> Void in
                            if !current.invalidated {
                                current.id = nil
                                current.invalidated = true
                            }
                        }
                        if let image = image {
                            if let info = info, let degraded = info[PHImageResultIsDegradedKey], (degraded as AnyObject).boolValue!{

                            } else {
#if DEBUG
                                print("load completion \((CACurrentMediaTime() - startTime) * 1000.0) ms")
#endif
                                
                                let scale = min(1.0, min(size.width / max(1.0, image.size.width), size.height / max(1.0, image.size.height)))
                                let scaledSize = CGSize(width: floor(image.size.width * scale), height: floor(image.size.height * scale))
                                let scaledImage = resizedImage(image, for: scaledSize)
                                
#if DEBUG
                                print("scaled completion \((CACurrentMediaTime() - startTime) * 1000.0) ms")
#endif
                                
                                switch format {
                                case .none, .jpeg:
                                    let tempFile = TempBox.shared.tempFile(fileName: "file")
                                    defer {
                                        TempBox.shared.dispose(tempFile)
                                    }
                                    if let scaledImage = scaledImage, let data = compressImageToJPEG(scaledImage, quality: 0.6, tempFilePath: tempFile.path) {
    #if DEBUG
                                        print("compression completion \((CACurrentMediaTime() - startTime) * 1000.0) ms")
    #endif
                                        subscriber.putNext(.dataPart(resourceOffset: 0, data: data, range: 0 ..< Int64(data.count), complete: true))
                                        subscriber.putCompletion()
                                    } else {
                                        subscriber.putCompletion()
                                    }
                                case .jxl:
                                    if let scaledImage = scaledImage, let data = compressImageToJPEGXL(scaledImage, quality: Int(quality ?? 75)) {
    #if DEBUG
                                        print("jpegxl compression completion \((CACurrentMediaTime() - startTime) * 1000.0) ms")
    #endif
                                        subscriber.putNext(.dataPart(resourceOffset: 0, data: data, range: 0 ..< Int64(data.count), complete: true))
                                        subscriber.putCompletion()
                                    } else {
                                        subscriber.putCompletion()
                                    }
                                }
                                semaphore.signal()
                            }
                        } else {
                            semaphore.signal()
                        }
                    }
                })
                requestId.with { current -> Void in
                    if !current.invalidated {
                        current.id = requestIdValue
                    }
                }
                semaphore.wait()
            }))
        } else {
            subscriber.putNext(.reset)
        }
        
        return ActionDisposable {
            let requestIdValue = requestId.with { current -> PHImageRequestID? in
                if !current.invalidated {
                    let value = current.id
                    current.id = nil
                    current.invalidated = true
                    return value
                } else {
                    return nil
                }
            }
            if let requestIdValue = requestIdValue {
                PHImageManager.default().cancelImageRequest(requestIdValue)
            }
        }
    }
}

public func fetchPhotoLibraryImage(localIdentifier: String, thumbnail: Bool) -> Signal<(UIImage, Bool)?, NoError> {
    return Signal { subscriber in
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        let requestId = Atomic<RequestId>(value: RequestId())
        if fetchResult.count != 0 {
            let asset = fetchResult.object(at: 0)
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            if thumbnail {
                option.resizeMode = .fast
            }
            option.isNetworkAccessAllowed = true
            option.isSynchronous = false
            
            let targetSize: CGSize = thumbnail ? CGSize(width: 128.0, height: 128.0) : PHImageManagerMaximumSize
            let requestIdValue = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: option, resultHandler: { (image, info) -> Void in
                Queue.concurrentDefaultQueue().async {
                    requestId.with { current -> Void in
                        if !current.invalidated {
                            current.id = nil
                            current.invalidated = true
                        }
                    }
                    if let image = image {
                        subscriber.putNext((image, thumbnail))
                        subscriber.putCompletion()
                    }
                }
            })
            requestId.with { current -> Void in
                if !current.invalidated {
                    current.id = requestIdValue
                }
            }
        } else {
            subscriber.putNext(nil)
            subscriber.putCompletion()
        }
        
        return ActionDisposable {
            let requestIdValue = requestId.with { current -> PHImageRequestID? in
                if !current.invalidated {
                    let value = current.id
                    current.id = nil
                    current.invalidated = true
                    return value
                } else {
                    return nil
                }
            }
            if let requestIdValue = requestIdValue {
                PHImageManager.default().cancelImageRequest(requestIdValue)
            }
        }
    }
}

