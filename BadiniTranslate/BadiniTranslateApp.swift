import SwiftUI
import WebKit
import UIKit

// MARK: - WebView für iOS (WKWebView)
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // JavaScript, Kamera & Mikrofon erlauben
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor.systemBackground
        
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // nichts
    }
    
    // MARK: - Coordinator (Navigation + File Upload)
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var progressObserver: NSKeyValueObservation?
        
        // Datei-Upload Callback
        private var uploadCallback: ((URL?) -> Void)? = nil
        
        // MARK: WKNavigationDelegate
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            NetworkIndicator.shared.show()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            NetworkIndicator.shared.hide()
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            NetworkIndicator.shared.hide()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            NetworkIndicator.shared.hide()
        }
        
        // MARK: WKUIDelegate – File Upload Dialog
        func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters,
                     initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            
            // Als Upload-Callback speichern
            self.uploadCallback = { url in
                if let url = url {
                    completionHandler([url])
                } else {
                    completionHandler(nil)
                }
            }
            
            // Picker anzeigen
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(picker, animated: true)
            }
        }
    }
}

// MARK: - UIImagePickerController Delegate
extension WebView.Coordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let imageURL = info[.imageURL] as? URL {
                self.uploadCallback?(imageURL)
            } else if let image = info[.originalImage] as? UIImage {
                // Temporär speichern
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("upload_\(UUID().uuidString).jpg")
                if let data = image.jpegData(compressionQuality: 0.8) {
                    try? data.write(to: tempURL)
                    self.uploadCallback?(tempURL)
                } else {
                    self.uploadCallback?(nil)
                }
            } else {
                self.uploadCallback?(nil)
            }
            self.uploadCallback = nil
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.uploadCallback?(nil)
            self.uploadCallback = nil
        }
    }
}

// MARK: - Network Indicator (Loading)
class NetworkIndicator: ObservableObject {
    static let shared = NetworkIndicator()
    @Published var isLoading = false
    
    func show() {
        DispatchQueue.main.async { self.isLoading = true }
    }
    
    func hide() {
        DispatchQueue.main.async { self.isLoading = false }
    }
}

// MARK: - Haupt App
@main
struct BadiniTranslateApp: App {
    @StateObject private var networkIndicator = NetworkIndicator.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Hintergrundfarbe
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ✅ Rote Toolbar wie auf Android
                    HStack {
                        Text("Badini Translate")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        
                        // Kleine kurdische Flagge als Symbol
                        Text("🇰🇼")
                            .font(.title3)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(red: 237/255, green: 28/255, blue: 36/255))
                    
                    // WebView
                    WebView(url: URL(string: "https://translator-site-five.vercel.app")!)
                        .edgesIgnoringSafeArea(.bottom)
                        .overlay {
                            if networkIndicator.isLoading {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                            }
                        }
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
