enum Things {
  thing1,
  thing2,
  thing3,
  ;

  int get number {
    switch (this) {
      case Things.thing1:
        return 1;
      case Things.thing2:
        return 2;
      case Things.thing3:
        return 3;
    }
  }

  int get otherNnumber {
    switch (this) {
      case thing1:
        return 4;
      case thing2:
        return 5;
      case thing3:
        return 6;
    }
    throw Exception();
  }
}
