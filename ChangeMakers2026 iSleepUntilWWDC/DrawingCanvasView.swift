//
//  DrawingCanvasView.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Samuel Aarón Flores Montemayor on 10/04/26.
//

import SwiftUI
import UIKit

final class InsecureSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

struct DrawingCanvasView: View {
    struct PredictionResponse: Decodable {
        let character: String
        let confidence: Double
        let classIndex: Int

        enum CodingKeys: String, CodingKey {
            case character
            case confidence
            case classIndex = "class_index"
        }
    }

    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var exportedImage: UIImage?
    @State private var predictionResult: String = ""
    @State private var predictionResponse: PredictionResponse?
    @State private var isUploading = false
    @State private var errorMessage: String?

    private let endpoint = "http://31.220.50.65:9900/predict"
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(
            configuration: configuration,
            delegate: InsecureSessionDelegate(),
            delegateQueue: nil
        )
    }()

    var body: some View {
        VStack(spacing: 16) {
            Text("Draw here")
                .font(.title2)
                .bold()

            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .overlay(
                        Rectangle()
                            .stroke(Color.black.opacity(0.3), lineWidth: 2)
                    )

                Canvas { context, size in
                    for stroke in strokes {
                        drawStroke(stroke, in: &context)
                    }
                    drawStroke(currentStroke, in: &context)
                }
            }
            .frame(width: 300, height: 300)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentStroke.append(value.location)
                    }
                    .onEnded { _ in
                        if !currentStroke.isEmpty {
                            strokes.append(currentStroke)
                            currentStroke = []
                        }
                    }
            )

            HStack(spacing: 16) {
                Button("Clear") {
                    clearCanvas()
                }
                .buttonStyle(.bordered)

                Button(isUploading ? "Predicting..." : "Predict") {
                    Task {
                        await exportAndPredict()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isUploading || isCanvasEmpty)
            }

            if let exportedImage {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exported JPG preview")
                        .font(.headline)

                    Image(uiImage: exportedImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .border(Color.gray)
                }
            }

            if let predictionResponse {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prediction debug")
                        .font(.headline)

                    Text("Character: \(predictionResponse.character)")
                    Text(String(format: "Confidence: %.4f", predictionResponse.confidence))
                    Text("Class index: \(predictionResponse.classIndex)")

                    if !predictionResult.isEmpty {
                        Text("Raw response: \(predictionResult)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            } else if !predictionResult.isEmpty {
                Text("Raw response: \(predictionResult)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private var isCanvasEmpty: Bool {
        strokes.isEmpty && currentStroke.isEmpty
    }

    private func drawStroke(_ points: [CGPoint], in context: inout GraphicsContext) {
        guard !points.isEmpty else { return }

        var path = Path()
        path.move(to: points[0])

        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        context.stroke(
            path,
            with: .color(.black),
            style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)
        )
    }

    private func clearCanvas() {
        strokes = []
        currentStroke = []
        exportedImage = nil
        predictionResult = ""
        predictionResponse = nil
        errorMessage = nil
    }

    @MainActor
    private func exportAndPredict() async {
        errorMessage = nil
        predictionResult = ""
        predictionResponse = nil

        guard let image = renderCanvasImage(size: CGSize(width: 300, height: 300)) else {
            errorMessage = "Could not render image."
            return
        }

        exportedImage = image

        guard let jpgData = image.jpegData(compressionQuality: 0.9) else {
            errorMessage = "Could not convert image to JPG."
            return
        }

        isUploading = true
        defer { isUploading = false }

        do {
            let responseText = try await uploadImage(jpgData: jpgData, filename: "drawing.jpg")
            predictionResult = responseText

            if let jsonData = responseText.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(PredictionResponse.self, from: jsonData) {
                predictionResponse = decoded
            }
        } catch {
            errorMessage = "Upload failed: \(error.localizedDescription)"
        }
    }

    private func renderCanvasImage(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let cgContext = context.cgContext
            cgContext.setStrokeColor(UIColor.black.cgColor)
            cgContext.setLineWidth(16)
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)

            for stroke in strokes {
                guard let first = stroke.first else { continue }
                cgContext.beginPath()
                cgContext.move(to: first)
                for point in stroke.dropFirst() {
                    cgContext.addLine(to: point)
                }
                cgContext.strokePath()
            }
        }

        return image
    }

    private func uploadImage(jpgData: Data, filename: String) async throws -> String {
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(jpgData)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")

        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverText = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NSError(
                domain: "UploadError",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: serverText]
            )
        }

        return String(data: data, encoding: .utf8) ?? "Success, but response was not text."
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

#Preview {
    DrawingCanvasView()
}
