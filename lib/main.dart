// ========================================
// HSA APP - CHUNK 1 OF 7 (FULLY FIXED)
// Main Setup, Imports, Data Models, Theme Provider
// ========================================

// ✅ ALL IMPORTS MUST BE AT THE TOP OF THE FILE
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

// ✅ CHUNK 2 IMPORTS (ADDED HERE, NOT IN CHUNK 2)
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// ========================================
// GLOBAL USER DATA
// ========================================
String userEmail = 'user@example.com';
String userName = 'Guest User';
String userAddress = 'Not set';
String userMobile = '';
String userGender = 'Not specified';

// ========================================
// DATA MODELS (ENHANCED & FIXED)
// ========================================

class BookingModel {
  final String serviceName;
  final String price;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String timeSlot;
  final String date;
  final String bookingId;
  final String status;
  final String userId;
  final DateTime createdAt;

  BookingModel({
    required this.serviceName,
    required this.price,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.timeSlot,
    required this.date,
    required this.bookingId,
    required this.status,
    required this.userId,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      serviceName: json['service_name'] as String? ?? 'Unknown',
      price: json['price'] as String? ?? 'Rs.0',
      name: json['name'] as String? ?? 'N/A',
      email: json['user_email'] as String? ?? 'N/A',
      phone: json['phone'] as String? ?? 'N/A',
      address: json['address'] as String? ?? 'N/A',
      timeSlot: json['time_slot'] as String? ?? 'N/A',
      date: json['date'] as String? ?? DateFormat('dd MMM yyyy').format(DateTime.now()),
      bookingId: json['booking_id'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'Pending',
      userId: json['user_id'] as String? ?? 'N/A',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class TimeSlotModel {
  final String timeSlot;
  final int availableCount;

  TimeSlotModel({
    required this.timeSlot,
    required this.availableCount,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      timeSlot: json['time_slot'] as String,
      availableCount: (json['available_count'] as int?) ?? 0,
    );
  }
}

class AdminModel {
  final String id;
  final String email;
  final String name;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? 'Admin',
    );
  }
}

// ✅ FIXED: Service Model with proper image validation
class ServiceModel {
  final String id;
  final String name;
  final String price;
  final String rating;
  final String category;
  final String imageUrl;
  final String iconName;
  final String colorHex;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.category,
    required this.imageUrl,
    required this.iconName,
    required this.colorHex,
    required this.isActive,
  });

  // ✅ FIXED: Better URL validation
  bool get isValidImageUrl {
    if (imageUrl.isEmpty) return false;
    try {
      final uri = Uri.parse(imageUrl);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  IconData get icon {
    switch (iconName) {
      case 'cleaning_services':
        return Icons.cleaning_services_rounded;
      case 'bathroom':
        return Icons.bathroom_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'content_cut':
        return Icons.content_cut_rounded;
      case 'kitchen':
        return Icons.kitchen_rounded;
      case 'ac_unit':
        return Icons.ac_unit_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical_services':
        return Icons.electrical_services_rounded;
      case 'format_paint':
        return Icons.format_paint_rounded;
      case 'carpenter':
        return Icons.carpenter_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'face_retouching_natural':
        return Icons.face_retouching_natural_rounded;
      case 'face':
        return Icons.face_rounded;
      case 'colorize':
        return Icons.colorize_rounded;
      case 'shower':
        return Icons.shower_rounded;
      case 'checkroom':
        return Icons.checkroom_rounded;
      default:
        return Icons.home_repair_service_rounded;
    }
  }

  Color get color {
    try {
      return Color(int.parse('FF$colorHex', radix: 16));
    } catch (e) {
      return const Color(0xFF2196F3); // Default blue
    }
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as String,
      rating: json['rating'] as String? ?? '4.5',
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      iconName: json['icon_name'] as String? ?? 'home_repair_service',
      colorHex: json['color_hex'] as String? ?? '2196F3',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'rating': rating,
      'category': category,
      'image_url': imageUrl,
      'icon_name': iconName,
      'color_hex': colorHex,
      'is_active': isActive,
    };
  }
}

// ========================================
// ✅ FIXED THEME PROVIDER
// ========================================

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  // Modern Color Palette
  static const primaryBlue = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF1976D2);
  static const accentOrange = Color(0xFFFF9800);
  static const successGreen = Color(0xFF4CAF50);
  static const warningAmber = Color(0xFFFFC107);
  static const errorRed = Color(0xFFF44336);
  
  // Background Colors
  static const lightBg = Color(0xFFF5F5F5);
  static const darkBg = Color(0xFF121212);
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textLight = Colors.white;
  static const textDark = Color(0xFFE0E0E0);
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  // ✅ FIXED: Proper theme toggle
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
  
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightBg,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    cardColor: cardLight,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentOrange,
      surface: cardLight,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
  
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkBg,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    cardColor: cardDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentOrange,
      surface: cardDark,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardDark,
      foregroundColor: textLight,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

// ========================================
// MAIN APP ENTRY POINT
// ========================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = "https://kzbkqiwnvbwfcumvewsa.supabase.co";
  const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6YmtxaXdudmJ3ZmN1bXZld3NhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0ODg0MzIsImV4cCI6MjA3NjA2NDQzMn0.Ge-tl6qCHIuuZnPYQnUg_JO51dFk8PizwwNIE6p4ZgI";

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BookingManager()),
      ],
      child: const HSAApp(),
    ),
  );
}

// ========================================
// ROOT APP WIDGET
// ========================================

class HSAApp extends StatelessWidget {
  const HSAApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'HSA - Home Services',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(themeProvider: themeProvider),
    );
  }
}

// ========================================
// END OF CHUNK 1 (WITH ALL IMPORTS)
// ========================================

/*
 * ✅ CRITICAL FIX:
 * - ALL imports moved to the top of the file
 * - Chunk 2 imports (dart:io, image_picker, permission_handler) 
 *   are now included here
 * - This fixes the "Directives must appear before any declarations" error
 * 
 * 📝 IMPORTANT:
 * - DO NOT add any imports in Chunk 2
 * - All imports are now in this Chunk 1
 * - Chunk 2 should start directly with the ImageUploadHelper class
 */
// ========================================
// HSA APP - CHUNK 2 OF 7 (FULLY FIXED)
// Booking Manager + Image Upload Helper
// ========================================

// NOTE: All imports are in Chunk 1 - DO NOT add imports here!

// ========================================
// IMAGE UPLOAD HELPER CLASS
// ========================================

class ImageUploadHelper {
  static final _supabase = Supabase.instance.client;
  static final _picker = ImagePicker();

  // Request storage permissions
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        final photos = await Permission.photos.request();
        return photos.isGranted;
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  // Show image source selection dialog
  static Future<File?> pickImage(BuildContext context) async {
    final hasPermission = await requestPermissions();
    
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to upload images'),
            backgroundColor: ThemeProvider.errorRed,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return null;
    }

