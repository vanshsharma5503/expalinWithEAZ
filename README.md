# Explain with EAZ

**Explain with EAZ** is an iOS app built using **SwiftUI** and **Google's Gemini AI** that simplifies complex topics using kid-friendly analogies — just like you're five years old.

## 📱 Features

* ✏️ Enter a **custom prompt** or
* 📷 **Pick/capture an image**, and the app uses **Vision OCR** to extract text
* 🌐 Get **AI-generated explanations** in **English** or **Hindi** using Gemini 2.5 Flash
* 💾 **Save** the generated response locally as a text file
* 🎨 Clean and responsive UI built using SwiftUI

## 🛠️ Tech Stack

* `SwiftUI` – Modern UI framework for iOS
* `GoogleGenerativeAI` – To generate AI responses
* `VisionKit` – For text recognition from images
* `PhotosPicker` – To select or capture images
* `FileManager` – To save explanations locally

## 🚀 Getting Started

1. **Clone the repo**

   ```bash
   git clone https://github.com/yourusername/explain-with-eaz.git
   ```

2. **Open in Xcode**

   Open `ExplainWithEAZ.xcodeproj` in Xcode.

3. **Add Google Generative AI API Key**

   Replace the placeholder API key in:

   ```swift
   let model = GenerativeModel(name: "gemini-2.5-flash", apiKey: "YOUR_API_KEY_HERE")
   ```

4. **Run the app** on a simulator or device.

> Note: The app requires iOS 16+ due to SwiftUI and PhotosPicker support.

## 📸 Screenshots

*(Add your app screenshots here to showcase UI)*

## 🙋‍♂️ About Me

I’m a beginner iOS developer exploring AI integration in apps. This project was built to learn SwiftUI, APIs, and working with images in iOS.
Feel free to connect or share feedback!

## 📄 License

This project is licensed under the MIT License.

---

