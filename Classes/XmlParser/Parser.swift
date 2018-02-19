//
//  Parser.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

import Foundation
public class Parser: NSObject, XMLParserDelegate {
    var objectPleyview:MerideVideoControlView? = MerideVideoControlView()
    var object:OnMerideInitilizeListener!
    var objectMeride = MediaModel()
    var objectVideo = VideoModel()
    var elementNm : String = ""
    var currentlyParsingElement: String = ""
    var insideItem = false
    var cData : String = ""
    public func parse(_ data: Data)->MediaModel{
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return objectMeride
    }
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        // print("start elememt:==\(elementName)")
        elementNm = elementName
        if elementName == "embed"{
            if let id = attributeDict["id"] , let customer = attributeDict["customer"] ,let autoplay:Bool = Bool(attributeDict["autoplay"]!),let controlbarmode = attributeDict["controlbarmode"],let controlbar_auto_hide = Bool(attributeDict["controlbar-auto-hide"]!),let seekable = Bool(attributeDict["seekable"]!),let responsive = Bool(attributeDict["responsive"]!),let adblock_policy = attributeDict["adblock-policy"],let wmode = attributeDict["wmode"] ,let player_adv_manager = attributeDict["player-adv-manager"],let ima_vpaid_mode = attributeDict["ima-vpaid-mode"],let  desktop_player = attributeDict["desktop-player"],let bulk_selected_label = attributeDict["bulk-selected-label"]{
                
                objectMeride.id = id
                objectMeride.customer = customer
                objectMeride.autoplay = autoplay
                objectMeride.controlbarmode = controlbarmode
                objectMeride.controlbar_auto_hide = controlbar_auto_hide
                objectMeride.seekable = seekable
                objectMeride.responsive = responsive
                objectMeride.wmode = wmode
                objectMeride.adblock_policy = adblock_policy
                objectMeride.player_adv_manager = player_adv_manager
                objectMeride.ima_vpaid_mode = ima_vpaid_mode
                objectMeride.desktop_player = desktop_player
                objectMeride.bulk_selected_label = bulk_selected_label
                
            }
        }
        
        if elementName == "video"{
            insideItem = true
        }
        if insideItem {
            switch elementName {
            case "default":
                currentlyParsingElement = "default"
            case "iphone":
                currentlyParsingElement = "iphone"
            case "mp4":
                currentlyParsingElement = "mp4"
            case "poster":
                currentlyParsingElement = "poster"
            default: break
            }
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // print("end elememt:==\(elementName)")
        if elementName == "video"{
            insideItem = false
            objectMeride.objectVideo = objectVideo
        }
    }
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
    }
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let stringData = String(data: CDATABlock, encoding: String.Encoding.utf8) {
            cData = stringData
        }
        if elementNm == "skin"{
            objectMeride.skin = cData
        }
        if elementNm == "title"{
            objectMeride.title = cData
        }
        if insideItem {
            switch currentlyParsingElement {
            case "default":
                objectVideo.defaultUrl = cData
            case "iphone":
                objectVideo.iphone = cData
            case "mp4":
                objectVideo.mp4 = cData
            case "poster":
                objectVideo.poster = cData
            default: break
            }
        }
    }
    public func parserDidEndDocument(_ parser: XMLParser) {
        if objectMeride != nil{
            self.objectPleyview?.getObject(objectMeride: objectMeride)
        }else{
        }
    }
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        object.onMerideInitilizedError(errorMessage: parseError.localizedDescription)
    }
}

