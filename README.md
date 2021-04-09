# Slab

In house building, a slab is what's just over the foundations. So Slab is an overlay to Foundation, extending common types and providing convenience methods and common third-party dependencies.

It also provides two tools described in [Useradgents’ iOS Architecture Guide](about:) : the Version Wizard, and the Environment Manager (with its associated Configuration Encryptor).


## Dependencies

Slab automatically adds common dependencies to your project:

- [RNCryptor](https://github.com/RNCryptor/RNCryptor) (MIT Licence) — AES encryption/decryption
- [KeychainSwift](https://github.com/evgenyneu/keychain-swift) (MIT Licence) — Swifty Keychain handling
- [Reachability](https://github.com/ashleymills/Reachability.swift) (MIT Licence) — Swifty replacement for Apple’s Reachability, with closures

## Foundation Extensions

### Array.swift, Collection.swift, Sequence.swift

- **Extension on `Array`:**

    `func removing(at: Index) -> Array`  
        Returns a copy of the Array with the nth Element removed

    `func appending(_: Element) -> Array`  
        Returns a copy of the Array with the given Element appended
        
- **Extension on `Collection`:**

    `var isNotEmpty: Bool`  
        A boolean value indicating the collection is **not** empty
        

- **Extension on `Optional<Collection>`:**

    `var isEmpty: Bool`  
        A Boolean value indicating whether the optional is nil or the wrapped collection is empty.

    `var isNotEmpty: Bool`  
        A Boolean value indicating whether the wrappd collection is neither nil nor empty.

    `var nilIfEmpty: Bool`  
        Collapses an empty wrapped collection into a nil

    `var count: Int`  
        The count of the wrapped collection, or zero if the optional is nil

- **Extension on `Collection<Identifiable>`:**  

    `subscript(id: Element.ID) -> Element?`  
        Access identifiable elements by subscripting their id


### Codable.swift
- Provides both `JSONEncoder.shared` and `JSONDecoder.shared` (with no customization).

- **Extension on `JSONDecoder`:**

     `decode<T>(_: T.Type, at: URL) throws -> T where T : Decodable`  
        Decodes an instance of the indicated type from data at the given URL

- **Extension on `JSONEncoder`:**

    `encode<T>(_: T, to: URL) throws where T: Encodable`  
        Encodes an instance of the indicated type and writes it to the given URL


### Date.swift, DateComponents.swift, DateFormatter.swift

 Notably, these extensions allow creating DateComponents by writing
 
    1.year.and(1.week)
 
 Or creating past/future Date by writing
 
    18.months.ago
    1.year.and(2.months).fromNow
    Date.tomorrow >> 3.hours


- **New protocol**

    `protocol Dated`  
        All types adhering to this protocol have a `date: Date` instance variable.

- **Extension on `Date`:**

    `func progress(between: Date, and: Date) -> Double`  
    `func progress(in: ClosedRange<Date>) -> Double`  
        Returns the fraction of time elapsed between two dates, as a Double in the range `0...1`

    `var dmy: DateComponents`  
        Returns the day, month and year components of the Date

    `var isPast: Bool`  
    `var isFuture: Bool`  
    `var isToday: Bool`  
    `var isTomorrow: Bool`  
        Returns boolean values stating whether the Date is past, future, today or tomorrow (according the current Calendar)

    `var midnight: Date`  
        Returns a Date set to the beginning of its day (by setting hour, minute and second components to zero, according to the current Calendar)

    `var timeIntervalSinceMidnight: TimeInterval`  
        Returns the timeInterval since midnight, according to the current Calendar.

    **Getting common dates:**  
    `static var midnight: Date`  
        Returns a Date set to the beginning of the current day, according to the current Calendar

    `static var tomorrow: Date`  
        Returns a Date set to the beginning of tomorrow, according to the current Calendar

    `static var yesterday: Date`  
        Returns a Date set to the beginning of yesterday, according to the current Calendar

    `static var timeIntervalSinceMidnight: TimeInterval`  
        Returns the timeInterval of the beginning of the current day, according to the current Calendar

- **Extension on `ClosedRange<Date>`:**

    `var isPresent: Bool`  
        Returns a Bool indicating whether the Date range contains the current Date

    `var isPast: Bool`  
    `var isFuture: Bool`    
        Return a Bool indicating whether the Date range is *entirely* in the past or in the future

- **Operators:**

    `Date >> TimeInterval -> Date`  
        Adds a TimeInterval to a Date

    `Date << TimeInterval -> Date`  
        Subtracts a TimeInterval to a Date

    `Date >> DateComponents -> Date`  
        Adds DateComponents to a Date according to the current Calendar

    `Date << DateComponents -> Date`  
        Subtracts DateComponents to a Date according to the current Calendar




## General Tools

## Custom Collections

## Networking

## Property Wrappers

## Version Wizard
Shell script that synchronizes build versions and numbers across multi-scheme apps, as described in [Useradgents’ iOS Architecture Guide](about:).

### Setup
- A single mandatory user-defined Build Setting must be created: `VW_APP_ID`, which will usually be in the form `ios.<projectName>`
- Other build settings can be used to control various parts of the version wizard, they are explained directly in the `VersionWizard.sh` file
- Create a Run Script Build Phase (at the very end, after Copy Bundle Resources) named `Version Wizard`, with the following contents:

```
$(echo "$BUILD_ROOT" | sed 's%/Build/.*%%')/SourcePackages/checkouts/Slab/Helpers/VersionWizard.sh
```
- Tick the checkbox so that it runs "For install builds only"

## Environment Manager

Component that allows secure embedding of configuration keys, and easy runtime switching of environments.

A whole Xcode project demonstrating the Environment Manager is available in the [EnvTest repository](https://bitbucket.org/useradgents/envtest/src/master/)


### 1. Multi-scheme setup
Even though there's nothing preventing you from only using a Production environment and no other one, the Environment Manager only shines when used in a multi-scheme setup : one Production application, and one Dev application that allows runtime switching of environments.

To correctly setup your multi-scheme project, head over to [Useradgents’ iOS Architecture Guide](about:).

### 2. Environment Manager Setup

- Create an `Environments` directory somewhere in your project
- Add at least an `env_prod.json` file containing :

```
{
    "environment": {
        "name": "Production",
        "emoji": "🎢"
    },
    
    "api": {
        "baseURL": "https://mywonderfulapi.io/v1/"
        [... the rest of your configuration ...]
    },
    
    [... other groups of settings ...]
}

```

- Add a "Run Script" build phase, name it "Encrypt Environments", and ensure it runs **before** "Copy Bundle Resources". Script contents :

```
$(echo "$BUILD_ROOT" | sed 's%/Build/.*%%')/SourcePackages/checkouts/Slab/Helpers/ConfCryptor.sh
```

- add the `Environments` directory you’ve just created to the script’s Input Files, eg.

```
$(SRCROOT)/EnvTest/Environments
```

- Build the project at least once.

- If no failure is encountered, the file `env_prod.json.aes` will be created along `env_prod.json`. Add it to the Project Navigator.
	- Select `env_prod.json`, make sure it is **not** in the Target Membership settings (you don’t want your plain-text credentials in your final app bundle).
	- Select `env_prod.json.aes` and make sure it is included in the Target Membership instead.

Rinse & repeat for your other environments.

The AES files are built artifacts which are regenerated on each build, so they don’t need to be tracked. Don’t forget to add this line to your `.gitignore` :

```
*.json.aes
```



### 3. Usage

Again, please take inspiration from the [EnvTest repository](https://bitbucket.org/useradgents/envtest/src/master/) which implements all of this

- Instanciate an `EnvironmentManager` in your AppDelegate.
	- Production schemes don’t need no particular arguments ;
	- Development schemes must pass `developmentMode: true` and an optional `onChange` closure that will be called when the app restarts on a different environment than before (for clearing caches, disconnecting the user, …)
	- If the initializer throws an error, there’s something wrong with the setup in the previous section.

- To retreive settings for the current environment, use:

```
let env = try EnvironmentManager()
[...]
let baseURL = env.url(forKey: "api.baseURL")
```

Other methods include `string(forKey:)`, `bool(forKey:)`, `value(forKey:)`.

- To allow selecting another environment in Development schemes, iterate over `env.all` which lists all the available environments as an array of `Environment` structs. Equality to `env.current` can be tested to provide a checkmark for the currently-selected environment.
- To make another environment active, call its `activate()` method. This will force-sync the UserDefaults and force-quit the app with a call to `exit()` — which are methods that will get you a rejection from Apple if you call them in production code (even though they are not private API).
