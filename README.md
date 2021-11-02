# SwiftyLink

SwiftyLink is a fully-fledged Lavalink client written in Swift 5. It supports querying songs from multiple platforms, and gives you full access to everything Lavalink has to offer through its REST API.

# Library support

SwiftyLink supports SwiftDiscord's vapor3 branch out of the box. If you would like to add custom library support, your library MUST be able to do these things:
1. It must be able to intercept **RAW** VOICE_SERVER_UPDATE and VOICE_STATE_UPDATE payloads from Discord's dispatch handling.
2. It must be able to send payloads through a shard's websocket connection
3. It must be able to send the intercepted payloads to this library using the ```sendUpdate()``` method.

# Connecting to Lavalink
First, initialize your Lavalink node. 
```swift
import Discord
import Dispatch
import SwiftyLink

class Bot: DiscordClientDelegate {
    private var client: DiscordClient!
    public var manager: SwiftyNode?

    init() {
        client = DiscordClient(token: "Bot mytoken", delegate: self)
        client.connect()
        self.manager = SwiftyNode(
                        password: "youshallnotpass", 
                        port: "2333", 
                        ID: "\(client.user.id)", 
                        shards: "1", 
                        host: "127.0.0.1", 
                        client: client
    )}

    func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
        if message.content == "?ping" {
            message.channel?.send("pong")
        }
    }
}

let bot = Bot()
dispatchMain()
```

Next, you must send Lavalink raw VOICE_STATE_UPDATE/VOICE_SERVER_UPDATE payloads intercepted from Discord.
```swift
func client(_ client: DiscordClient, didRecieveVoiceServerUpdate voiceServer: DiscordVoiceServerInformation) {
        
    let server = client.ws.voiceServerData!
    let state = client.ws.voiceStateData!
        
    let userID = UserID(state["user_id"] as! String)
        
    let sJson = serverJSON(
                     token: server["token"] as! String, 
                     guild_id: server["guild_id"] as! String, 
                     endpoint: server["endpoint"] as! String
                    )
        
    let s = voiceUpdateJSON(
                op: "voiceUpdate", 
                sessionId: (client.guilds[voiceServer.guildId]!.voiceStates[userID!])!.sessionId, 
                guildId: server["guild_id"] as! String,
                event: sJson
               )
        
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
        
    let JSONData = try! encoder.encode(s)
        
    let JSON = String(data: JSONData, encoding: .utf8)!
        
    self.manager!.sendUpdate(msg: URLSessionWebSocketTask.Message.string(JSON))
        
   }
```
After that, you can connect to your nodes in the ready event.
```swift
func client(_ client: DiscordClient, didReceiveReady readyData: [String : Any]) {
        self.manager?.connect()
    }
```
# Usage
To join a voice channel, send SwiftyLink a `createPlayer()` method. Afterwards, you may use the `player?.connect()` method to connect to the voice channel.

The `player?.connect()` method accepts two additional parameters. The deaf parameter determines if the client will be deafened upon joining, whilst the mute parameter determines if the client will be muted upon joining.
```swift
func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
        if message.content == "?join" {
            let player = self.manager?.createPlayer(guild: "\(message.channel!.guild!.id)")
        
            player?.connect(channel: "\(message.guildMember!.voice!.channelId)", deaf: true, mute: false)
        }
    }
```
To play a song, use the `player?.play()` method. The argument is either the base64 Lavalink string or the YouTube identifier.
```swift
if message.content == "?play" {
        let player = self.manager?.createPlayer(guild: "\(message.channel!.guild!.id)")
        player?.play("ytsearch:Emperor'sNewClothes")
    }
```
To pause or the player, use `player?.pause()`. The boolean argument accepts true for pausing, and false for unpausing.
```swift
if message.content == "?pause" {
        let player = self.manager?.createPlayer(guild: "\(message.channel!.guild!.id)")
        player?.pause(true)
    }
```
```swift
if message.content == "?resume" {
        let player = self.manager?.createPlayer(guild: "\(message.channel!.guild!.id)")
        player?.pause(false)
    }
```
To stop the player, utilize the `player?.stop()` method.
```swift
if message.content == "?stop" {
        let player = self.manager?.createPlayer(guild: "\(message.channel!.guild!.id)")
        player?.stop()
    }
```
# Documentation and Support
Docs are coming soon!! I swear!!!

For support inquires, you can find me in the Discord API server.

I have a few items i'd like to complete.
- Remove the SwiftDiscord dependency (all it does is it talks to the API)
- Fix some runtime errors
- Safely unwrap each optional instead of force unwrapping it. This makes the syntax cleaner and allows for more efficient debugging, as force unwrapping a nil operator (which is done frequently) will cause a hard crash.
- Clean up the syntax

I am aiming for all of this to be completed by the mid-version codebase reinforcement.

# Contributing
I am a software developer, therefore I understand how important open source software is to the community. I also understand the burden of contributing to open source software. The Contributing guidelines are simple and straightforward, easy for a beginner to understand. Following the guidelines are a MUST for contributing, as well as the PR and issue templates.

# License
Licensed under the MIT license.

# Credits
[nuclearace](https://github.com/nuclearace) - SwiftDiscord.

[fwcd](https://github.com/fwcd) - SwiftDiscord fork that allowed me to expand.

[freyacodes](https://github.com/freyacodes) - Lavalink that made this all possible.

#
© TotallyNotNero 2021
