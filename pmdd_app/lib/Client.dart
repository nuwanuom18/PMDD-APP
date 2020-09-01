class Client {
  final double temp;
  final double humidity;
  final double heartrate;
  final double name;
  Client({this.temp, this.heartrate, this.humidity, this.name});

  factory Client.formJson(Map<dynamic, dynamic> json) {
    double parser(dynamic source) {
      try {
        return double.parse(source.toString());
      } on FormatException {
        return -1;
      }
    }

    return Client(
        temp: parser(json['temp']),
        humidity: parser(json['humidity']),
        name: parser(json['name']),
        heartrate: parser(json['heartrate']));
  }
}
