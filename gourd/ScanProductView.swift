//
//  ScanProductView.swift
//  gourd
//

import SwiftUI
import AVFoundation

// MARK: - Scanned Product Model

struct ScannedProduct {
    let barcode: String
    let name: String
    let brand: String?
    let imageURL: String?
    let quantity: String?
    let rawCategory: String?

    var displayCategory: String {
        rawCategory?
            .replacingOccurrences(of: "en:", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized ?? "Other"
    }
}

// MARK: - Open Food Facts Lookup

private func lookupBarcode(_ barcode: String) async throws -> ScannedProduct? {
    guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else {
        return nil
    }
    var request = URLRequest(url: url)
    request.setValue("GourdApp/1.0 (iOS; contact@gourd.app)", forHTTPHeaderField: "User-Agent")
    request.timeoutInterval = 15

    // Retry up to 3 times on transient network errors
    let retryableCodes: Set<Int> = [-1005, -1001, -1009, -1004]
    var lastError: Error = URLError(.unknown)
    for attempt in 1...3 {
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try parseOFFResponse(data: data, barcode: barcode)
        } catch let error as NSError where retryableCodes.contains(error.code) {
            lastError = error
            if attempt < 3 {
                try? await Task.sleep(nanoseconds: UInt64(attempt) * 500_000_000)
            }
        } catch {
            throw error  // non-retryable error — surface immediately
        }
    }
    throw lastError
}

private func parseOFFResponse(data: Data, barcode: String) throws -> ScannedProduct? {

    struct OFFResponse: Decodable {
        let status: Int
        let product: OFFProduct?
        struct OFFProduct: Decodable {
            let product_name: String?
            let brands: String?
            let image_front_url: String?
            let quantity: String?
            let categories_tags: [String]?
        }
    }

    let response = try JSONDecoder().decode(OFFResponse.self, from: data)
    guard response.status == 1,
          let p = response.product,
          let name = p.product_name, !name.isEmpty
    else { return nil }

    // Pick first English category tag
    let category = p.categories_tags?
        .first(where: { $0.hasPrefix("en:") })

    return ScannedProduct(
        barcode: barcode,
        name: name,
        brand: p.brands?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces),
        imageURL: p.image_front_url,
        quantity: p.quantity,
        rawCategory: category
    )
}

// MARK: - Scan State

private enum ScanState: Equatable {
    case requesting
    case scanning
    case loading
    case found(ScannedProduct)
    case notFound
    case denied

    static func == (lhs: ScanState, rhs: ScanState) -> Bool {
        switch (lhs, rhs) {
        case (.requesting, .requesting), (.scanning, .scanning),
             (.loading, .loading), (.notFound, .notFound), (.denied, .denied): return true
        case (.found(let a), .found(let b)): return a.barcode == b.barcode
        default: return false
        }
    }
}

// MARK: - ScanProductView