    return await showDialog<File?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Select Image Source',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeProvider.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeProvider.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: ThemeProvider.primaryBlue,
                ),
              ),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );
                if (image != null && context.mounted) {
                  Navigator.pop(context, File(image.path));
                }
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeProvider.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: ThemeProvider.accentOrange,
                ),
              ),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );
                if (image != null && context.mounted) {
                  Navigator.pop(context, File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Upload image to Supabase Storage
  static Future<String?> uploadToSupabase(
    File imageFile,
    BuildContext context,
  ) async {
    try {
      final fileName = 'service_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = fileName;

      // Upload to Supabase Storage
      await _supabase.storage.from('service-images').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      // Get public URL
      final publicUrl = _supabase.storage
          .from('service-images')
          .getPublicUrl(filePath);

      print('✅ Image uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
      return null;
    }
  }
}

// ========================================
// BOOKING MANAGER - ENHANCED STATE MANAGEMENT
// ========================================

class BookingManager extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  // User Bookings State
  List<BookingModel> userBookings = [];
  RealtimeChannel? _userBookingChannel;

  // Admin Bookings State
  List<BookingModel> adminBookings = [];
  RealtimeChannel? _adminBookingChannel;

  // Time Slots State
  List<TimeSlotModel> availableTimeSlots = [];
  RealtimeChannel? _slotChannel;

  // Admin Authentication State
  AdminModel? currentAdmin;
  bool isAdminAuthenticated = false;

  // Daily Bookings for Chart
  Map<DateTime, int> dailyBookingStats = {};
  
  // Services State
  List<ServiceModel> allServices = [];
  List<ServiceModel> get activeServices => 
      allServices.where((s) => s.isActive).toList();
  List<ServiceModel> get disabledServices => 
      allServices.where((s) => !s.isActive).toList();
  
  RealtimeChannel? _servicesChannel;

  // 24-Hour Auto Reset Timers
  Timer? _midnightResetTimer;
  Timer? _slotCheckTimer;

  BookingManager() {
    _initializeTimeSlots();
    _setupRealtimeSlots();
    _setupRealtimeAdminBookings();
    _setupRealtimeServices();
    _schedule24HourSlotReset();
    _checkAndResetSlotsIfNeeded();
    _fetchInitialServices();
    
    if (_supabase.auth.currentUser != null) {
      _fetchInitialUserBookings();
      _setupRealtimeUserBookings();
    }
  }
  
  // ========================================
  // 24-HOUR AUTO SLOT RESET (20 SLOTS)
  // ========================================

  Future<void> _checkAndResetSlotsIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetTimestamp = prefs.getInt('lastSlotReset') ?? 0;
      final lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);
      final now = DateTime.now();
      
      final hoursSinceReset = now.difference(lastResetDate).inHours;
      
      if (hoursSinceReset >= 24 || lastResetTimestamp == 0) {
        print('⏰ Resetting all slots to 20...');
        await _resetAllSlotsToTwenty();
        await prefs.setInt('lastSlotReset', now.millisecondsSinceEpoch);
      }
    } catch (e) {
      print('❌ Error checking slot reset: $e');
    }
  }

  void _schedule24HourSlotReset() {
    _slotCheckTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await _checkAndResetSlotsIfNeeded();
    });
    _scheduleMidnightReset();
  }

  void _scheduleMidnightReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _midnightResetTimer = Timer(durationUntilMidnight, () async {
      await _resetAllSlotsToTwenty();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastSlotReset', DateTime.now().millisecondsSinceEpoch);
      _scheduleMidnightReset();
    });
  }

  Future<void> _resetAllSlotsToTwenty() async {
    try {
      await _supabase.from('time_slots').update({
        'available_count': 20,
        'last_reset': DateTime.now().toIso8601String(),
      }).neq('time_slot', '');
      await _fetchInitialTimeSlots();
      print('✅ All slots reset to 20');
    } catch (e) {
      print('❌ Error resetting slots: $e');
    }
  }

  Future<void> manualResetSlots() async {
    await _resetAllSlotsToTwenty();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSlotReset', DateTime.now().millisecondsSinceEpoch);
  }

  // ========================================
  // TIME SLOT MANAGEMENT (20 SLOTS)
  // ========================================

  Future<void> _initializeTimeSlots() async {
    try {
      await _fetchInitialTimeSlots();
      
      if (availableTimeSlots.isEmpty) {
        await _createDefaultTimeSlots();
      }
    } catch (e) {
      print('❌ Error initializing time slots: $e');
    }
  }

  Future<void> _createDefaultTimeSlots() async {
    try {
      final defaultSlots = [
        {'time_slot': '9:00 AM - 11:00 AM', 'available_count': 20},
        {'time_slot': '11:00 AM - 1:00 PM', 'available_count': 20},
        {'time_slot': '2:00 PM - 4:00 PM', 'available_count': 20},
        {'time_slot': '4:00 PM - 6:00 PM', 'available_count': 20},
      ];

      for (var slot in defaultSlots) {
        await _supabase.from('time_slots').upsert(slot, onConflict: 'time_slot');
      }

      await _fetchInitialTimeSlots();
    } catch (e) {
      print('❌ Error creating default slots: $e');
    }
  }

  Future<void> _fetchInitialTimeSlots() async {
    try {
      final response = await _supabase
          .from('time_slots')
          .select('*')
          .order('time_slot', ascending: true);
      
      availableTimeSlots = (response as List)
          .map((e) => TimeSlotModel.fromJson(e))
          .toList();
      
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching time slots: $e');
    }
  }

  void _setupRealtimeSlots() {
    _slotChannel?.unsubscribe();
    
    _slotChannel = _supabase.channel('public:time_slots');
    
    _slotChannel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'time_slots',
      callback: (payload) {
        _fetchInitialTimeSlots();
      },
    ).subscribe();
  }

  Future<bool> decrementSlotCount(String slotName) async {
    try {
      final currentSlot = availableTimeSlots.firstWhere(
        (s) => s.timeSlot == slotName,
        orElse: () => TimeSlotModel(timeSlot: slotName, availableCount: 0),
      );
      
      final newCount = currentSlot.availableCount - 1;
      if (newCount < 0) return false;

      await _supabase.from('time_slots').update({
        'available_count': newCount,
      }).eq('time_slot', slotName);

      return true;
    } catch (e) {
      print('❌ Error decrementing slot: $e');
      return false;
    }
  }

  Future<void> incrementSlotCount(String slotName) async {
    try {
      final currentSlot = availableTimeSlots.firstWhere(
        (s) => s.timeSlot == slotName,
        orElse: () => TimeSlotModel(timeSlot: slotName, availableCount: 0),
      );
      
      final newCount = currentSlot.availableCount + 1;
      if (newCount > 20) return;

      await _supabase.from('time_slots').update({
        'available_count': newCount,
      }).eq('time_slot', slotName);
    } catch (e) {
      print('❌ Error incrementing slot: $e');
    }
  }

  // ========================================
  // SERVICES MANAGEMENT
  // ========================================

  Future<void> _fetchInitialServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select('*')
          .order('category', ascending: true);
      
      allServices = (response as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
      
      print('📊 Fetched ${allServices.length} services (${activeServices.length} active, ${disabledServices.length} disabled)');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching services: $e');
    }
  }

  Future<void> fetchAllServicesAdmin() async {
    await _fetchInitialServices();
  }

  void _setupRealtimeServices() {
    _servicesChannel?.unsubscribe();
    
    _servicesChannel = _supabase.channel('public:services');
    
    _servicesChannel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'services',
      callback: (payload) {
        _fetchInitialServices();
      },
    ).subscribe();
  }

  Future<bool> toggleServiceStatus(String serviceId, bool newStatus) async {
    try {
      await _supabase.from('services').update({
        'is_active': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', serviceId);

      print('✅ Service status updated: $serviceId -> ${newStatus ? "Active" : "Disabled"}');
      await _fetchInitialServices();
      return true;
    } catch (e) {
      print('❌ Error toggling service status: $e');
      return false;
    }
  }

  Future<bool> addNewService({
    required String name,
    required String price,
    required String category,
    required String imageUrl,
    required String iconName,
    required String colorHex,
  }) async {
    try {
      final uri = Uri.tryParse(imageUrl);
      if (uri == null || !uri.hasScheme || 
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        print('❌ Invalid image URL: $imageUrl');
        return false;
      }

      await _supabase.from('services').insert({
        'name': name,
        'price': price,
        'rating': '4.5',
        'category': category,
        'image_url': imageUrl,
        'icon_name': iconName,
        'color_hex': colorHex,
        'is_active': true,
      });

      print('✅ New service added: $name');
      await _fetchInitialServices();
      return true;
    } catch (e) {
      print('❌ Error adding service: $e');
      return false;
    }
  }

  Future<bool> updateService({
    required String serviceId,
    required String name,
    required String price,
    required String category,
    required String imageUrl,
    required String iconName,
    required String colorHex,
  }) async {
    try {
      final uri = Uri.tryParse(imageUrl);
      if (uri == null || !uri.hasScheme || 
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        print('❌ Invalid image URL: $imageUrl');
        return false;
      }

      await _supabase.from('services').update({
        'name': name,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        'icon_name': iconName,
        'color_hex': colorHex,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', serviceId);

      print('✅ Service updated: $serviceId');
      await _fetchInitialServices();
      return true;
    } catch (e) {
      print('❌ Error updating service: $e');
      return false;
    }
  }

  Future<bool> disableService(String serviceId) async {
    return await toggleServiceStatus(serviceId, false);
  }

  // ========================================
  // PROFILE UPDATE
  // ========================================

  Future<bool> updateUserProfile({
    required String name,
    required String mobileNumber,
    required String gender,
    required String address,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('profiles').update({
        'name': name,
        'mobile_number': mobileNumber,
        'gender': gender,
        'address': address,
      }).eq('id', user.id);

      userName = name;
      userMobile = mobileNumber;
      userGender = gender;
      userAddress = address;

      print('✅ Profile updated: $name');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }

  // ========================================
  // ADMIN AUTHENTICATION
  // ========================================

  Future<bool> authenticateAdmin(String email, String password) async {
    try {
      final response = await _supabase
          .from('admins')
          .select('*')
          .eq('email', email)
          .limit(1)
          .maybeSingle();

      if (response == null) return false;

      final storedPassword = response['password_hash'] as String;
      
      if (storedPassword == password) {
        currentAdmin = AdminModel.fromJson(response);
        isAdminAuthenticated = true;
        
        await fetchAllAdminBookings();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Admin authentication error: $e');
      return false;
    }
  }

  void logoutAdmin() {
    currentAdmin = null;
    isAdminAuthenticated = false;
    adminBookings.clear();
    dailyBookingStats.clear();
    notifyListeners();
  }

  // ========================================
  // USER BOOKING MANAGEMENT
  // ========================================

  Future<void> _fetchInitialUserBookings() async {
    final userEmailFilter = _supabase.auth.currentUser?.email;
    if (userEmailFilter == null) return;

    try {
      final response = await _supabase
          .from('bookings')
          .select('*')
          .eq('user_email', userEmailFilter)
          .order('created_at', ascending: false);

      userBookings = (response as List)
          .map((e) => BookingModel.fromJson(e))
          .toList();
      
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching user bookings: $e');
    }
  }

  void _setupRealtimeUserBookings() {
    final userEmailFilter = _supabase.auth.currentUser?.email;
    if (userEmailFilter == null) return;
    
    _userBookingChannel?.unsubscribe();
    _userBookingChannel = _supabase.channel('user_bookings_$userEmailFilter');

    _userBookingChannel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'bookings',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_email',
        value: userEmailFilter,
      ),
      callback: (payload) {
        _fetchInitialUserBookings();
      },
    ).subscribe();
  }

  void initializeUserBookings() {
    _fetchInitialUserBookings();
    _setupRealtimeUserBookings();
  }

  // ========================================
  // ADMIN BOOKING MANAGEMENT
  // ========================================

  Future<void> fetchAllAdminBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*')
          .order('created_at', ascending: false);

      adminBookings = (response as List)
          .map((e) => BookingModel.fromJson(e))
          .toList();
      
      _calculateDailyStats();
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching admin bookings: $e');
    }
  }
  
  void _setupRealtimeAdminBookings() {
    _adminBookingChannel?.unsubscribe();
    _adminBookingChannel = _supabase.channel('admin_bookings_all');

    _adminBookingChannel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'bookings',
      callback: (payload) {
        if (isAdminAuthenticated) {
          fetchAllAdminBookings();
        }
      },
    ).subscribe();
  }

  void _calculateDailyStats() {
    dailyBookingStats.clear();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      dailyBookingStats[date] = 0;
    }
    
    for (var booking in adminBookings) {
      final bookingDate = DateTime(
        booking.createdAt.year,
        booking.createdAt.month,
        booking.createdAt.day,
      );
      
      if (dailyBookingStats.containsKey(bookingDate)) {
        dailyBookingStats[bookingDate] = dailyBookingStats[bookingDate]! + 1;
      }
    }
  }

  int getTodayBookingCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return adminBookings.where((booking) {
      final bookingDate = DateTime(
        booking.createdAt.year,
        booking.createdAt.month,
        booking.createdAt.day,
      );
      return bookingDate == today;
    }).length;
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _supabase.from('bookings').update({
        'status': newStatus,
      }).eq('booking_id', bookingId);
    } catch (e) {
      print('❌ Error updating booking status: $e');
    }
  }

  // ========================================
  // CREATE NEW BOOKING (✅ FIXED)
  // ========================================

  Future<bool> createBooking({
    required String serviceName,
    required String price,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String timeSlot,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      // ✅ FIXED: Use timeSlot parameter, not slotName
      final currentSlot = availableTimeSlots.firstWhere(
        (s) => s.timeSlot == timeSlot,
        orElse: () => TimeSlotModel(timeSlot: timeSlot, availableCount: 0),
      );

      if (currentSlot.availableCount <= 0) return false;

      final slotUpdated = await decrementSlotCount(timeSlot);
      if (!slotUpdated) return false;

      final bookingId = 'HSA-${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}';
      final bookingDate = DateFormat('dd MMM yyyy').format(DateTime.now());

      await _supabase.from('bookings').insert({
        'booking_id': bookingId,
        'user_id': user.id,
        'user_email': email,
        'service_name': serviceName,
        'price': price,
        'time_slot': timeSlot,
        'date': bookingDate,
        'status': 'Pending',
        'name': name,
        'phone': phone,
        'address': address,
      });

      return true;
    } catch (e) {
      print('❌ Error creating booking: $e');
      await incrementSlotCount(timeSlot);
      return false;
    }
  }

  // ========================================
  // CLEANUP
  // ========================================

  @override
  void dispose() {
    _slotChannel?.unsubscribe();
    _userBookingChannel?.unsubscribe();
    _adminBookingChannel?.unsubscribe();
    _servicesChannel?.unsubscribe();
    _midnightResetTimer?.cancel();
    _slotCheckTimer?.cancel();
    super.dispose();
  }
}

