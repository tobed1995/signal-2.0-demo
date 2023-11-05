//
//  Home.swift
//  Signal 2.0 Demo
//
//  Created by Taha Obed on 05.11.23.
//

import SwiftUI
import AVKit

struct Home: View {
    
    @State private var message = ""
    
    @StateObject var viewModel  = ImageViewModel()
    
    var body: some View {
        NavigationStack {
            
            // Sample Signat Chat View
            
            VStack {
                ScrollView {
                    
                }
                
                VStack {
                    
                    HStack {
                        
                        Button(action: viewModel.openImagePicker, label: {
                            Image(systemName: viewModel.showImagePicker ? "xmark" : "plus")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        })
                        
                        TextField("New Message", text: $message, onEditingChanged: {(opened) in
                            if opened && viewModel.showImagePicker {
                                withAnimation {
                                    viewModel.showImagePicker.toggle()
                                }
                            }
                        })
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(Capsule())
                        
                        Button(action: {}, label: {
                            Image(systemName: "camera")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        })
                        
                        Button(action: {}, label: {
                            Image(systemName: "mic")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        })
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        HStack(spacing: 10) {
                            // Images...
                            ForEach(viewModel.fetchedPhotos) { photo in
                                ThumbnailView(photo: photo)
                                    .onTapGesture {
                                        viewModel.extractPreviewData(asset: photo.asset)
                                        viewModel.showPreview.toggle()
                                    }
                                
                            }
                            
                            // more of Give access Button
                            if viewModel.libraryStatus == .denied ||
                                viewModel.libraryStatus == .limited {
                                VStack(spacing:15) {
                                    Text(viewModel.libraryStatus == .denied ?
                                         "Allow Access For Photos" : "Select More Photos")
                                    .foregroundStyle(.gray)
                                    
                                    Button(action: {
                                        // Go to Settings
                                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                                    }, label: {
                                        Text(viewModel.libraryStatus == .denied ? "Allow Access" : "Select More")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                            .padding(.vertical,10)
                                            .padding(.horizontal)
                                            .background(Color.blue)
                                            .cornerRadius(5)
                                        
                                    })
                                }
                                .frame(width:150)
                            }
                            
                        }
                        .padding()
                    })
                    // Showing when Button Clicked...
                    .frame(height: viewModel.showImagePicker ? 200 : 0)
                    .background(Color.primary.opacity(0.04)
                        .ignoresSafeArea(.all, edges: .bottom))
                    .opacity(viewModel.showImagePicker ? 1 : 0)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {}, label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    })
                }
                ToolbarItem(id: "PROFILE", placement: .topBarLeading, showsByDefault: true) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 35, height: 35)
                            .overlay (
                                Text("K")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                )
                        Text("Kavsoft")
                            .fontWeight(.semibold)
                        
                        Image(systemName: "person.circle")
                            .font(.caption)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}, label: {
                        Image(systemName: "camera")
                            .font(.title2)
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}, label: {
                        Image(systemName: "phone")
                            .font(.title2)
                    })
                }
            }
        }
        .tint(.primary)
        .onAppear(perform: viewModel.setUp)
        .sheet(isPresented: $viewModel.showPreview) {
            viewModel.selectedVideoPreview = nil
            viewModel.selectedImagePreview = nil
        } content: {
            PreviewView()
                .environmentObject(viewModel)
            
        }

    }
}

// Preview View

struct PreviewView: View {
    @EnvironmentObject var viewModel: ImageViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.selectedVideoPreview != nil {
                    VideoPlayer(player: AVPlayer(playerItem: AVPlayerItem(asset: viewModel.selectedVideoPreview)))
                }
                if viewModel.selectedImagePreview != nil {
                    Image(uiImage: viewModel.selectedImagePreview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {}, label: {
                        Text("Send")
                    })
                }
            })
        }
    }
}

struct ThumbnailView: View {
    var photo: Asset
    
    var body: some View {
        ZStack(alignment: .bottomTrailing, content: {
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(10)
            
            // If its Video
            // Displaying Video Icon
            
            if photo.asset.mediaType == .video {
                Image(systemName: "video.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(8)
            }
        })
    }
}

#Preview {
    Home()
}
