class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String date;
  final String time;
  final String location;
  final double price;
  final int availableSeats;
  final int totalSeats;
  final String organizerId;
  final String organizerName;
  final String image;
  final bool featured;
  final List<String> tags;
  final DateTime? createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.availableSeats,
    required this.totalSeats,
    this.organizerId = '',
    this.organizerName = '',
    this.image = '',
    this.featured = false,
    this.tags = const [],
    this.createdAt,
  });

  bool get isSoldOut => availableSeats <= 0;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 0,
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 0,
      organizerId: json['organizerId'] as String? ?? '',
      organizerName: json['organizerName'] as String? ?? '',
      image: json['image'] as String? ?? '',
      featured: json['featured'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'date': date,
      'time': time,
      'location': location,
      'price': price,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'image': image,
      'featured': featured,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? date,
    String? time,
    String? location,
    double? price,
    int? availableSeats,
    int? totalSeats,
    String? organizerId,
    String? organizerName,
    String? image,
    bool? featured,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      price: price ?? this.price,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      image: image ?? this.image,
      featured: featured ?? this.featured,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
