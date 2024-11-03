# Grade Management Application
This Flutter application provides an interface for managing student grades. Users can view, add, search, import, sort, and export student grades, with options for various sorting criteria and filtering by student ID or grade.

## Features
* __View Grades:__ View the list of student grades.
* __Add Grades:__ Add new grades with a form.
* __Search Grades:__ Search for grades by student ID or grade.
* __Sort Grades:__ Sort grades by student ID or grade (ascending/descending).
* __Import Grades:__ Import grades from a CSV file.
* __Export Grades:__ Export the list of grades to a PDF.
* __View Grade Frequencies:__ Visualize grade distributions with a bar chart.

## Libraries Used
* __Material Design Widgets:__ For building the UI.
* __File Picker:__ To import CSV files.
* __CSV Parser:__ To parse CSV data.
* __PDF:__ To generate PDF documents.
* __Charts:__ For visualizing grade distributions with bar charts.

## Screens and Components
1. __Home Screen (`ListGrades`)__

    * Displays the list of grades and provides options for sorting, searching, importing, exporting, and viewing grade distributions.
    * __Floating Action Button (FAB):__ Adds a new grade.

2. __Search Bar__

    * Filters grades in real-time based on user input, filtering by student ID or grade.

3. __Sorting Menu__

    * Sorts grades by student ID or grade in both ascending and descending order.

4. __Grade Chart__

    * Displays a frequency bar chart for grade distributions.

## Setup Instructions
#### Prerequisites
* __Flutter SDK:__ Make sure Flutter is installed and properly configured.

* __Dart:__ Ensure that Dart is also installed.

* __Dependencies:__ Make sure to add the required dependencies in your `pubspec.yaml` file:

```dart
dependencies:
  flutter:
    sdk: flutter
  charts_flutter: ^0.10.0
  file_picker: ^4.4.3
  csv: ^5.0.0
  pdf: ^3.8.1
  path_provider: ^2.0.14
```
### Installation
* __Clone this repository:__
    ```
    git clone https://github.com/karanjot-gaidu/grade_entry_system.git
    cd grade_entry_system
    ```
* __Install dependencies:__
    ```
    flutter pub get
    ```
* __Run the app:__
    ```
    flutter run
    ```

### Usage

* __Add Grade:__ Tap the FAB to open the grade form. Enter the student ID and grade, then save.
* __Edit Grade:__ Long-press on a grade to edit its details.
* __Delete Grade:__ Swipe a grade item to delete.
* __Sort Grades:__ Tap the sort icon on the AppBar and choose a sorting option.
* __Import Grades:__ Tap the import/export icon, choose a CSV file with student IDs and grades.
* __Export Grades to PDF:__ Tap the export PDF icon to save a PDF of grades in your device's Downloads folder.
* __View Grade Frequencies:__ Tap the bar chart icon on the AppBar to view grade frequencies in a bar chart.

## Example CSV File Format
The CSV file should be formatted as follows:
```
sid,grade
12345,A
67890,B
11223,C
```
## Folder Structure
* `main.dart`: Entry point of the application.
* `grades_model.dart`: Manages database operations for grades.
* `grade.dart`: Data model for a Grade.
* `grade_form.dart`: UI for adding or editing a grade.