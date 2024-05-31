import 'dart:ffi';

class BusinessInfo{
  final String? name;
  final String? phone;
  final String? priceRange;
  final Bool? status;
  final String? businessLink;
  final String? category;
  final String? address;
  BusinessInfo({this.name,this.phone, this.priceRange, this.status, this.businessLink, this.category, this.address});

  factory BusinessInfo
      .fromJson(Map<String, dynamic> json){
    return BusinessInfo(
      name: json['name'],
      priceRange:json["price"],
      phone: json["phone"],
      status: json["is_closed"],
      businessLink: json["url"],
      category: json["categories"][1]["title"],
      address: json["location"]["display_address"],
    );
  }
}