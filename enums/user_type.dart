enum UserType {meterReader, cashier, manager, diretor, admin}

extension on UserType {
  int get value {
    switch (this) {
      case UserType.meterReader:
        return 1;
      case UserType.cashier:
        return 2;
      case UserType.manager:
        return 3;
      case UserType.diretor:
        return 4;
      case UserType.admin:
        return 5;
    }
  }
}