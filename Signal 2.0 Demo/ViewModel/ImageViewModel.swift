//
//  ImageViewModel.swift
//  Signal 2.0 Demo
//
//  Created by Taha Obed on 05.11.23.
//

import SwiftUI
import Photos
import AVKit

class ImageViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    @Published var showImagePicker = false
    
    @Published var libraryStatus: LibraryStatus = .denied
    
    @Published var fetchedPhotos: [Asset] = []
    
    // To Get Updates...
    @Published var allPhotos: PHFetchResult<PHAsset>!
    
    // Preview
    @Published var showPreview = false
    @Published var selectedImagePreview: UIImage!
    @Published var selectedVideoPreview: AVAsset!
    
    func openImagePicker() {
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Fetchin Images When it Needed
        if fetchedPhotos.isEmpty {
            fetchPhotos()
        }
        withAnimation {
            showImagePicker.toggle()
        }
    }
    
    func setUp() {
        // requesting Permission
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) {[self] (status) in
            DispatchQueue.main.async {
                switch status  {
                case .denied: self.libraryStatus = .denied
                case .authorized: self.libraryStatus = .approved
                case .limited: self.libraryStatus = .limited
                default: self.libraryStatus = .denied
                }
            }
        }
        
        // Registering Observer
        PHPhotoLibrary.shared().register(self)
    }
    
    // Listening to changes
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let _ = allPhotos else { return }
        
        if let updates = changeInstance.changeDetails(for: allPhotos) {
            // Getting Updated List...
            let updatedPhotos = updates.fetchResultAfterChanges
            
            // There is bug in it
            // it is not updating the inserted or removed items
//            print(updates.insertedObjects.count)
//            print(updates.removedObjects.count)
            
            // So were going to verify all and append only no in the list
            // to avoid of reloading all and ram usage
            updatedPhotos.enumerateObjects {[self] (asset, index, _) in
                if !allPhotos.contains(asset) {
                    // if its not there
                    // getting image and appending it to array
                    
                    getImageFromAsset(asset: asset, size: CGSize(width: 150, height: 150)) { image in
                        DispatchQueue.main.async {
                            self.fetchedPhotos.append(Asset(asset: asset, image: image))
                        }
                    }
                }
            }
            
            // To remove if Image is removed...
            allPhotos.enumerateObjects{ (asset, index, _) in
                if !updatedPhotos.contains(asset) {
                    // removing it
                    DispatchQueue.main.async {
                        self.fetchedPhotos.removeAll { (result) -> Bool in
                            return result.asset == asset
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.allPhotos = updatedPhotos
            }
        }
    }
    
    func fetchPhotos() {
        // Fetching All Photos
        let options = PHFetchOptions()
        options.sortDescriptors = [
            // Latest to Old..
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.includeHiddenAssets = false
        
        let fetchResults = PHAsset.fetchAssets(with: options)
        
        allPhotos = fetchResults
        
        fetchResults.enumerateObjects {[self] (asset, index, _) in
            
            getImageFromAsset(asset: asset, size: CGSize(width: 150, height: 150)) { (image) in
                /// Appending it to array
                /// Why we storing asset
                /// to get full image for sending
                self.fetchedPhotos.append(Asset(asset: asset, image: image))
            }
            
            
        }
        
    }
    
    /// Using Completion Handlers...
    /// to receive Objects
    func getImageFromAsset(asset: PHAsset,size: CGSize, completion: @escaping (UIImage) -> ()) {
        
        // To cache image in memory
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        
        /// Your Own Properties For Images...
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isSynchronous = false
        
        /// to reduce ram usage just getting thumbnail size of image
        
        let size = CGSize(width: 150, height: 150)
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageOptions) { (image, _) in
            guard let resizedImage = image else { return }
            completion(resizedImage)
        }
        
    }
    
    // Opening Image or Video
    func extractPreviewData(asset: PHAsset) {
        
        let manager = PHCachingImageManager()
        
        if asset.mediaType == .image {
            // Extract Image
            
            getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { image in
                self.selectedImagePreview = image
            }
            
        }
        if asset.mediaType == .video {
            // Extract Video
            
            let videoManager = PHVideoRequestOptions()
            videoManager.deliveryMode = .highQualityFormat
            manager.requestAVAsset(forVideo: asset, options: videoManager) { (videoAsset, _, _) in
                guard let videoUrl = videoAsset else { return }
                DispatchQueue.main.async {
                    self.selectedVideoPreview = videoUrl
                }
            }
        }
        
    }
}