// ========================================
// END OF CHUNK 2 (NO IMPORTS - FIXED)
// ========================================

/*
 * ✅ KEY FIXES IN THIS VERSION:
 * 
 * 1. Fixed orElse parameter in createBooking:
 *    - Changed: orElse: () => TimeSlotModel(timeSlot: slotName, ...)
 *    - To: orElse: () => TimeSlotModel(timeSlot: timeSlot, ...)
 * 
 * 2. Image Upload Helper fully integrated
 * 3. All async operations properly handled
 * 4. Realtime subscriptions setup correctly
 * 5. 24-hour slot reset (20 slots) working
 * 6. Profile update functionality
 * 7. Service management (add/edit/disable)
 * 
 * 📝 USAGE:
 * - Replace your current Chunk 2 with this version
 * - Ensure dependencies are added to pubspec.yaml:
 *   - image_picker: ^1.0.7
 *   - permission_handler: ^11.3.0
 * 
 * ✅ ALL ERRORS FIXED!
 */


// ========================================
// HSA APP - CHUNK 3 OF 7 (FULLY FIXED)
// Splash Screen, Login Selection & Authentication
// ========================================

// Add this to your main.dart file after Chunk 2

// ========================================
// SPLASH SCREEN WITH MODERN ANIMATION
// ========================================

class SplashScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const SplashScreen({super.key, required this.themeProvider});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginSelectionPage(themeProvider: widget.themeProvider),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ThemeProvider.primaryBlue.withOpacity(0.1),
              Colors.white,
              ThemeProvider.accentOrange.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeProvider.primaryBlue.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_repair_service_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                const Text(
                  'HSA',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: ThemeProvider.primaryBlue,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ThemeProvider.primaryBlue.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Home Services at Your Doorstep',
                    style: TextStyle(
                      fontSize: 15,
                      color: ThemeProvider.textSecondary,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeProvider.primaryBlue.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// LOGIN SELECTION PAGE WITH MODERN UI
// ========================================

class LoginSelectionPage extends StatelessWidget {
  final ThemeProvider themeProvider;
  
  const LoginSelectionPage({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeProvider.primaryBlue.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: ThemeProvider.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ThemeProvider.primaryBlue.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_repair_service_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 35),
                
                const Text(
                  'Welcome to HSA!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeProvider.primaryBlue,
                  ),
                ),
                const SizedBox(height: 10),
                
                const Text(
                  'Choose how you want to continue',
                  style: TextStyle(
                    fontSize: 15,
                    color: ThemeProvider.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
                
                _buildModernButton(
                  context,
                  'User Login',
                  Icons.person_rounded,
                  ThemeProvider.primaryBlue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserLoginPage(themeProvider: themeProvider),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildModernButton(
                  context,
                  'Admin Login',
                  Icons.admin_panel_settings_rounded,
                  ThemeProvider.accentOrange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginPage(),
                    ),
                  ),
                  isOutlined: true,
                ),
                const SizedBox(height: 50),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: ThemeProvider.successGreen,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Trusted by 10,000+ customers',
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeProvider.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isOutlined ? color : Colors.white,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isOutlined ? color : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// USER LOGIN PAGE
// ========================================

class UserLoginPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const UserLoginPage({super.key, required this.themeProvider});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: ThemeProvider.errorRed,
        ),
      );
      return;
    }
    
    setState(() { _isLoading = true; });

    try {
      final supabase = Supabase.instance.client;

      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user != null) {
        final List<dynamic> userData = await supabase
            .from('profiles')
            .select('name, address, mobile_number, gender')
            .eq('email', user.email!)
            .limit(1);

        if (userData.isNotEmpty) {
          userName = userData[0]['name'] as String? ?? 'User';
          userEmail = user.email!;
          userAddress = userData[0]['address'] as String? ?? 'Not set';
          userMobile = userData[0]['mobile_number'] as String? ?? '';
          userGender = userData[0]['gender'] as String? ?? 'Not specified';
          
          print('✅ User logged in: $userName');
        } else {
          final defaultName = user.email!.split('@')[0];
          
          try {
            await supabase.from('profiles').insert({
              'id': user.id,
              'email': user.email,
              'name': defaultName,
              'mobile_number': '',
              'gender': 'Not specified',
              'address': 'Not set',
            });
            
            userName = defaultName;
            userEmail = user.email!;
            userAddress = 'Not set';
            userMobile = '';
            userGender = 'Not specified';
          } catch (e) {
            userName = defaultName;
            userEmail = user.email!;
            userAddress = 'Not set';
            userMobile = '';
            userGender = 'Not specified';
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, $userName!'),
              backgroundColor: ThemeProvider.successGreen,
            ),
          );
          
          Provider.of<BookingManager>(context, listen: false).initializeUserBookings();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(themeProvider: widget.themeProvider),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.message}'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeProvider.primaryBlue.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: ThemeProvider.primaryBlue, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeProvider.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to your HSA account',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeProvider.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                
                _buildModernTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                _buildModernTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: ThemeProvider.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 40),
                
                _buildModernButton('Login', _isLoading ? null : _login),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: ThemeProvider.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserSignupPage(themeProvider: widget.themeProvider),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: ThemeProvider.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: ThemeProvider.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: ThemeProvider.textSecondary.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: ThemeProvider.primaryBlue, size: 22),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeProvider.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: ThemeProvider.primaryBlue.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

// ========================================
// USER SIGNUP PAGE
// ========================================

class UserSignupPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const UserSignupPage({super.key, required this.themeProvider});

  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _genderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields'),
          backgroundColor: ThemeProvider.errorRed,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final supabase = Supabase.instance.client;

      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user != null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'name': _nameController.text.trim(),
          'mobile_number': _phoneController.text.trim(),
          'gender': _genderController.text.trim(),
          'address': _addressController.text.trim().isEmpty
              ? 'Not set'
              : _addressController.text.trim(),
        });

        userName = _nameController.text.trim();
        userEmail = user.email!;
        userAddress = _addressController.text.trim().isEmpty
            ? 'Not set'
            : _addressController.text.trim();
        userMobile = _phoneController.text.trim();
        userGender = _genderController.text.trim();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, $userName! Account created successfully.'),
              backgroundColor: ThemeProvider.successGreen,
            ),
          );

          Provider.of<BookingManager>(context, listen: false).initializeUserBookings();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(themeProvider: widget.themeProvider),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: ${e.message}'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeProvider.primaryBlue.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: ThemeProvider.primaryBlue, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeProvider.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to start booking services',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeProvider.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 35),
                
                _buildModernTextField(
                  controller: _nameController,
                  label: 'Full Name *',
                  hint: 'Enter your full name',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 20),
                
                _buildModernTextField(
                  controller: _phoneController,
                  label: 'Mobile Number *',
                  hint: 'Enter your mobile number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                
                _buildModernTextField(
                  controller: _genderController,
                  label: 'Gender *',
                  hint: 'e.g. Male, Female, Other',
                  icon: Icons.wc_rounded,
                ),
                const SizedBox(height: 20),
                
                _buildModernTextField(
                  controller: _addressController,
                  label: 'Address (Optional)',
                  hint: 'Enter your address',
                  icon: Icons.location_on_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 25),
                
                _buildModernTextField(
                  controller: _emailController,
                  label: 'Email *',
                  hint: 'Enter your email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                _buildModernTextField(
                  controller: _passwordController,
                  label: 'Password *',
                  hint: 'Create a password',
                  icon: Icons.lock_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: ThemeProvider.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 35),
                
                _buildModernButton('Create Account', _isLoading ? null : _signUp),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: ThemeProvider.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: ThemeProvider.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              color: ThemeProvider.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: ThemeProvider.textSecondary.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: ThemeProvider.primaryBlue, size: 22),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeProvider.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: ThemeProvider.primaryBlue.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

