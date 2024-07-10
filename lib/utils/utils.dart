import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

double radius = 20;
double padding = 3;

typedef StrMap = Map<String, dynamic>;
typedef SnapShot = QuerySnapshot<StrMap>;
typedef SnapShotFuture = Future<SnapShot>;
typedef DocSnapshot = QueryDocumentSnapshot<StrMap>;
typedef DocSnapshotFuture = Future<DocSnapshot>;
typedef Collection = CollectionReference<StrMap>;

void simpleSnackBar(BuildContext context, String s) => ScaffoldMessenger.of(context)
  ..clearSnackBars()
  ..showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text(s)));
