import Foundation

extension URLSession {
    public func synchronousDataTask(urlRequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlRequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
    
    public func synchronousDownloadTask(urlRequest: URLRequest) -> (url: URL?, response: URLResponse?, error: Error?) {
        var url: URL?
        var response: URLResponse?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let task = self.downloadTask(with: urlRequest) {
            url = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return (url, response, error)
    }
    
    public func curlString(for request: URLRequest, multiline: Bool = false) -> String {
        var ret: [String] = []
        
        switch request.httpMethod {
            case "HEAD": ret.append("--head")
            case .some(let method) where method != "GET": ret.append("-X \(method)")
            default: break
        }
        
        configuration.httpAdditionalHeaders?.forEach { ret.append("-H \"\($0.key): \($0.value)\"") }
        request.allHTTPHeaderFields?.forEach { ret.append("-H \"\($0.key): \($0.value)\"") }
        
        request.httpBody.flatMap { String(data: $0, encoding: .utf8) }.map {
            ret.append("-d '\($0)'")
        }
        
        request.url.map {
            ret.append($0.absoluteString)
        }
        
        return "curl " + ret.joined(separator: multiline ? " \\\n" : " ")
    }
    
}
