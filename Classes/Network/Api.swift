//
//  Api.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//


import Foundation
public class Api {
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    public var objectParser = Parser()
    init(object:MediaDataListener) {
        getMediadata(mediaDataListener: object)
    }
    private  func getMediadata(mediaDataListener:MediaDataListener) {
        dataTask?.cancel()
        let urlString: String = "http://mediawebink.meride.tv/proxy/bulkproxynew/embedproxy_bulk.php/1385/webink/desktop/NO_LABEL/f4m/default/aHR0cDovL2RldjUubWVyaWRlLnR2Lyo="
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let task = defaultSession.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error calling GET on /todos/1")
                self.mediadataError(mediaDataListener:mediaDataListener,error:error.debugDescription)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            self.parseDataAndCallMediaDataComplete(mediaDataListener: mediaDataListener,response: responseData)
        }
        task.resume()
    }
    private func parseDataAndCallMediaDataComplete(mediaDataListener:MediaDataListener,response:Data){
        mediaDataListener.onMediaDataComplete(mediaModel: objectParser.parse(response))
    }
    private func mediadataError(mediaDataListener:MediaDataListener,error:String) {
        mediaDataListener.onMediaDataError(error: error);
    }
}

