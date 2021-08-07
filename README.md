#  Networking Layer

This is a generic networking layer which I have refined over a number of similar projects. It should provide a decent starting point for 
any new project.

## Endpoint Type
This is designed to describe the endpoint (URLString, HTTP Method and Headers). 

## NetworkingError
Generally these would be expanded upon based on the error states possible with a specific backend

## NetworkManager
Usage:
```
class SampleService {
    static let shared = AuthenticationService(networkManager: NetworkManager())
    private let networkManager: Networking
    
    init(networkManager: Networking) {
        self.networkManager = networkManager
    }
    
    func doSomething(completion: @escaping ((Result<Type, NetworkingError>) -> Void)) {
        let endpoint = Endpoint(urlString: "http://sample.com", method: .GET, headers: [:])
        networkManager.execute(endpoint, dataType: TokenPair.self) { result in
            completion(result)
        }
    }
}
```

## Testing
By conforming URLSession to NetworkSession protocol, it allows us to inject a mock to take the place of URLSession in tests - enabling 
full testing of the `execute` method without hitting the network.