struct ScanProductView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PantryRepository.self) private var repo

    @State private var state: ScanState = .requesting
    @State private var isPaused         = false
    @State private var torchOn          = false
    @State private var addedSuccess     = false
    @State private var isSaving         = false
    @State private var saveError: String?
    @State private var expirationDate   = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var showManualAdd    = false

    var body: some View {
        ZStack {
            // Camera layer
            if state != .denied && state != .requesting {
                BarcodeScannerView(
                    onDetected: handleBarcode,
                    isPaused: $isPaused,
                    torchOn: $torchOn
                )
                .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            // Scanning overlay
            if state == .scanning || state == .loading {
                scanOverlay
            }

            // State-driven content
            VStack {
                topBar
                Spacer()
                bottomContent
            }
        }
        .task { await checkPermission() }
        .animation(.easeInOut(duration: 0.3), value: state)
        .alert("Couldn't Add Item", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
        .sheet(isPresented: $showManualAdd) {
            ManualAddItemView()
                .environment(repo)
        }
    }

    // MARK: - Permission Check

    private func checkPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            state = .scanning
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            state = granted ? .scanning : .denied
        default:
            state = .denied
        }
    }

    // MARK: - Barcode Handler

    private func handleBarcode(_ barcode: String) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        state = .loading

        Task {
            do {
                if let product = try await lookupBarcode(barcode) {
                    state = .found(product)
                } else {
                    state = .notFound
                }
            } catch {
                state = .notFound
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.black.opacity(0.4)))
            }
            Spacer()
            if state == .scanning || state == .loading {
                Button(action: { torchOn.toggle() }) {
                    Image(systemName: torchOn ? "bolt.fill" : "bolt.slash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(torchOn ? Color.yellow : .white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.black.opacity(0.4)))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    // MARK: - Scanning Overlay

    private var scanOverlay: some View {
        VStack(spacing: 20) {
            Spacer()

            Text(state == .loading ? "Looking up product..." : "Point camera at barcode")
                .font(.ftBody(14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.black.opacity(0.5)))

            ZStack {
                // Dim surround
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: 260, height: 160)
                                    .blendMode(.destinationOut)
                            )
                    )

                // Corner brackets
                ScannerFrame()
                    .stroke(
                        state == .loading ? Color.ftOlive : Color.white,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 260, height: 160)
                    .animation(.easeInOut(duration: 0.3), value: state)

                // Scan line when loading
                if state == .loading {
                    Rectangle()
                        .fill(Color.ftOlive.opacity(0.7))
                        .frame(width: 240, height: 2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)

            Spacer()
            Spacer()
        }
        .ignoresSafeArea()
    }

    // MARK: - Bottom Content

    @ViewBuilder
    private var bottomContent: some View {
        switch state {
        case .requesting:
            EmptyView()

        case .scanning:
            EmptyView()

        case .loading:
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
                .padding(.bottom, 120)

        case .found(let product):
            productCard(product)
                .transition(.move(edge: .bottom).combined(with: .opacity))

        case .notFound:
            notFoundCard
                .transition(.move(edge: .bottom).combined(with: .opacity))

        case .denied:
            deniedCard
        }
    }

    // MARK: - Product Card

    private func productCard(_ product: ScannedProduct) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.ftSoftClay)
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 16)

            HStack(spacing: 14) {
                // Product image
                ProductImage(
                    urlString: product.imageURL ?? "",
                    fallbackIcon: "barcode.viewfinder",
                    fallbackBg: Color.ftSoftClay.opacity(0.3),
                    cornerRadius: 10
                )
                .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.ftBody(16, weight: .bold))
                        .foregroundStyle(Color.ftDeepForest)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let brand = product.brand {
                        Text(brand)
                            .font(.ftBody(13))
                            .foregroundStyle(Color.ftDeepForest50)
                    }

                    HStack(spacing: 8) {
                        if let qty = product.quantity {
                            Label(qty, systemImage: "scalemass")
                                .font(.ftBody(12))
                                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
                        }
                        Text(product.displayCategory)
                            .font(.ftBody(11, weight: .semibold))
                            .foregroundStyle(Color.ftOlive)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.ftOlive.opacity(0.1)))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)

            // Expiration date picker
            HStack {
                Label("Expires", systemImage: "calendar")
                    .font(.ftBody(14, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.7))
                Spacer()
                DatePicker("", selection: $expirationDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Color.ftDeepForest)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    guard !isSaving else { return }
                    isSaving = true
                    Task {
                        do {
                            let insert = try await repo.makeInsert(
                                name: product.name,
                                brand: product.brand,
                                barcode: product.barcode,
                                imageUrl: product.imageURL,
                                category: ItemCategory(fromOFFTag: product.rawCategory),
                                storageLocation: .fridge,
                                addedVia: .barcode,
                                quantity: 1.0,
                                unit: "item",
                                expiryDate: expirationDate
                            )
                            try await repo.addItem(insert)
                            let impact = UINotificationFeedbackGenerator()
                            impact.notificationOccurred(.success)
                            withAnimation { addedSuccess = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                        } catch {
                            isSaving = false
                            print("❌ addItem error:", error)
                            saveError = error.localizedDescription
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        if isSaving && !addedSuccess {
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Image(systemName: addedSuccess ? "checkmark" : "plus")
                                .font(.system(size: 14, weight: .bold))
                        }
                        Text(addedSuccess ? "Added to Pantry!" : "Add to Pantry")
                            .font(.ftBody(15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(addedSuccess ? Color.ftOlive : Color.ftDeepForest)
                    )
                }
                .disabled(addedSuccess || isSaving)

                Button(action: scanAgain) {
                    Text("Scan Again")
                        .font(.ftBody(15, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.ftSoftClay, lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.ftWarmBeige)
        )
    }

    // MARK: - Not Found Card

    private var notFoundCard: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.ftSoftClay)
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            Image(systemName: "questionmark.circle")
                .font(.system(size: 36))
                .foregroundStyle(Color.ftDeepForest.opacity(0.25))

            VStack(spacing: 4) {
                Text("Product not found")
                    .font(.ftBody(16, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text("This barcode isn't in our database yet.")
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
            }

            VStack(spacing: 10) {
                Button(action: { showManualAdd = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14, weight: .bold))
                        Text("Add Manually")
                            .font(.ftBody(15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.ftDeepForest))
                }

                Button(action: scanAgain) {
                    Text("Try Again")
                        .font(.ftBody(15, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.ftSoftClay, lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.ftWarmBeige))
    }

    // MARK: - Denied Card

    private var deniedCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "camera.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.4))
            Text("Camera Access Required")
                .font(.ftBody(18, weight: .bold))
                .foregroundStyle(.white)
            Text("Go to Settings → Gourd → Camera and enable access to use the barcode scanner.")
                .font(.ftBody(14))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .font(.ftBody(15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.ftOlive))
            }
            Spacer()
        }
    }

    // MARK: - Helpers

    private func scanAgain() {
        addedSuccess = false
        isSaving = false
        saveError = nil
        expirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        isPaused = false
        state = .scanning
    }
}

// MARK: - Scanner Frame Shape

private struct ScannerFrame: Shape {
    private let cornerLength: CGFloat = 28
    private let radius: CGFloat       = 6

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let (l, r, t, b) = (rect.minX, rect.maxX, rect.minY, rect.maxY)
        let cl = cornerLength

        // Top-left
        p.move(to: CGPoint(x: l, y: t + cl))
        p.addLine(to: CGPoint(x: l, y: t + radius))
        p.addQuadCurve(to: CGPoint(x: l + radius, y: t), control: CGPoint(x: l, y: t))
        p.addLine(to: CGPoint(x: l + cl, y: t))

        // Top-right
        p.move(to: CGPoint(x: r - cl, y: t))
        p.addLine(to: CGPoint(x: r - radius, y: t))
        p.addQuadCurve(to: CGPoint(x: r, y: t + radius), control: CGPoint(x: r, y: t))
        p.addLine(to: CGPoint(x: r, y: t + cl))

        // Bottom-right
        p.move(to: CGPoint(x: r, y: b - cl))
        p.addLine(to: CGPoint(x: r, y: b - radius))
        p.addQuadCurve(to: CGPoint(x: r - radius, y: b), control: CGPoint(x: r, y: b))
        p.addLine(to: CGPoint(x: r - cl, y: b))

        // Bottom-left
        p.move(to: CGPoint(x: l + cl, y: b))
        p.addLine(to: CGPoint(x: l + radius, y: b))
        p.addQuadCurve(to: CGPoint(x: l, y: b - radius), control: CGPoint(x: l, y: b))
        p.addLine(to: CGPoint(x: l, y: b - cl))

        return p
    }
}