// ========================================
// ADMIN LOGIN PAGE
// ========================================

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginAsAdmin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: ThemeProvider.errorRed,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final manager = Provider.of<BookingManager>(context, listen: false);
      
      final success = await manager.authenticateAdmin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${manager.currentAdmin?.name ?? "Admin"}!'),
            backgroundColor: ThemeProvider.successGreen,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid admin credentials'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeProvider.accentOrange.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: ThemeProvider.accentOrange, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'HSA Admin Portal',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeProvider.accentOrange,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Secure admin access',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeProvider.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                
                _buildModernTextField(
                  controller: _emailController,
                  label: 'Admin Email',
                  hint: 'Enter admin email',
                  icon: Icons.admin_panel_settings_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                _buildModernTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter password',
                  icon: Icons.lock_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: ThemeProvider.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginAsAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Login as Admin',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeProvider.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeProvider.accentOrange.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: ThemeProvider.accentOrange,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Only authorized admins can access this portal',
                          style: TextStyle(
                            color: ThemeProvider.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: ThemeProvider.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: ThemeProvider.textSecondary.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: ThemeProvider.accentOrange, size: 22),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.accentOrange, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// END OF CHUNK 3
// ========================================
// ========================================
// HSA APP - CHUNK 4 OF 7 (OVERFLOW FIXED)
// Home Page with Fixed Service Cards
// ========================================

// ✅ FIXED: Home Page with No Overflow
class HomePage extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const HomePage({super.key, required this.themeProvider});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final manager = Provider.of<BookingManager>(context, listen: false);
      manager._fetchInitialServices();
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const MyBookingsPage();
      case 2:
        return ProfilePage(themeProvider: widget.themeProvider);
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    final manager = Provider.of<BookingManager>(context);
    final services = manager.activeServices;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: ThemeProvider.primaryBlue,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: const Text(
              'HSA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeProvider.primaryBlue,
                    ThemeProvider.primaryDark,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Book services at your doorstep',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ThemeProvider.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ThemeProvider.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${services.length} Available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ThemeProvider.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        services.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        color: ThemeProvider.primaryBlue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading services...',
                        style: TextStyle(
                          color: ThemeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    // ✅ FIXED: Increased from 0.75 to 0.85 to give more vertical space
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildFixedServiceCard(services[index]);
                    },
                    childCount: services.length,
                  ),
                ),
              ),
      ],
    );
  }

  // ✅ FIXED: Service Card with Proper Spacing (No Overflow)
  Widget _buildFixedServiceCard(ServiceModel service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(
              serviceName: service.name,
              price: service.price,
              serviceImage: service.imageUrl,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: Image Section with Fixed Height
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: service.isValidImageUrl
                      ? CachedNetworkImage(
                          imageUrl: service.imageUrl,
                          width: double.infinity,
                          height: 110, // ✅ Fixed height instead of Expanded
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  service.color.withOpacity(0.3),
                                  service.color.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: service.color,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  service.color.withOpacity(0.2),
                                  service.color.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                service.icon,
                                size: 48,
                                color: service.color.withOpacity(0.6),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                service.color.withOpacity(0.2),
                                service.color.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              service.icon,
                              size: 48,
                              color: service.color.withOpacity(0.6),
                            ),
                          ),
                        ),
                ),
                
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: service.color.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: service.color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      service.icon,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            // ✅ FIXED: Content Section with Proper Padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and Rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: ThemeProvider.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              service.rating,
                              style: const TextStyle(
                                fontSize: 10,
                                color: ThemeProvider.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: service.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  service.category,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: service.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // ✅ FIXED: Price and Book Button with Adjusted Spacing
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            service.price,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: service.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: service.color,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: service.color.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: ThemeProvider.primaryBlue,
        unselectedItemColor: ThemeProvider.textSecondary,
        currentIndex: _selectedIndex,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_rounded),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

// ========================================
// MY BOOKINGS PAGE (No changes needed)
// ========================================

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<BookingManager>(context);

    return Scaffold(
      backgroundColor: ThemeProvider.lightBg,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ThemeProvider.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: manager.userBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_busy_rounded,
                      size: 64,
                      color: ThemeProvider.primaryBlue.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: ThemeProvider.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book a service to see it here',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: manager.userBookings.length,
              itemBuilder: (context, index) {
                BookingModel booking = manager.userBookings[index];
                return _buildBookingCard(booking);
              },
            ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;
    IconData statusIcon;
    switch (booking.status) {
      case 'Confirmed':
        statusColor = ThemeProvider.successGreen;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Rejected':
        statusColor = ThemeProvider.errorRed;
        statusIcon = Icons.cancel_rounded;
        break;
      case 'Pending':
      default:
        statusColor = ThemeProvider.warningAmber;
        statusIcon = Icons.schedule_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: ThemeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${booking.bookingId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeProvider.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        booking.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_rounded, 'Name', booking.name),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.access_time_rounded, 'Time', booking.timeSlot),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.calendar_today_rounded, 'Date', booking.date),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.location_on_rounded, 'Address', booking.address),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.phone_rounded, 'Phone', booking.phone),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.textPrimary,
                      ),
                    ),
                    Text(
                      booking.price,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ThemeProvider.primaryBlue),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            color: ThemeProvider.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeProvider.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// END OF FIXED CHUNK 4
// ========================================
// ========================================
// HSA APP - CHUNK 5 OF 7 (FULLY FIXED)
// Profile Page with Working Edit + About HSA
// ========================================

// Add this to your main.dart file after Chunk 4

// ========================================
// ✅ FIXED: PROFILE PAGE WITH WORKING EDIT
// ========================================

class ProfilePage extends StatelessWidget {
  final ThemeProvider themeProvider;
  
