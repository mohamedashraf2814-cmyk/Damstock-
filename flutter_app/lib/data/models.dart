import 'package:flutter/material.dart';

class Tx {
  final String ar;
  final String en;
  const Tx(this.ar, this.en);
  String of(bool isAr) => isAr ? ar : en;
}

enum ListingKind { primary, resale, assignment }

enum PropertyType { apartment, villa, townhouse, twinhouse, duplex, penthouse, chalet, studio, office, clinic }

enum FinishType { core, semi, full, furnished }

enum ProjectStatus { launch, construction, delivered }

enum InquiryType { info, viewing, callback }

enum InquiryStatus { pending, confirmed, completed }

enum SortBy { newest, priceLow, priceHigh, areaHigh, pricePerMeter }

class Property {
  final String id;
  final Tx title;
  final PropertyType type;
  final ListingKind kind;
  final int price;
  final int area;
  final int beds;
  final int baths;
  final int? floor;
  final Tx location;
  final Tx city;
  final String? developerId;
  final String? projectId;
  final List<String> images;
  final Tx description;
  final List<String> amenities;
  final FinishType finish;
  final int deliveryYear;
  final bool isReady;

  final double x;
  final double y;
  final bool featured;
  final bool verified;
  final DateTime listedAt;
  final int? downPayment;
  final int? installmentYears;

  final int? paidAmount;
  final int? originalPrice;
  final String? sellerName;
  final bool negotiable;
  final bool pendingReview;

  Property({
    required this.id,
    required this.title,
    required this.type,
    required this.kind,
    required this.price,
    required this.area,
    required this.beds,
    required this.baths,
    this.floor,
    required this.location,
    required this.city,
    this.developerId,
    this.projectId,
    required this.images,
    required this.description,
    this.amenities = const [],
    required this.finish,
    required this.deliveryYear,
    required this.isReady,
    required this.x,
    required this.y,
    this.featured = false,
    this.verified = true,
    required this.listedAt,
    this.downPayment,
    this.installmentYears,
    this.paidAmount,
    this.originalPrice,
    this.sellerName,
    this.negotiable = false,
    this.pendingReview = false,
  });

  int get pricePerMeter => area == 0 ? 0 : (price / area).round();

  int? get monthly {
    final years = installmentYears;
    if (years == null || years == 0) return null;
    return ((price - (downPayment ?? 0)) / (years * 12)).round();
  }

  String get cover => images.isNotEmpty ? images.first : '';
}

class Developer {
  final String id;
  final Tx name;
  final String letter;
  final Tx tagline;
  final Tx about;
  final int founded;
  final int projectsCount;
  final int deliveredUnits;
  final double rating;
  final String cover;
  final Tx hq;
  final Color color;

  const Developer({
    required this.id,
    required this.name,
    required this.letter,
    required this.tagline,
    required this.about,
    required this.founded,
    required this.projectsCount,
    required this.deliveredUnits,
    required this.rating,
    required this.cover,
    required this.hq,
    required this.color,
  });
}

class Project {
  final String id;
  final Tx name;
  final String developerId;
  final Tx location;
  final Tx city;
  final List<String> images;
  final int startingPrice;
  final int minArea;
  final int maxArea;
  final int deliveryYear;
  final int downPaymentPct;
  final int installmentYears;
  final List<PropertyType> unitTypes;
  final List<String> amenities;
  final Tx description;
  final ProjectStatus status;
  final double progress;
  final double x;
  final double y;
  final int acres;
  final bool featured;

  const Project({
    required this.id,
    required this.name,
    required this.developerId,
    required this.location,
    required this.city,
    required this.images,
    required this.startingPrice,
    required this.minArea,
    required this.maxArea,
    required this.deliveryYear,
    required this.downPaymentPct,
    required this.installmentYears,
    required this.unitTypes,
    required this.amenities,
    required this.description,
    required this.status,
    required this.progress,
    required this.x,
    required this.y,
    required this.acres,
    this.featured = false,
  });

  String get cover => images.first;
}

class Inquiry {
  final String id;
  final InquiryType type;
  final String? propertyId;
  final String? projectId;
  final String? developerId;
  final String name;
  final String phone;
  final String message;
  final DateTime? viewingDate;
  final String? slot;
  final bool viaWhatsApp;
  final DateTime createdAt;
  final InquiryStatus status;

  const Inquiry({
    required this.id,
    required this.type,
    this.propertyId,
    this.projectId,
    this.developerId,
    required this.name,
    required this.phone,
    required this.message,
    this.viewingDate,
    this.slot,
    this.viaWhatsApp = false,
    required this.createdAt,
    this.status = InquiryStatus.pending,
  });
}

class UserProfile {
  final String name;
  final String phone;
  const UserProfile({required this.name, required this.phone});

  String get initial => name.trim().isEmpty ? 'D' : name.trim().characters.first.toUpperCase();
}
