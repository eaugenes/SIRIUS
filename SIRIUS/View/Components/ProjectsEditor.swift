//
//  ProjectsEditor.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI
import UIKit
import PhotosUI

struct ProjectsEditor: View {
    
    @Binding var projects: [Project]
    
    private enum Field: Hashable {
        case title(UUID)
        case details(UUID)
        
        var projectID: UUID {
            switch self {
            case .title(let id), .details(let id): return id
            }
        }
    }
    
    @FocusState private var focus: Field?
    @State private var showPicker = false
    @State private var pickerProjectID: UUID?
    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var isLoadingPictures = false
    
    private let fieldWidth: CGFloat = 300
    
    // How many more pictures the project that opened the picker can take
    private var remainingPictures: Int {
        guard let id = pickerProjectID, let project = projects.first(where: { $0.id == id }) else { return 1 }
        return max(1, Project.maxPictures - project.pictureCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            
            ForEach($projects) { $project in
                card(for: $project)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: fieldWidth)
        .animation(.easeInOut(duration: 0.2), value: projects.count)
        .onChange(of: focus) { _, newFocus in
            removeEmptyProjects(keeping: newFocus?.projectID)
        }
        .photosPicker(
            isPresented: $showPicker,
            selection: $pickedItems,
            maxSelectionCount: remainingPictures,
            matching: .images
        )
        .onChange(of: pickedItems) { _, items in
            guard !items.isEmpty, let id = pickerProjectID else { return }
            isLoadingPictures = true
            Task { await addPictures(items, to: id) }
        }
    }
    
    // MARK: - Header with the + button
    
    private var header: some View {
        HStack(spacing: 8) {
            Text("Projects")
                .scaledFont(size: 13, weight: .medium)
                .foregroundStyle(Color.siriusInk)
            Text("(optional)")
                .scaledFont(size: 11, weight: .light)
                .foregroundStyle(Color.siriusTextSecondary)
            
            Spacer()
            
            Button {
                addProject()
            } label: {
                Image(systemName: "plus")
                    .scaledFont(size: 14, weight: .bold)
                    .foregroundStyle(Color.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(projects.count >= Project.maxProjects ? Color.siriusBorder : Color.siriusNavy))
            }
            .disabled(projects.count >= Project.maxProjects)
            .accessibilityLabel("Add a project")
        }
        .padding(.leading, 11)
    }
    
    // MARK: - One project
    
    @ViewBuilder
    private func card(for project: Binding<Project>) -> some View {
        let id = project.wrappedValue.id
        let number = (projects.firstIndex(where: { $0.id == id }) ?? 0) + 1
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Project \(number)")
                    .scaledFont(size: 12, weight: .semibold)
                    .foregroundStyle(Color.siriusInk)
                Spacer()
                Button {
                    remove(id)
                } label: {
                    Image(systemName: "trash")
                        .scaledFont(size: 13)
                        .foregroundStyle(Color.siriusDanger)
                        .frame(width: 30, height: 30)
                }
                .accessibilityLabel("Remove project \(number)")
            }
            
            // Title (required, 30 characters)
            fieldLabel("Title", isRequired: true, count: project.wrappedValue.title.count, limit: Project.titleLimit)
            TextField("", text: limited(project.title, Project.titleLimit, singleLine: true), prompt: prompt("Project title"))
                .focused($focus, equals: .title(id))
                .scaledFont(size: 14, weight: .regular)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 10)
                .frame(minHeight: 35)
                .background(Color.siriusFieldFill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
                .accessibilityLabel("Project \(number) title")
            
            // Description (required, 100 characters, smaller text than the title)
            fieldLabel("Description", isRequired: true, count: project.wrappedValue.details.count, limit: Project.descriptionLimit)
            TextField("", text: limited(project.details, Project.descriptionLimit, singleLine: true), prompt: prompt("What did you build or do?", size: 12), axis: .vertical)
                .focused($focus, equals: .details(id))
                .scaledFont(size: 12, weight: .light)
                .lineLimit(2...4)
                .padding(10)
                .frame(minHeight: 52, alignment: .topLeading)
                .background(Color.siriusFieldFill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
                .accessibilityLabel("Project \(number) description")
            
            // Pictures (optional)
            HStack(spacing: 4) {
                Text("Pictures")
                    .scaledFont(size: 12, weight: .medium)
                    .foregroundStyle(Color.siriusInk)
                Text("(optional, up to \(Project.maxPictures))")
                    .scaledFont(size: 10, weight: .light)
                    .foregroundStyle(Color.siriusTextSecondary)
            }
            .padding(.leading, 2)
            
            pictureRow(for: project)
        }
        .padding(10)
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
    }
    
