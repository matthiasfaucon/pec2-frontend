import 'dart:convert';

import 'package:http/http.dart' as http;

class CreatorService {
  Future<List<String>> loadCountries() async {
    final response = await http.get(
      Uri.parse('https://restcountries.com/v3.1/all'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<String> countryNames =
      data.map((country) => country['name']['common'] as String).toList();
      if(countryNames.isNotEmpty){
        countryNames.sort();
      }
      return countryNames;
    }else{
      return [];
    }
  }
}
