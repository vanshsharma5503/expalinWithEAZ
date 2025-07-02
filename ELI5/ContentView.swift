//
//  ContentView.swift
//  ELI5
//
//  Created by Vansh Sharma on 30/06/25.
//

import SwiftUI
import GoogleGenerativeAI
import PhotosUI
import Vision

struct ContentView: View {
    @State private var selectedLanguage = 0
    @State var userPrompt = ""
    @State var isLoading = false
    @State var response = ""
    @State private var originalResponse = ""
    @State private var lastLanguage = 0
    @State private var ImagePicker = false
    @State private var pickedImage: UIImage? = nil
    @State private var showPhotoPicker = false
    @State private var photoPickerItem: PhotosPickerItem? = nil
    let model = GenerativeModel(name: "gemini-2.5-flash", apiKey: "")
    var body: some View {
        VStack {
            ZStack{
                RoundedRectangle(cornerRadius: 25)
                    .fill(.teal)
                    .offset(y:-80)
                Image("1")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                    .frame(height: 300)
                    .offset(y:50)
                    .padding()
                Text("Explain with EAZ")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .padding()
                    .offset(y:-250)
            }
            
            
            TextField("Type your topic....", text:$userPrompt, onCommit: {
                if !userPrompt.trimmingCharacters(in: .whitespaces).isEmpty {
                    generateResponse()
                }
            })
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .border(.black)
            .offset(y:-20)
            .padding(.horizontal)
            
            Button(action: {
                if !userPrompt.trimmingCharacters(in: .whitespaces).isEmpty {
                    generateResponse()
                }
            }) {
                Text("Make it EAZ")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Picker("Type of language", selection: $selectedLanguage) {
                Text("English").tag(0)
                Text("हिंदी").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 260)
            .padding(.top, 4)
            .onChange(of: selectedLanguage) { newValue in
                if !originalResponse.isEmpty && lastLanguage != newValue {
                    translateResponse(to: newValue)
                }
                lastLanguage = newValue
            }
            
            // Reserve space for response/loading
            ZStack {
                if isLoading {
                    ProgressView("Thinking...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .teal))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !response.isEmpty {
                    ScrollView {
                        Text(response)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .frame(height: 120)
            .padding(.horizontal)
            .padding(.top,10)
            
            Spacer()
            
            HStack {
                Button(action: {
                    showPhotoPicker = true
                }) {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .padding(.leading)
                Spacer()
            }
            
            Button(action: {
                saveResponseToFile()
            }) {
                Text("Save")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoPickerItem, matching: .images)
        .onChange(of: photoPickerItem) { newItem in
            if let item = newItem {
                item.loadTransferable(type: Data.self) { result in
                    switch result {
                    case .success(let data):
                        if let data, let image = UIImage(data: data) {
                            pickedImage = image
                            recognizeTextFromImage(image)
                        }
                    case .failure(let error):
                        print("Failed to load image: \(error)")
                    }
                }
            }
        }
    }

    func generateResponse(){
        isLoading = true
        response = ""
        let language = selectedLanguage == 0 ? "in simple English" : "in simple Hindi"
        let prompt = "Explain \(userPrompt) to me like I'm 5 years old, using a simple analogy. Keep it very short (2-3 sentences), easy to understand, and do not use complex words. Answer \(language)."
        Task{
            do{
                let result = try await model.generateContent(prompt)
                isLoading = false
                response = (result.text ?? "No response found")
                originalResponse = (response)
                lastLanguage = selectedLanguage
                userPrompt = ""
            }catch{
                response = "Something went wrong! \n\(error.localizedDescription)"
            }
        }
        
    }
    
    func translateResponse(to languageIndex: Int) {
        isLoading = true
        let targetLanguage = languageIndex == 0 ? "English" : "Hindi"
        let prompt = "Translate the following text to \(targetLanguage), keeping it very simple and short as if explaining to a 5-year-old:\n\n\(originalResponse)"
        Task {
            do {
                let result = try await model.generateContent(prompt)
                isLoading = false
                response = result.text ?? "No response found"
            } catch {
                response = "Something went wrong! \n\(error.localizedDescription)"
            }
        }
    }
    
    func saveResponseToFile() {
        guard !response.isEmpty else { return }
        let fileName = "ELI5_Explanation.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            do {
                try response.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to save file: \(error)")
            }
        }
    }
    
    func recognizeTextFromImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let results = request.results as? [VNRecognizedTextObservation] {
                let recognizedStrings = results.compactMap { $0.topCandidates(1).first?.string }
                let fullText = recognizedStrings.joined(separator: " ")
                DispatchQueue.main.async {
                    userPrompt = fullText
                    generateResponse()
                }
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}
