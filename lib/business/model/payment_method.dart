class PaymentMethod {
  final String name;
  final String image;

  PaymentMethod(this.name, this.image);

  static getPaymentMethods() {
    return [
      PaymentMethod("**** 8295", "assets/images/ic_master.png"),
      PaymentMethod("**** 3704", "assets/images/ic_visa.png"),
      PaymentMethod("Cash", "assets/images/ic_cash.png"),
    ];
  }
}
