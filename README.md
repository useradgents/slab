# Slab

In house building, a slab is what's just over the foundations. So Slab is an overlay to Foundation, extending common types and providing convenience methods and common third-party dependencies.

It also provides two tools described in [Useradgents’ iOS Architecture Guide](about:) : the Version Wizard, and the Environment Manager (with its associated Configuration Encryptor).

### Authors
- Cyrille Legrand <[c.legrand@useradgents.com](mailto:c.legrand@useradgents.com)>
- Julien Pipard <[j.pipard@useradgents.com](mailto:j.pipard@useradgents.com)>
- Thejus Thejus <[t.thejus@useradgents.com](mailto:t.thejus@useradgents.com)>


## Dependencies

Slab automatically adds common dependencies to your project:

- [RNCryptor](https://github.com/RNCryptor/RNCryptor) (MIT Licence) — AES encryption/decryption
- [KeychainSwift](https://github.com/evgenyneu/keychain-swift) (MIT Licence) — Swifty Keychain handling
- [Reachability](https://github.com/ashleymills/Reachability.swift) (MIT Licence) — Swifty replacement for Apple’s Reachability, with closures

## Foundation Extensions

### Array.swift, Collection.swift, Sequence.swift

- **Extension on `Array`:**

    `removing(at: Index) -> Array`  
        Returns a copy of the Array with the nth Element removed

    `appending(_: Element) -> Array`  
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
        
- **Extension on `Collection<Equatable>`:**  

    `replacing(_: Element, with: _Element) -> [Element]`  
        Returns a copy of the collection with each occurence of an element replaced with another.
        

- **Extension on `Collection<Collection>`:** 

    `var noneIsEmpty: Bool`  
        Returns true if no element in this collection is empty 

    `var allAreEmpty: Bool`  
        Returns true if all elements in this collection are empty

- **Extension on `Sequence`:**  

    `sorted<T>(by: KeyPath<Element, T>, reversed: Bool = false) -> [Element]`  
        Returns the sequence sorted by ascending keypath, optionally reversed.

### Codable.swift
- Provides both `JSONEncoder.shared` and `JSONDecoder.shared` (with no customization).

- **Extension on `JSONDecoder`:**

     `decode<T>(_: T.Type, at: URL) throws -> T where T : Decodable`  
        Decodes an instance of the indicated type from data at the given URL

- **Extension on `JSONEncoder`:**

    `encode<T>(_: T, to: URL) throws where T: Encodable`  
        Encodes an instance of the indicated type and writes it to the given URL


### Date.swift, DateComponents.swift, DateFormatter.swift, TimeInterval.swift

 Notably, these extensions allow creating DateComponents by writing
 
    1.year.and(1.week)
 
 Or creating past/future Date by writing
 
    18.months.ago
    1.year.and(2.months).fromNow
    Date.tomorrow >> 3.hours

They also implement Swift 5 string interpolation for dates: `let str = "See you on \(date, using: .shortDate)"`

- **New protocol**

    `protocol Dated`  
        All types adhering to this protocol have a `date: Date` instance variable.

- **Extension on `Date`:**

    `progress(between: Date, and: Date) -> Double`  
    `progress(in: ClosedRange<Date>) -> Double`  
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

- **Extension on `Int`:**

    `var seconds: DateComponents`  
    `var minutes: DateComponents`  
    `var hours: DateComponents`  
    `var days: DateComponents`  
    `var weeks: DateComponents`  
    `var months: DateComponents`  
    `var years: DateComponents`  
    `var second: DateComponents`  
    `var minute: DateComponents`  
    `var hour: DateComponents`  
    `var day: DateComponents`  
    `var week: DateComponents`  
    `var month: DateComponents`  
    `var year: DateComponents`  
        Allow creating DateComponents by writing `1.year` or `3.minutes`

- **Extension on `DateComponents`:**

    `func and(_: DateComponents) -> DateComponents`  
        Adds other DateComponents to these DateComponents. Allows writing `1.year.and(3.months)`

    `var negated: DateComponents`  
        Negates all values of these DateComponents. Allows writing `1.year.and(1.day.negated)`

    `var date: Date`  
        Returns the Date corresponding to these DateComponents, according the the current Calendar

    `var ago: Date`  
        Returns the current Date according to the current Calendar, minus these DateComponents. Allows writing `let threeHoursAgo: Date = 3.hours.ago`

    `var fromNow: Date`  
        Returns the current Date according to the current Calendar, adding these DateComponents. Allows writing `let nextYear: Date = 1.year.fromNow`

    `static var today: DateComponents`  
        Returns the day, month, year components for today

- **Extension on `TimeInterval`:**

    `var minutes: Int`  
    `var hours: Int`  
        Returns the number of minutes or hours in this TimeInterval

- **Extension on `DateFormatter`:**

    `convenience init(dateFormat: String)`  
        Initializes a DateFormatter with the given date format

    `convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, relative: Bool = false)`  
        Initializes a DateFormatter with the given date style, time style and `relative` flag

- **Common DateFormatters**

| `DateFormatter.` | Style | Example (fr_FR) |
|---|---|---|
| `.shortDate` | Short date, no time | 09/04/2021 |
| `.shortTime` | No date, short time | 16:59 |
| `.relativeDate` | Short date, no time, relative | demain |
| `.relativeDateTime` | Short date, short time, relative | demain 04:53 |
| `.isoDate` | ISO 8601 date | 2021-04-09 |
| `.isoDateTime` | ISO 8601 date and time | 2021-04-09T14:59:52+0000 |
| `.isoDateTimeMilliseconds` | ISO 8601 date and time (with ms) | 2021-04-09T14:59:52.059Z |

- **String Interpolation**

    `"\(Date, using: DateFormatter)"`  
        Example : `print("See you at \(startTime, using: .shortTime)")`

### Identifiable.swift

- **Extension on `Array<Identifiable>`:**

     `var keyedByID: [Element.ID: Element]`  
        Returns a dictionary where all elements of this array are keyed by their id

### Numbers.swift, NumberFormatter.swift

- **String Interpolation**

    `"\(Int|Double|Float, using: NumberFormatter)"`  
        Example : `print("\(percentage, using: .percent) done")` with percentage = 0.25 prints "25% done"

- **Common NumberFormatters**

| `NumberFormatter.` | Style | Example (fr_FR) |
|---|---|---|
| `.percentage` | `percent` style, 0 to 2 fraction digits | 0.25 → "25%" |
| `.euros` | `currency` style with `EUR` code | 42 → "42,00 €" |
| `.decimal` | `decimal` style, 0 to 2 fraction digits | 13.3724 → "13,37" |

- **Easing and interpolation**

    `ease(F) -> F`  
        sin-wave easing from [0...1] to [0...1]  
        Global-scope method where F is either CGFloat, Float or Double.

    `fallIn(from: ClosedRange<Self>, to: ClosedRange<Self> = 0...1) -> Self`  
    `fallOff(from: ClosedRange<Self>, to: ClosedRange<Self> = 0...1) -> Self`  
        Maps value from the range `inRange` to `outRange`, rising up (fall-in) or down (fall-off). See ASCII-art comment at the top of `Numbers.swift` for a graphical explanation.  
        Works on all instances of types conforming to `FloatingPoint` (CGFloat, Float, Double)
 
 
### OptionSet.swift

Allows `OptionSet`s to conform to `Sequence` so they become natively iterable.

```
struct WeekdaySet: OptionSet, Sequence {
    let rawValue: Int
    static let monday = WeekdaySet(rawValue: 1 << 0)
    ...
}

let weekdays: WeekdaySet = [.monday, .tuesday]
for weekday in weekdays {
    // Do something with weekday
}
```

### Range.swift

- **Safe range formation operators**

Swift will crash at runtime if creating a range from values that are not in ascending order. Slab introduces two operators `....` and `...<` which fix this problem.

- **Common `ClosedRange<Int>`:**

```
public static var zero: ClosedRange<Int> = 0 ... 0
public static var zeroOrOne: ClosedRange<Int> = 0 ... 1
public static var any: ClosedRange<Int> = 0 ... Int.max
public static var one: ClosedRange<Int> = 1 ... 1
public static var oneOrMore: ClosedRange<Int> = 1 ... Int.max
```

### String.swift

- **Localization operator**

```
"hello"† == NSLocalizedString("hello", comment: "?⃤ hello ?⃤")
```

The cross `†` is done with alt+T on a US (QWERTY) or FR (AZERTY) keyboard. It looks like a T, so it reads like Translated

- **Extension on `String`:**

     `func matches(_ regex: String) -> Bool`  
        Tests if the String matches a given regular expression.

     `var withoutDiacritics: String`  
        Returns a version of the string with diacritics removed (eg: "Älphàbêt" becomes "Alphabet").

     `var initials: String`  
        Returns the initials of the string, by keeping the first character of each word.

     `var forSort: String`  
        Returns a sort-friendly variant of the string (all lowercase, without diacritics).

     `var cleanedUp: String`  
        Returns another sort-friendly variant of the string (all uppercase, without diacritics, keeping only alphanumerics).

     `func sha1() -> String`  
        Returns the SHA-1 hash of the string.

     `func sha256() -> String`  
        Returns the SHA-256 hash of the string.



## General Tools

## Custom Collections

## Networking

## Property Wrappers

## Localise.biz fetcher
Shell script that fetches Localizable.strings and InfoPlist.strings from Localise.biz on every build.

### Setup
- Build settings accordingly to what's defined in Localise.biz.sh
- Create a Run Script Build Phase (at the very end, after Copy Bundle Resources) named `Localise.biz`, with the following contents:

```
$(echo "$BUILD_ROOT" | sed 's%/Build/.*%%')/SourcePackages/checkouts/Slab/Helpers/Localise.biz.sh
```

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
- To easily provide environment change in SwiftUI:

```
struct DebugMenu: View {
    init(envManager: EnvironmentManager) {
        self.environments = envManager.allEnvironments.sorted(by: \.order)
        self.selectedEnvironment = envManager.current
    }
    
    let environments: [RuntimeEnvironment]
    @State var selectedEnvironment: RuntimeEnvironment
    
    var body: some View {
        Form {
            Section {
                Picker("Environment", selection: $selectedEnvironment) {
                    ForEach(environments, id: \.self) {
                        Text("\($0.emoji) \($0.displayName)")
                    }
                }.onChange(of: selectedEnvironment) { environment in
                    environment.activate()
                }
                Text("Changing environment will kill the app immediately. You will need to manually launch it again.")
            }
        }
    }
}
```