    private func fieldLabel(_ title: String, isRequired: Bool, count: Int, limit: Int) -> some View {
        HStack(spacing: 2) {
            Text(title)
                .scaledFont(size: 12, weight: .medium)
                .foregroundStyle(Color.siriusInk)
            if isRequired {
                Text("*")
                    .scaledFont(size: 12, weight: .bold)
                    .foregroundStyle(Color.siriusDanger)
            }
            Spacer()
            Text("\(count)/\(limit)")
                .scaledFont(size: 10)
                .foregroundStyle(count >= limit ? Color.siriusDanger : Color.siriusTextSecondary)
        }
        .padding(.leading, 2)
    }
    
    private func prompt(_ text: String, size: CGFloat = 14) -> Text {
        Text(text)
            .font(.scaled(size, .light))
            .foregroundColor(Color.siriusTextSecondary)
    }
    
    // Stops typing at the limit (and keeps the text on one logical line)
    private func limited(_ text: Binding<String>, _ limit: Int, singleLine: Bool) -> Binding<String> {
        Binding(
            get: { text.wrappedValue },
            set: { newValue in
                let cleaned = singleLine ? newValue.replacingOccurrences(of: "\n", with: " ") : newValue
                text.wrappedValue = String(cleaned.prefix(limit))
            }
        )
    }
    
    // MARK: - Pictures
    
    private func pictureRow(for project: Binding<Project>) -> some View {
        let id = project.wrappedValue.id
        let size: CGFloat = 56
        
        return HStack(spacing: 8) {
            ForEach(Array(project.wrappedValue.imagePaths.enumerated()), id: \.offset) { index, path in
                ProjectThumb(path: path, size: size)
                    .overlay(alignment: .topTrailing) {
                        removeBadge { project.wrappedValue.imagePaths.remove(at: index) }
                    }
            }
            ForEach(Array(project.wrappedValue.newImages.enumerated()), id: \.offset) { index, image in
                ProjectThumb(local: image, size: size)
                    .overlay(alignment: .topTrailing) {
                        removeBadge { project.wrappedValue.newImages.remove(at: index) }
                    }
            }
            
            if project.wrappedValue.pictureCount < Project.maxPictures {
                Button {
                    pickerProjectID = id
                    pickedItems = []
                    showPicker = true
                    focus = nil
                } label: {
                    Image(systemName: "photo.badge.plus")
                        .scaledFont(size: 18)
                        .foregroundStyle(Color.siriusAction)
                        .frame(width: size, height: size)
                        .background(Color.siriusFieldFill)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.siriusFieldBorder, style: StrokeStyle(lineWidth: 1, dash: [4]))
                        )
                }
                .accessibilityLabel("Add pictures")
            }
            Spacer(minLength: 0)
        }
    }
    
    private func removeBadge(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .scaledFont(size: 16)
                .foregroundStyle(Color.white, Color.black.opacity(0.65))
        }
        .offset(x: 5, y: -5)
        .accessibilityLabel("Remove picture")
    }
    
    // MARK: - Actions
    
    // Adds an empty project (with its text fields) and puts the cursor in its title
    private func addProject() {
        guard projects.count < Project.maxProjects else { return }
        let project = Project()
        withAnimation(.easeInOut(duration: 0.2)) {
            projects.append(project)
        }
        focus = .title(project.id)
    }
    
    private func remove(_ id: UUID) {
        focus = nil
        withAnimation(.easeInOut(duration: 0.2)) {
            projects.removeAll { $0.id == id }
        }
    }
    
    // Projects with nothing typed and no picture are removed once the user moves away from them.
    // The project that is busy picking photos is kept (the photo picker takes the keyboard focus away).
    private func removeEmptyProjects(keeping activeID: UUID?) {
        let busyID = (showPicker || isLoadingPictures) ? pickerProjectID : nil
        guard projects.contains(where: { $0.isBlank && $0.id != activeID && $0.id != busyID }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            projects.removeAll { $0.isBlank && $0.id != activeID && $0.id != busyID }
        }
    }
    
    private func addPictures(_ items: [PhotosPickerItem], to id: UUID) async {
        var images: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                images.append(image)
            }
        }
        await MainActor.run {
            if let index = projects.firstIndex(where: { $0.id == id }) {
                let room = max(0, Project.maxPictures - projects[index].pictureCount)
                projects[index].newImages.append(contentsOf: images.prefix(room))
            }
            pickedItems = []
            pickerProjectID = nil
            isLoadingPictures = false
        }
    }
}

#Preview {
    struct Demo: View {
        @State var projects: [Project] = [Project(title: "Mosqontrol", details: "Dengue risk monitoring app for barangays.")]
        var body: some View {
            ScrollView {
                ProjectsEditor(projects: $projects).padding(.vertical, 40)
            }
            .appBg()
        }
    }
    return Demo()
}
