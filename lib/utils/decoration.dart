import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Decoration decoration = Decoration();

class Decoration {
  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;

  BorderRadius allBorderRadius(double radius) {
    return BorderRadius.all(Radius.circular(radius));
  }

  BorderRadius singleBorderRadius(List selectedSide, double radius) {
    List top = [1], right = [2], left = [3], bottom = [4];
    List topLR = [1, 2], topLBottomR = [1, 3], bottomLR = [3, 4], topRBottomR = [2, 4];
    List ignoreTopL = [2, 3, 4], ignoreTopR = [1, 3, 4];
    if (listEquals(selectedSide, top)) {
      selectedSide = [1, null, null, null];
    } else if (listEquals(selectedSide, right)) {
      selectedSide = [null, 2, null, null];
    } else if (listEquals(selectedSide, left)) {
      selectedSide = [null, null, 3, null];
    } else if (listEquals(selectedSide, bottom)) {
      selectedSide = [null, null, null, 4];
    } else if (listEquals(selectedSide, topLR)) {
      selectedSide = [1, 2, null, null];
    } else if (listEquals(selectedSide, bottomLR)) {
      selectedSide = [null, null, 3, 4];
    } else if (listEquals(selectedSide, topLBottomR)) {
      selectedSide = [1, null, 3, null];
    } else if (listEquals(selectedSide, topRBottomR)) {
      selectedSide = [null, 2, null, 4];
    } else if (listEquals(selectedSide, ignoreTopL)) {
      selectedSide = [null, 2, 3, 4];
    } else if (listEquals(selectedSide, ignoreTopR)) {
      selectedSide = [1, null, 3, 4];
    }
    return BorderRadius.only(
      topLeft: Radius.circular(selectedSide[0] != null ? radius : 0),
      topRight: Radius.circular(selectedSide[1] != null ? radius : 0),
      bottomLeft: Radius.circular(selectedSide[2] != null ? radius : 0),
      bottomRight: Radius.circular(selectedSide[3] != null ? radius : 0),
    );
  }
}
