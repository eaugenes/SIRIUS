//
//  ProjectsSection.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI
import UIKit

enum ProjectImageStore {        // Loads a project picture from Supabase Storage once and keeps it in memory
    private static let cache = NSCache<NSString, UIImage>()
    
    static func load(_ path: String) async -> UIImage? {
        if let cached = cache.object(forKey: path as NSString) { return cached }
        guard let image = await SupabaseStore.downloadProjectImage(path: path) else { return nil }
        cache.setObject(image, forKey: path as NSString)
        return image
    }
}

// One square picture: a local photo (not uploaded yet) or a stored picture (loaded by its path)
struct ProjectThumb: View {
    var local: UIImage? = nil
    var path: String? = nil
    var size: CGFloat = 64
    var onTap: ((UIImage) -> Void)? = nil
    
    @State private var loaded: UIImage?
    
    var body: some View {
        Group {
            if let image = local ?? loaded {
                Button {
                    onTap?(image)
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Project picture")
            } else {
                ZStack {
                    Color.siriusFill
                    ProgressView()
                }
                .frame(width: size, height: size)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .task(id: path) {
            guard local == nil, let path else { return }
            loaded = await ProjectImageStore.load(path)
        }
    }
}

private struct PicturePreview: Identifiable {
    let id = UUID()
    let image: UIImage
}

// One project: title, description and its pictures (read-only)
struct ProjectCard: View {
    
    let project: Project
    
    @State private var preview: PicturePreview?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(project.title)
                .scaledFont(size: 14, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
            
            Text(project.details)
                .scaledFont(size: 11)
                .foregroundStyle(Color.siriusMuted)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
            
            if project.pictureCount > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(project.imagePaths.enumerated()), id: \.offset) { _, path in
                            ProjectThumb(path: path) { image in preview = PicturePreview(image: image) }
                        }
                        ForEach(Array(project.newImages.enumerated()), id: \.offset) { _, image in
                            ProjectThumb(local: image) { picked in preview = PicturePreview(image: picked) }
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.siriusFieldFill))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
        .sheet(item: $preview) { item in
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Button {
                    preview = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .scaledFont(size: 28)
                        .foregroundStyle(Color.white.opacity(0.9))
                        .padding(16)
                }
                .accessibilityLabel("Close picture")
            }
        }
    }
}

// The "Projects" block shown on the applicant's Account page and on the employer's Applicant Details
struct ProjectsSection: View {
    
    let projects: [Project]
    var emptyText: String = "No projects added"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if projects.isEmpty {
                Text(emptyText)
                    .scaledFont(size: 12, weight: .medium)
                    .foregroundStyle(Color.siriusMuted)
            } else {
                ForEach(projects) { project in
                    ProjectCard(project: project)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
