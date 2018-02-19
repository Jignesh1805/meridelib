//
//  Meride.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

import Foundation
public class Meride:MediaDataListener{
    private static var objectListener : OnMerideInitilizeListener?
    
    public static func initilize(listener:OnMerideInitilizeListener) {
        if isInternetAvailable(){
            getMediaData(listener:listener)
        }else{
            listener.noInternetConnection(message: CONSTANT.INTERNET_CONNECTION_ERROR)
        }
    }
    
    public static func getMediaData(listener:OnMerideInitilizeListener){
        objectListener = listener
        //  objectMeride = Meride()
        let objectMeride = Meride()
        _ = Api.init(object: objectMeride)
    }
    
    public func onMediaDataComplete(mediaModel: MediaModel) {
        print(mediaModel.id)
        Meride.objectListener?.onMerideInitilizedSucess(successMessage: "successfully initilize meride..")
    }
    
    public func onMediaDataError(error: String) {
        print(error)
        Meride.objectListener?.onMerideInitilizedError(errorMessage: "getMediadata() error " + error)
    }
}

