//
//  MediaPicker.swift
//  MediaPicker
//
//  Created by Artem Kedrov on 15.03.2022.
//

import SwiftUI
import PhotosUI

typealias URLCompletion = (URL?) -> ()

struct MediaPicker: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = PHPickerViewController
    
    var filter: PHPickerFilter?
    var limit: Int = 0
    var completion: ([AKFile]) -> ()
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = filter
        config.selectionLimit = limit
        config.preferredAssetRepresentationMode = .current
        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    
    class Coordinator: PHPickerViewControllerDelegate {
        var photoPicker: MediaPicker
        
        init(with photoPicker: MediaPicker) {
            self.photoPicker = photoPicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let group = DispatchGroup()
            var files = [AKFile]()
            for result in results {
                let itemProvider = result.itemProvider
                
                guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                      let utType = UTType(typeIdentifier)
                else { continue }
                
                if utType.conforms(to: .image) {
                    group.enter()
                    self.getPhotoData(from: itemProvider) { url in
                        if let url = url {
                            let uuid = UUID().uuidString
                            files.append(.init(id: uuid, localURL: url))
                        }
                        group.leave()
                    }
                } else if utType.conforms(to: .movie) {
                    group.enter()
                    self.getVideo(from: itemProvider, typeIdentifier: typeIdentifier) { url in
                        if let url = url {
                            let uuid = UUID().uuidString
                            files.append(.init(id: uuid, localURL: url))
                        }
                        group.leave()
                    }
                } else {
                    guard let assetIdentifier = result.assetIdentifier else { continue }
                    group.enter()
                    self.getLivePhotoData(from: itemProvider, assetIdentifier: assetIdentifier) { url in
                        if let url = url {
                            let uuid = UUID().uuidString
                            files.append(.init(id: uuid, localURL: url))
                        }
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {[weak self] in
                guard let self = self else { return }
                picker.dismiss(animated: true) {[weak self] in
                    self?.photoPicker.completion(files)
                }
            }
        }
        
        
        private func getPhotoData(from itemProvider: NSItemProvider, completion: @escaping URLCompletion) {
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else { completion(nil); return }
            let fileName = itemProvider.suggestedName ?? UUID().uuidString
            itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = (object as? UIImage), let data = image.jpegData(compressionQuality: 1.0) {
                    do {
                        let url = try AKFileManager.shared.writeToTempDir(data, fileName: fileName, fileExtension: "jpeg")
                        completion(url)
                    } catch let error {
                        assertionFailure(error.localizedDescription)
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
        
        private func getLivePhotoData(from itemProvider: NSItemProvider, assetIdentifier: String, completion: @escaping URLCompletion) {
            guard let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject else { completion(nil); return }
            PHImageManager.default().requestImageDataAndOrientation(for: phAsset, options: nil) { data, _, _, _ in
                guard let data = data else {
                    completion(nil)
                    return
                }
                do {
                    let url = try AKFileManager.shared.writeToTempDir(data, fileName: itemProvider.suggestedName ?? UUID().uuidString, fileExtension: "jpeg")
                    completion(url)
                } catch let error {
                    assertionFailure(error.localizedDescription)
                    completion(nil)
                }
            }
        }
        
        
        private func getVideo(from itemProvider: NSItemProvider, typeIdentifier: String, completion: @escaping URLCompletion) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    completion(nil)
                    return
                }
                
                guard let url = url else { completion(nil); return }
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent) else { completion(nil); return }
                
                do {
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try AKFileManager.shared.remove(at: targetURL)
                    }
                    try FileManager.default.copyItem(at: url, to: targetURL)
                    completion(targetURL)
                } catch {
                    assertionFailure(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
}

extension UIImage {
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}
