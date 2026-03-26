// ignore: unused_import
import 'dart:math';

import 'package:flutter/material.dart';

import 'ui_constants.dart';

class Decorations {
  //! 3.3.1 Toujours utiliser final
  //? myBoxDecoration et disabledBoxDecoration sont des champs statiques non-final 
  static BoxDecoration myBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(UI.cornerRadius)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ],
  );

  static BoxDecoration disabledBoxDecoration = BoxDecoration(
    color: Colors.grey.shade200,
    borderRadius: const BorderRadius.all(Radius.circular(UI.cornerRadius)),
  );
}
