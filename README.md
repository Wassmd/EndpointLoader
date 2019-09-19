# EndpointLoader
Generic Swift API for making network request call using simple URLSession.

You just have to call GET, POST, DELETE, PUT from your controller / service class

E.g

`func findBike(at currentLocation: Location, completion: @escaping (Result<[Bike], Error>) -> Void) {
        let parameter = ["latitude": "\(currentLocation.latitude)", "longitude": "\(currentLocation.longitude)", "radius":"500"]

        loader.load(bikeURL.baseEndpoint, ignoreCache: true, json: parameter, timeoutInterval: 5.0) { result in
            switch result {
            case .success(let data):
                do {
                    print("nearbyBikes", String(data: data, encoding: .utf8)!)
                    
                    let nearbyBikes = try self.jsonDeconder.decode([Bike].self, from: data)
                    completion(.success(nearbyBikes))
                } catch let error {
                    print("Error:\(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                 completion(.failure(error))
            }
        }
    }

This framework can be added to iOS project to make all endpoint (Network Client) calls using all HTTPS method with headers and parameters.

Carthage - Install this dependecies

```
	github "wassmd/EndpointLoader" ~> 1.0.0
````````


## License

```
EndPointLoader is released under the MIT license
```