// MARK: - Manual Add Item View

struct ManualAddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PantryRepository.self) private var repo

    @State private var name            = ""
    @State private var brand           = ""
    @State private var unit            = "item"
    @State private var quantity        = 1.0
    @State private var category        = ItemCategory.other
    @State private var storageLocation = StorageLocation.fridge
    @State private var expirationDate  = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var addedSuccess    = false
    @State private var isSaving        = false

    @FocusState private var focusedField: ManualField?
    private enum ManualField { case name, brand, unit }

    private var canAdd: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    formField(label: "Item Name", required: true) {

                        TextField("", text: $name, prompt: Text("e.g. Almond Milk").foregroundStyle(Color.ftPlaceholder))
                            .font(.ftBody(15))
                            .foregroundStyle(Color.ftDeepForest)
                            .autocorrectionDisabled()
                            .submitLabel(.next)
                            .focused($focusedField, equals: .name)
                    }

                    formField(label: "Brand", required: false) {
                        TextField("", text: $brand, prompt: Text("e.g. Silk").foregroundStyle(Color.ftPlaceholder))
                            .font(.ftBody(15))
                            .foregroundStyle(Color.ftDeepForest)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .focused($focusedField, equals: .brand)
                    }

                    // Quantity + unit on one row
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quantity")
                            .font(.ftBody(13, weight: .semibold))
                            .foregroundStyle(Color.ftDeepForest.opacity(0.6))
                        HStack(spacing: 12) {
                            // Stepper
                            HStack(spacing: 16) {
                                Button(action: { if quantity > 0.5 { quantity -= 0.5 } }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.ftOlive)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().strokeBorder(Color.ftOlive, lineWidth: 1.5))
                                }
                                Text(quantity == floor(quantity)
                                     ? String(Int(quantity))
                                     : String(format: "%.1f", quantity))
                                    .font(.ftBody(16, weight: .semibold))
                                    .foregroundStyle(Color.ftDeepForest)
                                    .frame(minWidth: 24)
                                Button(action: { quantity += 0.5 }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Color.ftOlive))
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.ftSoftClay.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            // Unit field
                            TextField("", text: $unit, prompt: Text("unit").foregroundStyle(Color.ftPlaceholder))
                                .font(.ftBody(15))
                                .foregroundStyle(Color.ftDeepForest)
                                .autocorrectionDisabled()
                                .frame(maxWidth: .infinity)
                                .focused($focusedField, equals: .unit)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(Color.ftSoftClay.opacity(0.5), lineWidth: 1)
                                        )
                                )
                        }
                    }

                    formField(label: "Category", required: false) {
                        Picker("Category", selection: $category) {
                            ForEach(ItemCategory.allCases, id: \.self) { cat in
                                Text(cat.displayName).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.ftDeepForest)
                        .font(.ftBody(15))
                    }

                    formField(label: "Storage Location", required: false) {
                        Picker("Storage", selection: $storageLocation) {
                            ForEach(StorageLocation.allCases, id: \.self) { loc in
                                Label(loc.displayName, systemImage: loc.systemImage).tag(loc)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.ftDeepForest)
                        .font(.ftBody(15))
                    }

                    formField(label: "Expiration Date", required: false) {
                        DatePicker("", selection: $expirationDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(Color.ftDeepForest)
                    }

                    Button(action: saveItem) {
                        HStack(spacing: 8) {
                            if isSaving && !addedSuccess {
                                ProgressView().tint(.white).scaleEffect(0.8)
                            } else {
                                Image(systemName: addedSuccess ? "checkmark" : "plus")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            Text(addedSuccess ? "Added to Pantry!" : "Add to Pantry")
                                .font(.ftBody(16, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    addedSuccess  ? Color.ftOlive :
                                    canAdd        ? Color.ftDeepForest :
                                                    Color.ftDeepForest.opacity(0.3)
                                )
                        )
                    }
                    .disabled(!canAdd || addedSuccess || isSaving)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.ftWarmBeige.ignoresSafeArea())
            .navigationTitle("Add Item Manually")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.ftBody(15))
                        .foregroundStyle(Color.ftDeepForest)
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
                    .font(.ftBody(15, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                }
            }
        }
    }

    private func formField<Content: View>(label: String, required: Bool, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 3) {
                Text(label)
                    .font(.ftBody(13, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.6))
                if required {
                    Text("*").font(.ftBody(13, weight: .bold)).foregroundStyle(Color.ftCrimson)
                }
            }
            HStack {
                content()
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.ftSoftClay.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }

    private func saveItem() {
        guard canAdd, !isSaving else { return }
        isSaving = true
        Task {
            do {
                let trimmedName  = name.trimmingCharacters(in: .whitespaces)
                let trimmedBrand = brand.trimmingCharacters(in: .whitespaces)
                let insert = try await repo.makeInsert(
                    name: trimmedName,
                    brand: trimmedBrand.isEmpty ? nil : trimmedBrand,
                    category: category,
                    storageLocation: storageLocation,
                    addedVia: .manual,
                    quantity: quantity,
                    unit: unit,
                    expiryDate: expirationDate
                )
                try await repo.addItem(insert)
                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.success)
                withAnimation { addedSuccess = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
            } catch {
                isSaving = false
            }
        }
    }
}

#Preview {
    ScanProductView()
}

#Preview("Manual Add") {
    ManualAddItemView()
}
