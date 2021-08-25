# Luna iOS SDK

Luna SDK is an iOS framework for working with Luna Trackers.  
 
Luna SDK consists of five modules:
* Finder 
* Owner  
* Local 
* Buzzer 
* Onboarder
 
**Finder Module** continuously monitors LunaTrackers in the background and reports discovered devices to the server.  

**Owner Module** provides a set of tools for managing LunaTrackers: listing onboarded devices, forgetting and searching for events associated with onboarded device etc.
 
**Local Module** scans LunaTrackers nearby and reports found devices with their basic properties, such as RSSI. 

**Buzzer Module** allows for buzzing a LunaTracker using Control Packages.

**Onboarder Module** allows for onboardings devices. 
 
LunaTracker is a bluetooth device that oscillates between two modes: iBeacon and BLE advertising. In the iBeacon mode the device cycles between a few different UUIDs making it possible to wake up app hosting the SDK in the background. Once the app hosting the SDK is woken up in the background (as a result of getting in the range of iBeacon), the SDK starts scanning for bluetooth peripherals with service `0x1804`.  


## Installation

Luna SDK is entirely standalone and does not depend on any third party libraries. The easiest way to integrate Luna SDK with the host application is via [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) (CocoaPods version 1.5.3 suggested).

Please add `pod 'LunaSDK', :git => 'git@github.com:indigo-d/luna-app.git'` to your Podfile, example:
```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'LunaSDK', :git => 'git@github.com:indigo-d/luna-app.git'
end
```

Execute `pod install` so that CocoaPods fetches and links Luna SDK with your project.

Please note that Luna SDK is not available publicly. Please ensure that you have obtained access to Luna SDK repository.


## Prerequisites

In order for Luna SDK to function correctly, the developer of the host application needs to ensure that the host app includes required background mode settings and requests user permission to access location, etc.

### Project settings

LunaSDK requires a few configuration steps that need to be taken by the developer of the host application.

1) Location updates in the Background Modes - UIBackgroundModes of type `location` need to be defined in host app Info.plist file. See example below:

```
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

2) Request Always Authorization for the location updates - in order for registering for iBeacon events when the application is not actively running the host app needs to be authorized by the user to fetch user location always. Developer of the host application should request user permission before initiating LunaSDK.

## LunaSDK version number

Static method `Luna.version()` exposes a version number as defined in the Podspec for the project. 

## LunaFinder - configuration

Example given below presents how the Luna Finder module could be initiated from within the host app AppDelegate class. 

```swift
import UIKit

// 1
import LunaSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // 2
    let lunaFinder = Luna.finder()
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 3
        lunaFinder.delegate = self
        
        // 4
        lunaFinder.startMonitoring()
        
        return true
    }
}

// 5
extension AppDelegate: LunaDelegate {