  const ProfilePage({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? ThemeProvider.darkBg : ThemeProvider.lightBg,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? ThemeProvider.cardDark : Colors.white,
        foregroundColor: isDark ? ThemeProvider.textDark : ThemeProvider.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? ThemeProvider.cardDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeProvider.primaryBlue.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: ThemeProvider.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? ThemeProvider.textDark : ThemeProvider.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: ThemeProvider.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  if (userMobile.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      userMobile,
                      style: const TextStyle(
                        color: ThemeProvider.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // ✅ NEW: Edit Profile Button
            _buildProfileOption(
              context,
              Icons.edit_rounded,
              'Edit Profile',
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
            ),
            
            // ✅ FIXED: Dark Mode Toggle that actually works
            _buildProfileOption(
              context,
              Icons.dark_mode_rounded,
              'Dark Mode',
              isDark: isDark,
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) async {
                  await themeProvider.toggleTheme();
                },
                activeThumbColor: ThemeProvider.primaryBlue,
              ),
            ),
            
            _buildProfileOption(
              context,
              Icons.info_rounded,
              'About HSA',
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutHSAPage()),
                );
              },
            ),
            
            _buildProfileOption(
              context,
              Icons.logout_rounded,
              'Logout',
              isRed: true,
              isDark: isDark,
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                userName = 'Guest User';
                userEmail = 'user@example.com';
                userMobile = '';
                
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LoginSelectionPage(themeProvider: themeProvider),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
    Widget? trailing,
    bool isRed = false,
    bool isDark = false,
  }) {
    final color = isRed ? ThemeProvider.errorRed : ThemeProvider.primaryBlue;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? ThemeProvider.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isRed 
                          ? ThemeProvider.errorRed 
                          : isDark 
                              ? ThemeProvider.textDark 
                              : ThemeProvider.textPrimary,
                    ),
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: ThemeProvider.textSecondary,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// ✅ NEW: EDIT PROFILE PAGE WITH DATABASE UPDATE
// ========================================

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    _nameController.text = userName;
    _mobileController.text = userMobile;
    _genderController.text = userGender;
    _addressController.text = userAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ✅ FIXED: Save profile changes to database
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      final manager = Provider.of<BookingManager>(context, listen: false);
      
      final success = await manager.updateUserProfile(
        name: _nameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        gender: _genderController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (mounted) {
        setState(() { _isLoading = false; });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: ThemeProvider.successGreen,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: ThemeProvider.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.lightBg,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ThemeProvider.primaryBlue,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeProvider.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Update your profile details below',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeProvider.textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              
              _buildTextField(
                controller: _nameController,
                label: 'Full Name *',
                hint: 'Enter your full name',
                icon: Icons.person_rounded,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _mobileController,
                label: 'Mobile Number *',
                hint: 'Enter your mobile number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? 'Valid number required' : null,
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _genderController,
                label: 'Gender *',
                hint: 'e.g. Male, Female, Other',
                icon: Icons.wc_rounded,
                validator: (v) => v!.isEmpty ? 'Gender is required' : null,
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _addressController,
                label: 'Address *',
                hint: 'Enter your complete address',
                icon: Icons.location_on_rounded,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: ThemeProvider.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: ThemeProvider.textSecondary.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: ThemeProvider.primaryBlue, size: 22),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.primaryBlue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.errorRed, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.errorRed, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// ABOUT HSA PAGE
// ========================================

class AboutHSAPage extends StatelessWidget {
  const AboutHSAPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.lightBg,
      appBar: AppBar(
        title: const Text(
          'About HSA',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ThemeProvider.primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeProvider.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_repair_service_rounded,
                size: 64,
                color: ThemeProvider.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'HSA - Home Services Application',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ThemeProvider.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            _buildInfoCard(
              'Our Mission',
              'HSA is dedicated to revolutionizing home services by connecting customers with verified, professional service providers. We believe quality home services should be accessible, reliable, and hassle-free.',
              Icons.rocket_launch_rounded,
              ThemeProvider.primaryBlue,
            ),
            const SizedBox(height: 16),
            
            _buildInfoCard(
              'What We Offer',
              '• Professional cleaning services\n• Skilled plumbing and electrical work\n• Expert salon services at home\n• Verified service providers\n• Real-time booking system\n• Secure payment options',
              Icons.stars_rounded,
              ThemeProvider.accentOrange,
            ),
            const SizedBox(height: 16),
            
            _buildInfoCard(
              'Our Values',
              'Quality • Trust • Convenience • Customer Satisfaction\n\nWe prioritize your safety and satisfaction by thoroughly vetting all service providers and maintaining high service standards.',
              Icons.favorite_rounded,
              ThemeProvider.successGreen,
            ),
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: ThemeProvider.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '© 2025 HSA. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeProvider.textSecondary,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Made with ❤️ for better home services',
                    style: TextStyle(
                      fontSize: 11,
                      color: ThemeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeProvider.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// END OF CHUNK 5
// ========================================
// ========================================
// HSA APP - CHUNK 6 OF 7 (FULLY FIXED)
// Booking Page & Payment Page with QR Code
// ========================================

// Add this to your main.dart file after Chunk 5

// ========================================
// ✅ BOOKING PAGE WITH TIME SLOTS
// ========================================

class BookingPage extends StatefulWidget {
  final String serviceName;
  final String price;
  final String serviceImage;

  const BookingPage({
    super.key,
    required this.serviceName,
    required this.price,
    required this.serviceImage,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? selectedTimeSlot;
  final bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill user data
    _nameController.text = userName;
    _emailController.text = userEmail;
    _phoneController.text = userMobile.isNotEmpty ? userMobile : '';
    _addressController.text = userAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: ThemeProvider.errorRed,
        ),
      );
      return;
    }

    final manager = Provider.of<BookingManager>(context, listen: false);
    final selectedSlotModel = manager.availableTimeSlots.firstWhere(
      (s) => s.timeSlot == selectedTimeSlot,
      orElse: () => TimeSlotModel(timeSlot: selectedTimeSlot!, availableCount: 0),
    );

    if (selectedSlotModel.availableCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This slot is fully booked! Please select another.'),
          backgroundColor: ThemeProvider.errorRed,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          serviceName: widget.serviceName,
          price: widget.price,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          timeSlot: selectedTimeSlot!,
          serviceImage: widget.serviceImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<BookingManager>(context);

    return Scaffold(
      backgroundColor: ThemeProvider.lightBg,
      appBar: AppBar(
        title: const Text(
          'Book Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ThemeProvider.primaryBlue,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Info Card with Image
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.serviceImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 150,
                          color: ThemeProvider.primaryBlue.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: ThemeProvider.primaryBlue.withOpacity(0.1),
                            child: const Center(
                              child: Icon(
                                Icons.home_repair_service_rounded,
                                size: 60,
                                color: ThemeProvider.primaryBlue,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.serviceName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeProvider.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'HSA Professional Service',
                                  style: TextStyle(
                                    color: ThemeProvider.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            widget.price,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ThemeProvider.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Personal Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_rounded,
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_rounded,
                      validator: (v) => !v!.contains('@') ? 'Enter valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Mobile Number',
                      icon: Icons.phone_rounded,
                      validator: (v) => v!.length < 10 ? 'Enter valid number' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on_rounded,
                      maxLines: 2,
                      validator: (v) => v!.isEmpty || v == 'Not set' ? 'Enter address' : null,
                    ),
                    const SizedBox(height: 30),
                    
                    // Time Slots Section
                    const Text(
                      'Select Time Slot',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Time Slots Grid
                    manager.availableTimeSlots.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.5,
                            ),
                            itemCount: manager.availableTimeSlots.length,
                            itemBuilder: (context, index) {
                              TimeSlotModel slotModel = manager.availableTimeSlots[index];
                              bool isSelected = selectedTimeSlot == slotModel.timeSlot;
                              bool isAvailable = slotModel.availableCount > 0;
                              
                              return GestureDetector(
                                onTap: isAvailable
                                    ? () => setState(() => selectedTimeSlot = slotModel.timeSlot)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: !isAvailable
                                        ? Colors.grey.shade100
                                        : isSelected
                                            ? ThemeProvider.primaryBlue
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !isAvailable
                                          ? Colors.grey.shade300
                                          : isSelected
                                              ? ThemeProvider.primaryBlue
                                              : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: ThemeProvider.primaryBlue.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        slotModel.timeSlot,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: !isAvailable
                                              ? Colors.grey
                                              : isSelected
                                                  ? Colors.white
                                                  : ThemeProvider.textPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isAvailable
                                            ? '${slotModel.availableCount} slots left'
                                            : 'Fully Booked',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: !isAvailable
                                              ? ThemeProvider.errorRed
                                              : isSelected
                                                  ? Colors.white70
                                                  : ThemeProvider.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 30),
                    
                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Proceed to Payment',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          color: ThemeProvider.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: ThemeProvider.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: ThemeProvider.primaryBlue, size: 22),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ThemeProvider.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ThemeProvider.errorRed, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ThemeProvider.errorRed, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ========================================
// ✅ PAYMENT PAGE WITH QR CODE
// ========================================

class PaymentPage extends StatelessWidget {
  final String serviceName;
  final String price;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String timeSlot;
  final String serviceImage;

  const PaymentPage({
    super.key,
    required this.serviceName,
    required this.price,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.timeSlot,
    required this.serviceImage,
  });

  @override
  Widget build(BuildContext context) {
    String qrData = 'upi://pay?pa=hsa@upi&pn=HSA&am=${price.replaceAll('Rs.', '').replaceAll(',', '').trim()}&cu=INR&tn=Payment for $serviceName';

    return Scaffold(
      backgroundColor: ThemeProvider.lightBg,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ThemeProvider.primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Payment Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeProvider.successGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.payment_rounded,
                        size: 48,
                        color: ThemeProvider.successGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scan QR Code to Pay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: $price',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // QR Code
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeProvider.primaryBlue.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 240.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Scan using any UPI app',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeProvider.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Booking Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.primaryBlue,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow('Service', serviceName),
                    _buildSummaryRow('Name', name),
                    _buildSummaryRow('Phone', phone),
                    _buildSummaryRow('Time Slot', timeSlot),
                    _buildSummaryRow('Address', address),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeProvider.textPrimary,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeProvider.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Confirmation
              const Text(
                'Have you completed the payment?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeProvider.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _handlePaymentConfirmation(context, true),
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: const Text('Yes, I paid'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.successGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _handlePaymentConfirmation(context, false),
                        icon: const Icon(Icons.cancel_rounded, size: 20),
                        label: const Text("No, I didn't"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.errorRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: ThemeProvider.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ThemeProvider.textPrimary,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePaymentConfirmation(BuildContext context, bool paid) async {
    if (paid) {
      final manager = Provider.of<BookingManager>(context, listen: false);
      final success = await manager.createBooking(
        serviceName: serviceName,
        price: price,
        name: name,
        email: email,
        phone: phone,
        address: address,
        timeSlot: timeSlot,
      );

      if (success && context.mounted) {
        _showAnimatedSuccessDialog(context);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking failed. Slot may be unavailable.'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Payment Pending',
            style: TextStyle(
              color: ThemeProvider.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Please complete the payment to confirm your booking.',
            style: TextStyle(color: ThemeProvider.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: ThemeProvider.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showAnimatedSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AnimatedSuccessDialog(),
    ).then((_) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }
}

// ========================================
// ✅ ANIMATED SUCCESS DIALOG
// ========================================

class AnimatedSuccessDialog extends StatefulWidget {
  const AnimatedSuccessDialog({super.key});

  @override
  State<AnimatedSuccessDialog> createState() => _AnimatedSuccessDialogState();
}

class _AnimatedSuccessDialogState extends State<AnimatedSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ThemeProvider.primaryBlue.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ThemeProvider.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: ThemeProvider.successGreen,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ThemeProvider.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Thank you for booking with HSA!\nYour booking is pending admin review.',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeProvider.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Check "My Bookings" for status updates.',
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeProvider.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// END OF CHUNK 6
// ========================================
// ========================================
// ========================================
// ========================================
// ========================================
// HSA APP - CHUNK 7 OF 7 (OVERFLOW COMPLETELY FIXED)
// Admin Dashboard & Service Management
// ========================================

// ========================================
// ✅ ADMIN DASHBOARD WITH FIXED STAT CARDS (NO OVERFLOW)
// ========================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<BookingManager>(context, listen: false).fetchAllAdminBookings());
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<BookingManager>(context);
    final totalBookings = manager.adminBookings.length;
    final todayBookings = manager.getTodayBookingCount();
    final pendingBookings =
        manager.adminBookings.where((b) => b.status == 'Pending').length;
    final confirmedBookings =
        manager.adminBookings.where((b) => b.status == 'Confirmed').length;

    int totalRevenue = manager.adminBookings
        .where((b) => b.status == 'Confirmed')
        .map((b) => int.tryParse(
            b.price.replaceAll('Rs.', '').replaceAll(',', '').trim()) ?? 0)
        .fold(0, (sum, price) => sum + price);

    return Scaffold(
      backgroundColor: ThemeProvider.lightBg,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Provider.of<BookingManager>(context, listen: false).logoutAdmin();
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: ThemeProvider.accentOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminServicesPage(),
                ),
              );
            },
            tooltip: 'Manage Services',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              await manager.manualResetSlots();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All slots reset to 20!'),
                    backgroundColor: ThemeProvider.successGreen,
                  ),
                );
              }
            },
            tooltip: 'Reset Slots',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: Stat Cards with Proper Constraints (NO OVERFLOW)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45, // ✅ REDUCED from 1.75 to 1.45 for TALLER cards
              children: [
                _buildStatCard('Total', '$totalBookings', Icons.book_online_rounded, ThemeProvider.primaryBlue),
                _buildStatCard('Today', '$todayBookings', Icons.today_rounded, ThemeProvider.successGreen),
                _buildStatCard('Pending', '$pendingBookings', Icons.pending_actions_rounded, ThemeProvider.warningAmber),
                _buildStatCard('Confirmed', '$confirmedBookings', Icons.check_circle_rounded, ThemeProvider.successGreen),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeProvider.primaryBlue,
                    ThemeProvider.primaryBlue.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ThemeProvider.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Revenue',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs.${NumberFormat('#,##,##0').format(totalRevenue)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_rupee_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeProvider.textPrimary,
                  ),
                ),
                Text(
                  '${manager.adminBookings.length} total',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ThemeProvider.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (manager.adminBookings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: ThemeProvider.accentOrange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inbox_rounded,
                          size: 64,
                          color: ThemeProvider.accentOrange.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No bookings found',
                        style: TextStyle(
                          color: ThemeProvider.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...manager.adminBookings.map((booking) {
                return _buildAdminBookingCard(context, booking, manager);
              }),
          ],
        ),
      ),
    );
  }

  // ✅ COMPLETELY FIXED: Stat Card with NO OVERFLOW
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10), // ✅ Uniform padding instead of symmetric
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // ✅ CRITICAL FIX
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6), // ✅ Reduced from 8 to 6
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color), // ✅ Reduced from 18 to 16
          ),
          const SizedBox(height: 4), // ✅ Reduced from 6 to 4
          
          // Value
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18, // ✅ Kept at 18
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2), // ✅ Kept at 2
          
          // Title - THIS WAS CAUSING OVERFLOW
          Text(
            title,
            style: const TextStyle(
              fontSize: 10, // ✅ Kept at 10
              color: ThemeProvider.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBookingCard(
      BuildContext context, BookingModel booking, BookingManager manager) {
    Color statusColor;
    IconData statusIcon;
    switch (booking.status) {
      case 'Confirmed':
        statusColor = ThemeProvider.successGreen;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Rejected':
        statusColor = ThemeProvider.errorRed;
        statusIcon = Icons.cancel_rounded;
        break;
      case 'Pending':
      default:
        statusColor = ThemeProvider.warningAmber;
        statusIcon = Icons.schedule_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${booking.bookingId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: ThemeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      booking.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 20, color: Colors.grey.shade200),
          _buildAdminInfoRow(Icons.person_rounded, 'User', booking.name),
          _buildAdminInfoRow(Icons.email_rounded, 'Email', booking.email),
          _buildAdminInfoRow(Icons.phone_rounded, 'Phone', booking.phone),
          _buildAdminInfoRow(Icons.schedule_rounded, 'Time', '${booking.timeSlot} • ${booking.date}'),
          _buildAdminInfoRow(Icons.location_on_rounded, 'Address', booking.address),
          _buildAdminInfoRow(Icons.payment_rounded, 'Amount', booking.price),
          
          if (booking.status == 'Pending')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await manager.updateBookingStatus(booking.bookingId, 'Confirmed');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking Confirmed! ✓'),
                                backgroundColor: ThemeProvider.successGreen,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.successGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await manager.incrementSlotCount(booking.timeSlot);
                          await manager.updateBookingStatus(booking.bookingId, 'Rejected');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking Rejected! Slot restored.'),
                                backgroundColor: ThemeProvider.errorRed,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.errorRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: ThemeProvider.primaryBlue),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeProvider.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: ThemeProvider.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// ADMIN SERVICES PAGE WITH TABS
// ========================================

class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key});

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() =>
        Provider.of<BookingManager>(context, listen: false).fetchAllServicesAdmin());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<BookingManager>(context);

    return Scaffold(
      backgroundColor: ThemeProvider.lightBg,
      appBar: AppBar(
        title: const Text(
          'Manage Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ThemeProvider.accentOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditServicePage(),
                ),
              );
            },
            tooltip: 'Add New Service',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeProvider.accentOrange,
          labelColor: ThemeProvider.accentOrange,
          unselectedLabelColor: ThemeProvider.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              text: 'Active (${manager.activeServices.length})',
              icon: const Icon(Icons.check_circle_rounded, size: 20),
            ),
            Tab(
              text: 'Disabled (${manager.disabledServices.length})',
              icon: const Icon(Icons.cancel_rounded, size: 20),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServicesList(manager.activeServices, manager, isActive: true),
          _buildServicesList(manager.disabledServices, manager, isActive: false),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<ServiceModel> services, BookingManager manager, {required bool isActive}) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeProvider.accentOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.inbox_rounded : Icons.block_rounded,
                size: 64,
                color: ThemeProvider.accentOrange.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active services' : 'No disabled services',
              style: const TextStyle(
                fontSize: 16,
                color: ThemeProvider.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceManagementCard(services[index], manager);
      },
    );
  }

  Widget _buildServiceManagementCard(ServiceModel service, BookingManager manager) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: service.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          service.color.withOpacity(0.3),
                          service.color.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: service.color,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          service.color.withOpacity(0.2),
                          service.color.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        service.icon,
                        size: 48,
                        color: service.color.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: service.isActive
                        ? ThemeProvider.successGreen
                        : ThemeProvider.errorRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service.isActive ? 'Active' : 'Disabled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: service.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(service.icon, color: service.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ThemeProvider.textPrimary,
                            ),
                          ),
                          Text(
                            service.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ThemeProvider.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      service.price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: service.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final success = await manager.toggleServiceStatus(
                              service.id,
                              !service.isActive,
                            );
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    service.isActive
                                        ? 'Service Disabled'
                                        : 'Service Enabled',
                                  ),
                                  backgroundColor: service.isActive
                                      ? ThemeProvider.errorRed
                                      : ThemeProvider.successGreen,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            service.isActive
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 18,
                          ),
                          label: Text(
                            service.isActive ? 'Disable' : 'Enable',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: service.isActive
                                ? ThemeProvider.errorRed
                                : ThemeProvider.successGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditServicePage(service: service),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeProvider.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// ADD/EDIT SERVICE PAGE (WITH IMAGE UPLOAD) - KEEPING AS IS
// ========================================

class AddEditServicePage extends StatefulWidget {
  final ServiceModel? service;
  
  const AddEditServicePage({super.key, this.service});

  @override
  State<AddEditServicePage> createState() => _AddEditServicePageState();
}

class _AddEditServicePageState extends State<AddEditServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String selectedCategory = 'Cleaning';
  String selectedIcon = 'home_repair_service';
  String selectedColor = '2196F3';
  bool _isLoading = false;
  File? _selectedImage;
  bool _useUploadedImage = false;

  final List<String> categories = [
    'Cleaning',
    'Salon',
    'Electrical',
    'Plumbing',
    'Painting',
    'Carpentry',
    'Spa & Massage',
    'Beauty & Fashion',
    'Fashion Styling',
  ];

  final Map<String, String> iconOptions = {
    'Home Repair': 'home_repair_service',
    'Cleaning': 'cleaning_services',
    'Bathroom': 'bathroom',
    'Home': 'home',
    'Scissors': 'content_cut',
    'Kitchen': 'kitchen',
    'AC Unit': 'ac_unit',
    'Plumbing': 'plumbing',
    'Electrical': 'electrical_services',
    'Paint': 'format_paint',
    'Carpenter': 'carpenter',
    'Spa': 'spa',
    'Meditation': 'self_improvement',
    'Face': 'face_retouching_natural',
    'Face 2': 'face',
    'Colorize': 'colorize',
    'Shower': 'shower',
    'Wardrobe': 'checkroom',
  };

  final Map<String, String> colorOptions = {
    'Blue': '2196F3',
    'Cyan': '00BCD4',
    'Green': '4CAF50',
    'Pink': 'E91E63',
    'Orange': 'FF9800',
    'Indigo': '3F51B5',
    'Purple': '9C27B0',
    'Brown': '795548',
    'Hot Pink': 'FF69B4',
    'Light Purple': 'BA68C8',
    'Red': 'FF1744',
    'Deep Pink': 'FF4081',
    'Magenta': 'F50057',
    'Rose': 'EC407A',
    'Deep Rose': 'D81B60',
  };

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _priceController.text = widget.service!.price.replaceAll('Rs.', '').trim();
      _imageUrlController.text = widget.service!.imageUrl;
      selectedCategory = widget.service!.category;
      selectedIcon = widget.service!.iconName;
      selectedColor = widget.service!.colorHex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImageUploadHelper.pickImage(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _useUploadedImage = true;
        _imageUrlController.clear();
      });
    }
  }

  void _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_useUploadedImage && _imageUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an image (upload or URL)'),
          backgroundColor: ThemeProvider.errorRed,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      String finalImageUrl;

      if (_useUploadedImage && _selectedImage != null) {
        final uploadedUrl = await ImageUploadHelper.uploadToSupabase(
          _selectedImage!,
          context,
        );
        
        if (uploadedUrl == null) {
          setState(() { _isLoading = false; });
          return;
        }
        
        finalImageUrl = uploadedUrl;
      } else {
        finalImageUrl = _imageUrlController.text.trim();
      }

      final manager = Provider.of<BookingManager>(context, listen: false);
      bool success;

      if (widget.service == null) {
        success = await manager.addNewService(
          name: _nameController.text.trim(),
          price: 'Rs.${_priceController.text.trim()}',
          category: selectedCategory,
          imageUrl: finalImageUrl,
          iconName: selectedIcon,
          colorHex: selectedColor,
        );
      } else {
        success = await manager.updateService(
          serviceId: widget.service!.id,
          name: _nameController.text.trim(),
          price: 'Rs.${_priceController.text.trim()}',
          category: selectedCategory,
          imageUrl: finalImageUrl,
          iconName: selectedIcon,
          colorHex: selectedColor,
        );
      }

      if (mounted) {
        setState(() { _isLoading = false; });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.service == null
                    ? 'Service added successfully!'
                    : 'Service updated successfully!',
              ),
              backgroundColor: ThemeProvider.successGreen,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save service'),
              backgroundColor: ThemeProvider.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ThemeProvider.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.lightBg,
      appBar: AppBar(
        title: Text(
          widget.service == null ? 'Add Service' : 'Edit Service',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ThemeProvider.accentOrange,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Service Name *',
                hint: 'e.g., Deep Cleaning',
                icon: Icons.spa_rounded,
                validator: (v) => v!.isEmpty ? 'Enter service name' : null,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _priceController,
                label: 'Price (without Rs.) *',
                hint: 'e.g., 999',
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Category *',
                value: selectedCategory,
                items: categories,
                icon: Icons.category_rounded,
                onChanged: (value) => setState(() => selectedCategory = value!),
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Icon *',
                value: selectedIcon,
                items: iconOptions.values.toList(),
                displayItems: iconOptions.keys.toList(),
                icon: Icons.image_rounded,
                onChanged: (value) => setState(() => selectedIcon = value!),
              ),
              const SizedBox(height: 20),

              _buildColorDropdown(),
              const SizedBox(height: 20),

              const Text(
                'Service Image *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeProvider.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ThemeProvider.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeProvider.accentOrange.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedImage != null
                            ? Icons.check_circle_rounded
                            : Icons.cloud_upload_rounded,
                        size: 48,
                        color: _selectedImage != null
                            ? ThemeProvider.successGreen
                            : ThemeProvider.accentOrange,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedImage != null
                            ? 'Image Selected ✓'
                            : 'Tap to Upload Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _selectedImage != null
                              ? ThemeProvider.successGreen
                              : ThemeProvider.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedImage != null
                            ? 'Tap again to change'
                            : 'From Gallery or Camera',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeProvider.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _imageUrlController,
                label: 'Image URL (Alternative)',
                hint: 'https://example.com/image.jpg',
                icon: Icons.link_rounded,
                maxLines: 3,
                enabled: !_useUploadedImage,
                onChanged: (v) {
                  if (v.isNotEmpty) {
                    setState(() {
                      _useUploadedImage = false;
                      _selectedImage = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              if (_selectedImage != null || _imageUrlController.text.isNotEmpty)
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: _imageUrlController.text,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_rounded,
                                      size: 48,
                                      color: ThemeProvider.textSecondary,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Invalid Image URL',
                                      style: TextStyle(
                                        color: ThemeProvider.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeProvider.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: ThemeProvider.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _useUploadedImage
                            ? 'Using uploaded image from your device'
                            : 'Upload from device or paste any image URL',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeProvider.primaryBlue.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          widget.service == null ? 'Add Service' : 'Update Service',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            enabled: enabled,
            onChanged: onChanged,
            style: TextStyle(
              color: enabled ? ThemeProvider.textPrimary : ThemeProvider.textSecondary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: ThemeProvider.textSecondary.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: enabled ? ThemeProvider.accentOrange : ThemeProvider.textSecondary,
                size: 22,
              ),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.accentOrange, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.errorRed, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.errorRed, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    List<String>? displayItems,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: ThemeProvider.accentOrange, size: 22),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.accentOrange, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: List.generate(items.length, (index) {
              return DropdownMenuItem(
                value: items[index],
                child: Text(displayItems != null ? displayItems[index] : items[index]),
              );
            }),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildColorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: selectedColor,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.palette_rounded,
                color: Color(int.parse('FF$selectedColor', radix: 16)),
                size: 22,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeProvider.accentOrange, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: colorOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.value,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(int.parse('FF${entry.value}', radix: 16)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(entry.key),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedColor = value!;
              });
            },
          ),
        ),
      ],
    );
  }
}

// ========================================
// END OF FIXED CHUNK 7 - ALL OVERFLOW ISSUES RESOLVED
// ========================================> iconOptions = {
  