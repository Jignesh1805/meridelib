//
//  MediaModel.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

public struct MediaModel  {
    public var id: String = ""
    public var customer: String = ""
    public var autoplay: Bool = false
    public var controlbarmode: String =  ""
    public var controlbar_auto_hide: Bool = false
    public var seekable: Bool = false
    public var responsive: Bool = false
    public var wmode: String =  ""
    public var adblock_policy: String = ""
    public var player_adv_manager: String = ""
    public var ima_vpaid_mode: String = ""
    public var desktop_player: String = ""
    public var bulk_selected_label: String = ""
    public var skin: String = ""
    public var title:String = ""
    
    weak var objectVideo = VideoModel()
}

