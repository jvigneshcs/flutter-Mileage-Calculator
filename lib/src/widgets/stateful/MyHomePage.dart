import 'package:flutter/material.dart';
import '../../models/MileageCalculator.dart';
import '../../models/OdometerDigits.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _formKey = GlobalKey<FormState>();
  final _previousReadingController = TextEditingController();
  final _currentReadingController = TextEditingController();
  final _fuelRefilledController = TextEditingController();
  final _mileageCalculator = MileageCalculator();

  final _supportedDigits = [
    OdometerDigits(5, 'Five'),
    OdometerDigits(6, 'Six'),
    OdometerDigits(7, 'Seven'),
    OdometerDigits(8, 'Eight'),
    OdometerDigits(9, 'Nine'),
  ];

  OdometerDigits? _selectedDigit;
  int? _calculatedDistance;
  double? _calculatedMileage;

  List<DropdownMenuItem<OdometerDigits>> get _supportedItems => this._supportedDigits
        .map<DropdownMenuItem<OdometerDigits>>((OdometerDigits digits) {
      return DropdownMenuItem<OdometerDigits>(
        value: digits,
          child: Text(
              digits.text,
          ),
      );
    }).toList();
  bool get _isDigitSelected => this._selectedDigit != null;
  String get _calculatedText => 'Distance Travelled: ${this._calculatedDistance ?? ''}\nMileage: ${this._calculatedMileage ?? ''}';

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);
    final textTheme = Theme.of(context).textTheme;
    final crossAxisCount = this._crossAxisCount(mediaQuery);
    final itemWidth = mediaQuery.size.width / crossAxisCount;
    final itemHeight = 90;
    final ratio = itemWidth / itemHeight;
    final maxDigits = this._selectedDigit?.digits;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SafeArea(
          child: Form(
            key: this._formKey,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              crossAxisSpacing: 16,
              childAspectRatio: ratio,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  child: DropdownButton(
                    isExpanded: true,
                    hint: Text(
                        'Number of digits in the Odometer'
                    ),
                    items: this._supportedItems,
                    onChanged: this._onChangeDigitSelection,
                    value: this._selectedDigit,
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: TextFormField(
                    controller: this._previousReadingController,
                    decoration: InputDecoration(
                      labelText: 'Previous Reading',
                    ),
                    enabled: this._isDigitSelected,
                    keyboardType: TextInputType.number,
                    maxLength: maxDigits,
                    validator: this._readingTextValidation,
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: TextFormField(
                    controller: this._currentReadingController,
                    decoration: InputDecoration(
                      labelText: 'Current Reading',
                    ),
                    enabled: this._isDigitSelected,
                    keyboardType: TextInputType.number,
                    maxLength: maxDigits,
                    validator: this._readingTextValidation,
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: TextFormField(
                    controller: this._fuelRefilledController,
                    decoration: InputDecoration(
                      labelText: 'Fuel Refilled',
                    ),
                    enabled: this._isDigitSelected,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: this._refillTextValidation,
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    this._calculatedText,
                    style: textTheme.headline6,
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    child: Text(
                      'Calculate',
                    ),
                    onPressed: this._isDigitSelected ? this._onTapCalculate : null,
                  ),
                )
              ],
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: this._onTapClearAll,
        tooltip: 'Clear All',
        child: Icon(Icons.clear_all_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  int _crossAxisCount(MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final orientation = mediaQuery.orientation;
    final widthCutOff = 600;

    if (orientation == Orientation.portrait) {
      return (size.shortestSide >= widthCutOff) ? 2 : 1;
    } else {
      return (size.longestSide < widthCutOff) ? 1 : 2;
    }
  }

  _onChangeDigitSelection(OdometerDigits? digits) {
    this.setState(() {
      this._selectedDigit = digits;
    });
  }

  String? _readingTextValidation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the reading';
    } else if (int.tryParse(value) == null) {
      return 'Please enter valid reading';
    } else {
      return null;
    }
  }

  String? _refillTextValidation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the fuel refilled quantity';
    }
    final refill = double.tryParse(value);
    if (refill == null || refill <= 0) {
      return 'Please enter valid fuel refill quantity';
    } else {
      return null;
    }
  }

  _onTapCalculate() {
    int? distance;
    double? mileage;
    if (this._formKey.currentState!.validate()) {
      final previousReading = int.tryParse(this._previousReadingController.text);
      final currentReading = int.tryParse(this._currentReadingController.text);
      final refill = double.tryParse(this._fuelRefilledController.text);
      final values = this._mileageCalculator.calculate(this._selectedDigit!, previousReading!, currentReading!, refill!);

      distance = values.item1;
      mileage = values.item2;
    }

    this.setState(() {
      this._calculatedDistance = distance;
      this._calculatedMileage = mileage;
    });
  }

  _onTapClearAll() {
    this.setState(() {
      this._previousReadingController.clear();
      this._currentReadingController.clear();
      this._fuelRefilledController.clear();
    });
  }
}