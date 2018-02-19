//
//  MediaDataListener.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

public protocol MediaDataListener : class {
    func onMediaDataComplete(mediaModel:MediaModel)
    func onMediaDataError(error:String)
}

