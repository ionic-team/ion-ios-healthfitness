# IONHealthFitnessLib

`IONHealthFitnessLib` is a library built using `Swift` that provides a set of methods to access information and data from [Apple's HealthKit API](https://developer.apple.com/documentation/healthkit). The currently supported variable list is composed by the following:

- Health Variables
    - Heart Rate
    - Sleep
    - Blood Pressure
    - Blood Glucose
    - Oxygen Saturation
    - Body Temperature
- Fitness Variables
    - Steps
    - Calories Burned
    - Distance
    - Walking Speed
- Profile Variables
    - Weight
    - Height
    - Body Fat Percentage
    - Basal Metabolic Rate

## Index

- [Installation](#installation)
- [Usage](#usage)
- [Methods](#methods)
    - [Delete Background Jobs](#delete-background-jobs)
    - [List Background Jobs](#list-background-jobs)
    - [Count Background Jobs For Variable](#count-background-jobs-for-variable)
    - [Write Values to Variable](#write-values-to-variable)
    - [Get Last Record for Variable](#get-last-record-for-variable)
    - [Request Permissions](#request-permissions)
    - [Create Background Job for Variable](#create-background-job-for-variable)
    - [Perform Advanced Query](#perform-advanced-query)

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ionic-team/ion-ios-healthfitness.git", from: "1.0.0")
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'IONHealthFitnessLib', '~> 1.0.0'
```

Then run:

```bash
pod install
```

## Usage

Go to [Apple Developer Portal](https://developer.apple.com/) and configure the following:

1. Application Identifier. The capabilities `HealthKit` and `HealthKit Estimate Recalibration` need to be set on.
2. Certificate and Provisioning Profile. Both have to be related to the aforementioned Application Identifier.

## Methods

The library provides the following methods to interact with `HealthKit`:

### Delete Background Jobs

Removes the background job associated with the passed `id`. In case of any error occuring while deleting, the associated error is returned via the parameter `completion` closure.

```swift
func deleteBackgroundJobs(
    id: String?, 
    completion: @escaping(NSError?) -> Void
)
```

### List Background Jobs

Returns all the existing background jobs as a JSON object encoded as a `utf8 String`. If there isn't any job to return, an empty string is returned.

```swift
func listBackgroundJobs() -> String
``` 

### Count Background Jobs For Variable

Given the parameter `variable` name, the method returns the number of background jobs associated with it.

```swift
func countBackgroundJobsFor(
    variable: String
) -> Int 
```

### Write Values to Variable

Allows inserting new values into a specific `variable`. The `completion` closure indicates the success/error state of the task.

```swift
func writeData(
    variable: String, 
    value: Double, 
    completion: @escaping (Bool, NSError?) -> Void
)
```

### Get Last Record for Variable

Retrieves the last registered value for a specific `variable`. The `completion` closure indicates the success/error state of the task, along with the value itself in case of success.

```swift
func getLastRecord(
    variable: String, 
    mostRecent: Bool, 
    timeUnitLength: Int, 
    completion: @escaping (Bool, String?, NSError?) -> Void
)
```

### Request Permissions

The method allows the users to set the variables they want to request access to. Different access types can be requested: Read Only, Write Only, Read and Write. The `completion` closure indicates the success/error state of the task.

```swift
func requestPermissions(
    customPermissions: String, 
    variable: VariableStruct, 
    completion: @escaping (Bool, NSError?) -> Void
)
```

### Create Background Job for Variable

This method provides the creation of a background job to monitor a specific `variable`. The monitoring settings are all settable (time unit, notification frequency, ...) and when a `condition` and `value` is met, a notification can be triggered and displayed to the user. The `completion` closure indicates the success/error state of the task.

```swift
func setBackgroundJob(
    variable: String,
    timeUnit: (name: String, grouping: Int),
    notificationFrequency: (name: String, grouping: Int),
    jobFrequency: String,
    condition: String,
    value: Double,
    notificationText: (header: String, body: String),
    completion: @escaping(Bool, String?, NSError?) -> Void
)
```

### Update a Background Job set for a Variable

Provides a way to update key parameters for a specific background job, such as trigger condition and value, notification header, body and frequency. The `completion` closure indicates the success/error state of the task.

```swift
func updateBackgroundJob(
    id: Int64?,
    notificationFrequency: (name: String?, grouping: Int?),
    condition: String?,
    value: Double?,
    notificationText: (header: String?, body: String?),
    isActive: Bool?,
    completion: @escaping(Bool, NSError?) -> Void
)
```

### Perform Advanced Query

Lets the user set query parameters to retrieve a set of values for a specific `variable`. To do this, the user can set a variable type, a start and finish date, operation type and time unit (minutes, days, weeks, ...). The `completion` closure indicates the success/error state of the task. In case of success an `AdvancedQueryResponse` type object is returned as a `utf8 string` type. This `AdvancedQueryResponse` type is an alias for a JSON object that is composed of two types of data: `results` and `resultDataPoints`. The first corresponds to blocks with the raw data returned and the other is an accelerator that returns data ready to be consumed and displayed in a Chart.

```swift
func advancedQuery(
    variable: String,
    date: (start: Date, end: Date),
    timeUnit: String,
    operationType: String,
    mostRecent: Bool,
    onlyFilledBlocks: Bool,
    resultType: AdvancedQueryResultType,
    timeUnitLength: Int,
    completion: @escaping(Bool, String?, NSError?) -> Void
)
```

The following represents an example of the value returned in case of success:
```JSON
{
  "results": [
    { "block": 0, "values": [1, 2], "startDate": 0, "endDate": 99 },
    { "block": 1, "values": [3, 4], "startDate": 100, "endDate": 199 },
  ],
  "resultDataPoints": [
    { "Label": "some-label", "Value": 0 },
    { "Label": "some-label", "Value": 1 },
    { "Label": "some-label", "Value": 2 },
    { "Label": "some-label", "Value": 3 },
  ] 
}
```

### Perform Workouts Advanced Query

Lets the user set query parameters to retreive a set of values for specific Workout Type and Variables combinations. To do this, the user can set a start and finish date and a list containing a map between the workout types he/she wants to get and the variables' data associated to it. The following defaults values are considered:
- Empty map means that all workout types will be queried with Heart Rate and Active Energy Burned variables.
- An empty variable list for a workout type means that Heart Rate and Active Energy Burned variables will be used for that workout type.

The `completion` closure indicates the success/error state of the task. In case of success an `WorkoutAdvancedQueryResponse` type object is returned as a `utf8 string` type. This `WorkoutAdvancedQueryResponse` type is an alias for a JSON object that is composed by a `results` array, which relates to the blocks with the raw data returned.

```swift
func workoutAdvancedQuery(
    workoutTypeVariableDictionary: WorkoutTypeVariableDictionary,
    date: (start: Date, end: Date),
    completion: @escaping(Bool, String?, NSError?) -> Void
)
```

The following represents and example of the values returned in case of success:
```JSON
{
  "results" : [
    {
      "activity" : "Running",
      "duration" : 7200,
      "samples" : [
        {
          "values" : [
            10345
          ],
          "block" : 0,
          "startDate" : 1671604588,
          "endDate" : 1671611788,
          "additionalData" : "Step Count"
        }
      ],
      "startDate" : 1671604588,
      "endDate" : 1671611788,
      "totalDistance" : 15000.200000000001
    }
  ]
}
{
  "results" : [
    {
      "activity" : "Yoga",
      "samples" : [
        {
          "values" : [
            95
          ],
          "block" : 0,
          "startDate" : 1671712588,
          "endDate" : 1671716188,
          "additionalData" : "Heart Rate"
        }
      ],
      "startDate" : 1671712588,
      "endDate" : 1671716188,
      "totalEnergyBurned" : 234,
      "duration" : 3600
    },
    {
      "activity" : "Running",
      "samples" : [
        {
          "values" : [
            166
          ],
          "block" : 0,
          "startDate" : 1671604588,
          "endDate" : 1671611788,
          "additionalData" : "Heart Rate"
        }
      ],
      "startDate" : 1671604588,
      "endDate" : 1671611788,
      "totalEnergyBurned" : 925,
      "duration" : 7200
    },
    {
      "activity" : "Running",
      "samples" : [
        {
          "values" : [
            195
          ],
          "block" : 0,
          "startDate" : 1669157788,
          "endDate" : 1669159288,
          "additionalData" : "Heart Rate"
        }
      ],
      "startDate" : 1669156588,
      "endDate" : 1669160188,
      "duration" : 3600
    },
    {
      "activity" : "Cycling",
      "samples" : [
        {
          "values" : [
            166
          ],
          "block" : 0,
          "startDate" : 1658526988,
          "endDate" : 1658528488,
          "additionalData" : "Heart Rate"
        }
      ],
      "startDate" : 1658525788,
      "endDate" : 1658529388,
      "duration" : 3600
    }
  ]
}
```