    func lunaFinder(didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // optional
    func lunaFinder(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(region)
    }
    
    // optional
    func lunaFinder(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print(region)
    }
    
    // optional
    func lunaFinder(didFindHeid heid: String) {
        print(heid)
    }
}
```

1) Import ```Luna SDK```.
2) Initialize ```LunaFinder``` object with the ```.plist``` name that your app use. For most of the projects default name is "Info". `.plist` file will be used to check if the developer has enabled `Background location updates` for the app. 
3) Delegate for the ```LunaFinder``` is set. Conformance to the ```LunaDelegate``` protocol is set in the extension of the AppDelegate.
4) ```startBeaconsMonitoring(withRegions: [String])``` function is used to register UUID's for proper iBeacons. After function is called, monitoring of specified iBeacons will be initialized.
5) In the AppDelegate extension, conformance to the ```LunaDelgate``` protocol is set. 

## LunaFinder API

`LunaFinder` instance can be obtained by calling: `Luna.finder()` method from `LunaSDK` package.

`LunaFinder` exposes two public methods:

```
func startMonitoring(configuration: LunaConfiguartion)
```
Registers the app to be woken up in response to iBeacon events and triggers BLE scanning after a device has discovered iBeacon device.

Starts continuous scanning for LunaTrackers. It registers the app to be woken up by iOS when one of 3 Luna iBeacon regions is entered. It starts scanning for user location so that discovered LunaTrackers can be matched to current user location.

Instance of LunaConfiguration class should be passed as a parameter.


```
func stopMonitoring()
```

Stops all monitoring activities initiated by `func startMonitoring(configuration: LunaConfiguartion)`.


### LunaDelegate

LunaDelegate protocol is used to notify the host app about events such as finding a tracker or problems preventing the SDK from functioning correctly. 

#### LunaDelegate Delegate required methods

```swift
func lunaFinder(didFailWithError error: Error)
```

Notifies the host application about issues preventing Luna SDK from functioning properly. Please ensure that this method is implemented on your delegate class and that reported errors are not ignored.

#### LunaDelegate Optional methods

```swift
[DEPRECATED]
func lunaFinder(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
```

DEPRECATED. Called when a device has entered iBeacon region. 

```swift
[DEPRECATED]
func lunaFinder(_ manager: CLLocationManager, didExitRegion region: CLRegion)
```

DEPRECATED. Called when a device has left iBeacon region.

```swift
func lunaFinder(didFindHeid heid: String)
```

Called when a device with given Heid is discovered. Can be used as a trigger to instantiate LunaLocal instance and scan for devices nearby and get full details of nearby devices.

## LunaLocal API

LunaLocal provides ability to easily scan devices nearby. `LunaLocal` instance can be obtained by calling: `Luna.local()` method from `LunaSDK` package.

`LunaLocal` exposes:

```
func startScanning(_ trackedDevices: [Device])
```

LunaLocal will start scan for all of the Luna devices nearby using CoreBluetooth framework. All of the discovered devices are exposed under `devices` property. Each modification of `devices` property value is notified using `onDevicesUpdate` callback. `devices` contains an array of `LocalDevice` instances.
   
`Device` elements passed as `trackedDevices` will be followed by the LunaLocal meaning that physical devices reporting sequential eids will be followed (in colloquial words, `LunaLocal` will know that two different eids represent the same physical device) and hence will be represented by the same instance of `LocalDevice` in the `devices` property.

All of the `trackedDevices` will be mapped to "empty" `LocalDevice` instances the moment the `startScanning` function is called.  


```
func stopScanning()
```

Stops all scanning activities initiated by `func startScanning()`.

``` 
func reset() 
```

Clears all of the discovered devices from the `devices` array.


```
var devices: [LocalDevice] = []
```

An array containing all of the discovered devices.

```
var onDevicesUpdate: () -> () 
```

A callback function called whenever a change to devices array is made. `LunaLocal` client is expected to provide a custom implementation in order to consume events on discovered devices.


## LunaOnboarder API 

LunaOnboarder allows for onboarding an onboardable device (`LocalDevice` instance) returned by `LunaOnboarder`.   

In order to start onboarding please execute:

```
func startOnboarding(localDevice: LocalDevice)
```

Onboarding can be terminated by executing:

```
func stopOnboarding()

```

Successful onboarding is indicated by executing `onEvent` callback.

LunaOnboarder exposes two properties that can be modified by its clients.

#####1. onEvents callback
```
var onEvent: (LunaOnboarderEvent) -> ()
```

`onEvent` callback, which accepts`LunaOnboarderEvent` as a parameter, can be used to react on events during onboarding process. It is highly advised in most use cases to provide custom implementation for this property.

#####2. viewController property
```
var viewController: UIViewController?
```

A `viewController` instance can be passed to `LunaOnboarder` so that (if no custom implementation of `onEvent` callback is provided) the LunaOnboarder can present simple alert messages during the onboarding process.


`LunaOnboarderEvent` might have one of the three values:

```
enum LunaOnboarderEvent {
    // a valid device is found and it is in connectable mode, onboarding is being attempted
    case discoveredConnectableLuna(String) 
    // a valid device is found but it is not connectable, onboarding will be attempted once the device changes into connectable mode
    case discoveredNonConnectableLuna(String)
    // device has been onboarded
    case lunaOnboarded(Device)
}
```

## LunaBuzzer API 

LunaBuzzer allows for buzzing an onboarded device.   

In order to start buzzing please execute:

```
func startBuzzing(localDevice: LocalDevice)
```

or

```
func startBuzzing(localDevice: LocalDevice, controlPackages: [ControlPackage])
```
 
where `controlPackage` include a list of control packages where at least one package matches eid/heid currently broadcast by the tracker.

When `controlPackages` property is not passed, `LunaOwner` module is used to find a matching `controlPackage` for the device (assuming the device has been onboarded from the same host app instance).

Buzzing can be terminated by executing:

```
func stopBuzzing()

```

Successful buzzing is indicated by executing `onEvent` callback.


## LunaOwner API


###1. Finding events
```
func findEvents(device: Device, dateFrom: Date, dateTo: Date,  _ successHandler: @escaping (([Event], String) -> ()), _ errorHandler: @escaping (String) -> ()) {
```

Returns all events associated with the `device` that were registered between `dateFrom` and `dateTo`.
Results are returned via `successHandler` callback. SDK only accepts date ranges that are not bigger than a year. 


###2. Listing all devices
```
func allDevices() -> [Device]
```

Returns a list of all onboarded devices.


###3. Forgetting a device
```
func forgetDevice(_ device: Device)
```

Removes an onboarded device the internal database, effectively forgetting a device.


## Data models


###LunaConfiguration 

Defines basic configuration of the tracking behaviour

```
class LunaConfiguration {
    var timeBetweenPostsToServerInSeconds = 10
    var maximumCacheSize = 10
    var minimumDistanceBetweenTwoLocationsInMeters = 10.0 // MD
    var minimumTimeBetweenTwoEventsInSeconds = 60.0  // MT
    var dataFilename = "luna-finder-memory.data"
    var devicesFilename = "luna-finder-memory-devices.data"
    var finderDesiredAccuracy: CLLocationAccuracy? = nil
    var logger: Logger
}
```

###Device 

Device is a struct representing basic properties of an onboarded device:

```
struct Device {
    var uuid: String
    var masterKey: String
    var onboardingTimestamp: Date
    var name: String
}
```


###LocalDevice 

LocalDevice represents a logical device discovered by LunaLocal module.

```
class LocalDevice {
    // peripheral name
    var name: String?
    // is the device assumed to be missing after having not been visible for timeout perioud 
    var timedOut: Bool? 
    // does the device report low battery level status 
    var batteryLowLevel: Bool?
    // time of the last advertisement received from the device    
    var lastSeenDate: Date? 
    // array of all device show-ups
    var timestampedEids: [TimestampedEid] = []
    // first time when the device showed-up
    var firstSignalDate: Date?
    // is the device connectable
    var connectable: Bool?
    // identifier of the peripheral
    var identifier: String 
    // rssi value associated with the last advertisement 
    var rssi: Double? 
    // is the device onboarable
    var onboardable: Bool 
    // heid associated with the last advertisement
    var heid: String?
    // eid associated with the last advertisement
    var eid: String? 
}
```

###LocalDevice 

An array of `TimestampedEid` items is given `LocalDevice` and represents each event when a device was discovered by `LunaLocal`. 

```
struct TimestampedEid {
    // eid associated with the advertisement
    var eid: String
    // time when the advertisement was received
    var receivedAt: Date
    // expected time when given eid was expected 
    var expectedAt: Date?
    // drift in seconds between expected and received times or Double.nan if the drift cannot be calculated (expectedAt is null) 
    var drift: TimeInterval
}
```

###Event

Event is a struct representing decoded state of an event fetched from the server.


```
struct Event {
    var collectedAt: Date
    var eid: String
    var latitude: Double
    var longitude: Double
    var batteryStatus: Bool
}
```

LunaOwner fetches encrypted events from the server and decrypts it locally using AOTP and BOTP associated with EID.    


###Logger

LunaSDK exposes `Logger` protocol together with its default implementation as `ConsoleLogger` which is used to initiate default value for `logger` property in `LunaConfiguration`. Client can provide a custom implementation of `Logger` protocol and hence have full control on how logs are consumed and (if) propagated.

`Logger` defines three levels of log messages:

`INFO` - used for informational messages that relate to top-level processes   
`DEBUG` - used for detailed messages that provide more context and are used primarily for debugging   
`ERROR` - used for messages indicating recoverable errors that can be handled within the app



### LunaFinder <-> Luna backend interactions

LunaFinder works in the background and monitors Luna devices in the vicinity of the user. iBeacon uuids are used internally to register regions and ensure that the host application gets woken up every time a Luna device is discovered by the operating system. Background tracking works even when the host app has been forcefully closed by the user.

Whenever host application gets woken up by the operating system as a result of entering Luna iBeacon region a regular BLE scanning is started and Luna devices are quickly discovered.

Each discovery of a Luna device results in tracker event being created. Each such event contains:

`protocolVersion` - version number as reported in the advertisement 

`heid` - heid value as reported in the advertisement 

`encodedLocation` - GPS location encrypted using key created as a concatenation of eid and aotp from the advertisement
 
`esf` - encrypted status fields

In addition to this several "debug" properties are recorded as well:

```
"eid"
"aotp"
"manufacturerId"
"keyRollingCounter"
"deviceName"
"batteryLevel"
"batteryState"
"locationSharingStatus"
"latitude"
"longitude"
"altitude"
"locationTimestamp"
"horizontalAccuracy"
"verticalAccuracy"
"course"
"speed"
```    

Above debug details are intended for testing only and will not be a part of the public version of the SDK.

Events are written to local `EventCache` and uploaded to the Luna Backend in batched (`POST /trackerEvent`)

Upon event batch upload Luna Backend verifies if there are any command requests associated with the events being uploaded. If so, such commands (with associated control packages) are returned to the LunaFinder module. Commands delivered back to LunaFinder are processed one by one. Successful execution of commands results in an acknowledgement being uploaded to LunaBackend (`POST /remote-control-request/confirm`).
  