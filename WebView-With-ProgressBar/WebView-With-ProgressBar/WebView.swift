//
//  WebView.swift
//  WebView-With-ProgressBar
//
//  Created by home on 2021/04/21.
//

import SwiftUI
import WebKit

// プログレスバー付きのWKWebView
struct WebView: UIViewRepresentable {
    var webView = WKWebView()
    var progressView = UIProgressView()
    
    let urlString: String
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // "target="_blank""が設定されたリンクも開けるようにする
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        // ページ読み始めで呼ばれる
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        }
        
        // ページ読み終わりで呼ばれる
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        }
        
        // URLごとに処理を制御する
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString {
                if (url.hasPrefix("https://apps.apple.com/")) {
                    guard let appStoreLink = URL(string: url) else {
                        return
                    }
                    UIApplication.shared.open(appStoreLink, options: [:], completionHandler: { (succes) in
                    })
                    decisionHandler(WKNavigationActionPolicy.cancel)
                } else if (url.hasPrefix("http")) {
                    decisionHandler(WKNavigationActionPolicy.allow)
                } else {
                    decisionHandler(WKNavigationActionPolicy.cancel)
                }
            }
        }
        
        // WebViewの読み込み状況を監視する
        func addProgressObserver() {
            parent.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            // progressViewのアニメーション処理
            if keyPath == "estimatedProgress" {
                parent.progressView.alpha = 1.0
                parent.progressView.setProgress(Float(parent.webView.estimatedProgress), animated: true)
                
                if parent.webView.estimatedProgress >= 1.0 {
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: { [weak self] in
                        self?.parent.progressView.alpha = 0.0
                    }, completion: { (finished: Bool) in
                        self.parent.progressView.setProgress(0.0, animated: false)
                    })
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.addSubview(progressView)
        
        // UIProgressViewのレイアウト設定
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.widthAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 1.0).isActive = true
        progressView.topAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor, constant: 0).isActive = true
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // makeCoordinatorで生成したCoordinatorクラスのインスタンスを指定
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        
        // スワイプで画面遷移できるようにする
        webView.allowsBackForwardNavigationGestures = true
        
        context.coordinator.addProgressObserver()
        
        guard let url = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // 前のページに戻る
    func goBack() {
        webView.goBack()
    }
    
    // 次のページに進む
    func goForward() {
        webView.goForward()
    }
    
    // ページをリロードする
    func reload() {
        webView.reload()
    }
}
