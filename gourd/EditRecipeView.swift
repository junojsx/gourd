//
//  EditRecipeView.swift
//  gourd
//

import SwiftUI
import PhotosUI

// MARK: - Recipe Hero Image

/// Handles empty URL, local file paths, and remote URLs with a placeholder fallback.
struct RecipeHeroImage: View {
    let urlString: String
    var height: CGFloat = 220

    var body: some View {
        Group {
            if urlString.isEmpty {
                placeholder
            } else if urlString.hasPrefix("/") {
                // Local file saved from photo picker
                if let uiImage = UIImage(contentsOfFile: urlString) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholder
                }
            } else {
                AsyncImage(url: URL(string: urlString)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        placeholder
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
    }

    private var placeholder: some View {
        ZStack {
            Color.ftSoftClay.opacity(0.25)
            Image("GourdLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 72)
                .opacity(0.3)
        }
    }
}

// MARK: - EditRecipeView

struct EditRecipeView: View {
    let recipe: GeneratedRecipe
    let onSave: (GeneratedRecipe) -> Void

    @State private var title: String
    @State private var prepTime: String
    @State private var difficulty: String
    @State private var ingredients: [String]
    @State private var steps: [String]
    @State private var imageSource: String
    @State private var selectedPhoto: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isPrepTimeFocused: Bool

    init(recipe: GeneratedRecipe, onSave: @escaping (GeneratedRecipe) -> Void) {
        self.recipe = recipe
        self.onSave = onSave
        _title       = State(initialValue: recipe.title)
        _prepTime    = State(initialValue: recipe.prepTime)
        _difficulty  = State(initialValue: recipe.difficulty)
        _ingredients = State(initialValue: recipe.ingredients)
        _steps       = State(initialValue: recipe.steps)
        _imageSource = State(initialValue: recipe.heroImageURL)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                imageSection
                infoSection
                listSection(title: "Ingredients", items: $ingredients,
                            placeholder: "e.g. 2 cups flour",
                            addLabel: "Add Ingredient")
                listSection(title: "Steps", items: $steps,
                            placeholder: "e.g. Preheat oven to 350°F",
                            addLabel: "Add Step")
                saveButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.ftWarmBeige.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Edit Recipe")
                    .font(.ftBody(17, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
            }
        }
        .toolbarBackground(Color.ftWarmBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let path = saveImageToDocuments(data) {
                    imageSource = path
                }
            }
        }
    }

    // MARK: - Image Section

    private var imageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            RecipeHeroImage(urlString: imageSource, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text(imageSource.isEmpty ? "Add Photo" : "Change Photo")
                        .font(.ftBody(13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.black.opacity(0.55)))
            }
            .padding(12)
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(spacing: 12) {
            fieldBlock(label: "TITLE") {
                TextField("", text: $title, prompt: Text("Recipe title").foregroundStyle(Color.ftPlaceholder))
                    .font(.ftBody(15))
                    .foregroundStyle(Color.ftDeepForest)
                    .focused($isTitleFocused)
            }

            HStack(spacing: 12) {
                fieldBlock(label: "PREP TIME") {
                    TextField("", text: $prepTime, prompt: Text("e.g. 20 mins").foregroundStyle(Color.ftPlaceholder))
                        .font(.ftBody(15))
                        .foregroundStyle(Color.ftDeepForest)
                        .focused($isPrepTimeFocused)
                }

                fieldBlock(label: "DIFFICULTY") {
                    Picker("", selection: $difficulty) {
                        Text("Easy").tag("Easy")
                        Text("Medium").tag("Medium")
                        Text("Hard").tag("Hard")
                    }
                    .pickerStyle(.menu)
                    .tint(Color.ftDeepForest)
                }
            }
        }
    }

    // MARK: - List Section

    private func listSection(title: String, items: Binding<[String]>,
                              placeholder: String, addLabel: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.ftBody(11, weight: .bold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.45))
                .kerning(0.8)

            VStack(spacing: 8) {
                ForEach(items.wrappedValue.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 8) {
                        // Step number or bullet
                        if title == "Steps" {
                            Text("\(i + 1)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Color.ftDeepForest.opacity(0.5)))
                                .padding(.top, 10)
                        } else {
                            Circle()
                                .fill(Color.ftDeepForest.opacity(0.3))
                                .frame(width: 6, height: 6)
                                .padding(.top, 14)
                        }

                        TextField("", text: items[i], prompt: Text(placeholder).foregroundStyle(Color.ftPlaceholder), axis: .vertical)
                            .font(.ftBody(14))
                            .foregroundStyle(Color.ftDeepForest)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.8))
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.ftSoftClay.opacity(0.5), lineWidth: 1))
                            )

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                var arr = items.wrappedValue
                                arr.remove(at: i)
                                items.wrappedValue = arr
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.ftCrimson.opacity(0.6))
                        }
                        .padding(.top, 8)
                    }
                }

                // Add row
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        var arr = items.wrappedValue
                        arr.append("")
                        items.wrappedValue = arr
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 17))
                        Text(addLabel)
                            .font(.ftBody(14, weight: .medium))
                    }
                    .foregroundStyle(Color.ftOlive)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.ftOlive.opacity(0.35), lineWidth: 1.5)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.ftOlive.opacity(0.05)))
                    )
                }
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: {
            let updated = GeneratedRecipe(
                id: recipe.id,
                title: title.trimmingCharacters(in: .whitespaces),
                prepTime: prepTime.trimmingCharacters(in: .whitespaces),
                difficulty: difficulty,
                heroImageURL: imageSource,
                ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
                steps: steps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            )
            onSave(updated)
            dismiss()
        }) {
            Text("Save Changes")
                .font(.ftBody(16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isValid ? Color.ftDeepForest : Color.ftDeepForest.opacity(0.3))
                )
        }
        .disabled(!isValid)
    }

    // MARK: - Helpers

    private func fieldBlock<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ftBody(11, weight: .bold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.45))
                .kerning(0.8)
            HStack {
                content()
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.ftSoftClay.opacity(0.5), lineWidth: 1))
            )
        }
    }

    private func saveImageToDocuments(_ data: Data) -> String? {
        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.8)
        else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        try? jpegData.write(to: url)
        return url.path
    }
}
