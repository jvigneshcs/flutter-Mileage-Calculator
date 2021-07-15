import 'dart:math';

import 'OdometerDigits.dart';
import 'package:tuple/tuple.dart';

class MileageCalculator {

  Tuple2<int, double> calculate(OdometerDigits digits, int previousReading, int currentReading, double refill) {
    if (refill <= 0) {
      return Tuple2(0, 0);
    }
    final int maxReading = pow(10, digits.digits).toInt() - 1;
    int distance = 0;
    if (currentReading > previousReading) {
      distance = currentReading - previousReading;
    } else {
      distance = (maxReading - previousReading) + currentReading;
    }

    return Tuple2(distance, distance / refill);
  }
}