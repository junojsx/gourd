//
//  EditPantryItemView.swift
//  gourdo
//

import PhotosUI
import SwiftUI

struct EditPantryItemView: View {
    @Environment(PantryRepository.self) private var repo
    @Environment(\.dismiss) private var dismiss

    let item: PantryItem

    @State private var name: String
    @State private var brand: String
    @State private var category: ItemCategory
    @State private var storageLocation: StorageLocation
    @State private var quantity: Double
    @State private var unit: String
    @State private var hasExpiryDate: Bool
    @State private var expiryDate: Date
    @State private var notes: String

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    init(item: PantryItem) {
        self.item = item
        _name            = State(initialValue: item.name)
        _brand           = State(initialValue: item.brand ?? "")
        _category        = State(initialValue: item.category)
        _storageLocation = State(initialValue: item.storageLocation)
        _quantity        = State(initialValue: item.quantity)
        _unit            = State(initialValue: item.unit)
        _hasExpiryDate   = State(initialValue: item.expiryDate != nil)
        _expiryDate      = State(initialValue: item.expiryDate ?? Calendar.current.date(byAdding: .day, value: 7, to: .now)!)
        _notes           = State(initialValue: item.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    photoSection
                    formSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(Color.ftWarmBeige.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Item")
                        .font(.ftBody(17, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.ftBody(15))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.6))
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: save) {
                        if isSaving {
                            ProgressView().tint(Color.ftOlive)
                        } else {
                            Text("Save")
                                .font(.ftBody(15, weight: .semibold))
                                .foregroundStyle(Color.ftOlive)
                        }
                    }
                    .disabled(isSaving || name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .toolbarBackground(Color.ftWarmBeige, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                    } else {
                        ProductImage(
                            urlString: item.imageUrl ?? "",
                            fallbackIcon: category.systemImage,
                            fallbackBg: category.iconBgColor,
                            cornerRadius: 16
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )

                ZStack {
                    Circle()
                        .fill(Color.ftPrimaryBg)
                        .frame(width: 36, height: 36)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .offset(x: -12, y: -12)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                selectedImageData = try? await newItem?.loadTransferable(type: Data.self)
            }
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: 12) {
            // Name
            fieldCard {
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("ITEM NAME")
                    TextField("e.g. Whole Milk", text: $name)
                        .font(.ftBody(15))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }

            // Brand
            fieldCard {
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("BRAND (OPTIONAL)")
                    TextField("e.g. Organic Valley", text: $brand)
                        .font(.ftBody(15))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }

            // Category & Storage side by side
            HStack(spacing: 10) {
                fieldCard {
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("CATEGORY")
                        Picker("", selection: $category) {
                            ForEach(ItemCategory.allCases, id: \.self) {
                                Text($0.displayName).tag($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.ftDeepForest)
                        .font(.ftBody(14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                fieldCard {
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("STORAGE")
                        Picker("", selection: $storageLocation) {
                            ForEach(StorageLocation.allCases, id: \.self) {
                                Text($0.displayName).tag($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.ftDeepForest)
                        .font(.ftBody(14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            // Quantity & Unit
            fieldCard {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("QUANTITY")
                        HStack(spacing: 14) {
                            Button {
                                if quantity > 0.5 { quantity = max(0.5, quantity - 0.5) }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.ftOlive)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().strokeBorder(Color.ftOlive, lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)

                            Text(quantity == floor(quantity) ? "\(Int(quantity))" : String(format: "%.1f", quantity))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.ftDeepForest)
                                .frame(minWidth: 32, alignment: .center)

                            Button {
                                quantity += 0.5
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color.ftOlive))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        fieldLabel("UNIT")
                        TextField("item", text: $unit)
                            .font(.ftBody(15))
                            .foregroundStyle(Color.ftDeepForest)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
            }

            // Expiry Date
            fieldCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        fieldLabel("EXPIRY DATE")
                        Spacer()
                        Toggle("", isOn: $hasExpiryDate)
                            .labelsHidden()
                            .tint(Color.ftOlive)
                            .scaleEffect(0.85)
                    }
                    if hasExpiryDate {
                        DatePicker(
                            "",
                            selection: $expiryDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(Color.ftOlive)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: hasExpiryDate)
            }

            // Notes
            fieldCard {
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("NOTES (OPTIONAL)")
                    TextField("Add any notes...", text: $notes, axis: .vertical)
                        .font(.ftBody(15))
                        .foregroundStyle(Color.ftDeepForest)
                        .lineLimit(3, reservesSpace: false)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftCrimson)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Save

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        errorMessage = nil

        Task {
            do {
                var updated = item
                updated.name            = name.trimmingCharacters(in: .whitespaces)
                updated.brand           = brand.trimmingCharacters(in: .whitespaces).isEmpty ? nil : brand.trimmingCharacters(in: .whitespaces)
                updated.category        = category
                updated.storageLocation = storageLocation
                updated.quantity        = quantity
                updated.unit            = unit.trimmingCharacters(in: .whitespaces).isEmpty ? "item" : unit.trimmingCharacters(in: .whitespaces)
                updated.expiryDate      = hasExpiryDate ? expiryDate : nil
                updated.notes           = notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces)

                if let data = selectedImageData {
                    updated.imageUrl = try await repo.uploadItemImage(data, itemId: item.id)
                }

                try await repo.updateItem(updated)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }

    // MARK: - Helpers

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.ftBody(10, weight: .semibold))
            .foregroundStyle(Color.ftDeepForest.opacity(0.4))
            .kerning(0.8)
    }

    @ViewBuilder
    private func fieldCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ftCardBg.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                    )
            )
    }
}
