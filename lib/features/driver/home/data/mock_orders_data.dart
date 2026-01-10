import 'dart:math';

import '../models/driver_order_model.dart';

class MockOrdersData {
  static List<DriverOrderModel> getMockOrders() {
    // إحداثيات طرابلس، ليبيا (مرجعية)
    final double baseLat = 32.8872;
    final double baseLng = 13.1913;

    return [
      DriverOrderModel(
        id: 'order_001',
        orderNumber: 'ORD-2024-001',
        customerId: 'cust_001',
        customerName: 'محمد أحمد',
        customerPhone: '+218912345678',
        restaurantId: 'rest_001',
        restaurantName: 'مطعم الكوخ',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الأندلس، شارع الجهاد',
          latitude: baseLat + 0.01,
          longitude: baseLng + 0.01,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي النصر، شارع عمر المختار',
          latitude: baseLat + 0.02,
          longitude: baseLng + 0.02,
          label: 'المنزل',
        ),
        items: [
          OrderItem(name: 'برجر لحم', quantity: 2, price: 25.00),
          OrderItem(name: 'بطاطا مقلية', quantity: 1, price: 8.50),
          OrderItem(name: 'بيبسي', quantity: 2, price: 3.00),
        ],
        totalAmount: 64.50,
        paymentMethod: 'cash',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        deliveryFee: 45.50,
        notes: 'يرجى الاتصال قبل الوصول',
      ),
      DriverOrderModel(
        id: 'order_002',
        orderNumber: 'ORD-2024-002',
        customerId: 'cust_002',
        customerName: 'فاطمة علي',
        customerPhone: '+218912345679',
        restaurantId: 'rest_002',
        restaurantName: 'مطعم البحر الأحمر',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي بن عاشور، شارع الفاتح',
          latitude: baseLat - 0.015,
          longitude: baseLng + 0.008,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي الزهراء، شارع الجمهورية',
          latitude: baseLat - 0.01,
          longitude: baseLng + 0.015,
          label: 'العمل',
        ),
        items: [
          OrderItem(name: 'شاورما دجاج', quantity: 3, price: 18.00),
          OrderItem(name: 'سلطة طحينة', quantity: 2, price: 12.00),
          OrderItem(name: 'عصير برتقال', quantity: 3, price: 4.50),
        ],
        totalAmount: 81.00,
        paymentMethod: 'cash',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        deliveryFee: 50.00,
      ),
      DriverOrderModel(
        id: 'order_003',
        orderNumber: 'ORD-2024-003',
        customerId: 'cust_003',
        customerName: 'خالد محمود',
        customerPhone: '+218912345680',
        restaurantId: 'rest_003',
        restaurantName: 'بيتزا إيطاليا',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الهضبة، شارع الوادي',
          latitude: baseLat + 0.02,
          longitude: baseLng - 0.01,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي السواني، شارع 23 يوليو',
          latitude: baseLat + 0.025,
          longitude: baseLng - 0.005,
          label: 'الشقة 5',
        ),
        items: [
          OrderItem(name: 'بيتزا كبيرة', quantity: 1, price: 45.00),
          OrderItem(name: 'صوص جبن إضافي', quantity: 1, price: 5.00),
          OrderItem(name: 'كولا', quantity: 2, price: 3.00),
        ],
        totalAmount: 53.00,
        paymentMethod: 'card',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        deliveryFee: 35.00,
        notes: 'الطابق الثاني',
      ),
      DriverOrderModel(
        id: 'order_004',
        orderNumber: 'ORD-2024-004',
        customerId: 'cust_004',
        customerName: 'عائشة سالم',
        customerPhone: '+218912345681',
        restaurantId: 'rest_004',
        restaurantName: 'مطعم الطعم الصيني',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الفرناج، شارع الثورة',
          latitude: baseLat - 0.008,
          longitude: baseLng - 0.012,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي الساقية، شارع الجلاء',
          latitude: baseLat - 0.005,
          longitude: baseLng - 0.018,
        ),
        items: [
          OrderItem(name: 'أرز دجاج', quantity: 2, price: 22.00),
          OrderItem(name: 'رول سلطعون', quantity: 4, price: 8.00),
          OrderItem(name: 'حساء صيني', quantity: 2, price: 15.00),
        ],
        totalAmount: 79.00,
        paymentMethod: 'cash',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        deliveryFee: 42.00,
      ),
      DriverOrderModel(
        id: 'order_005',
        orderNumber: 'ORD-2024-005',
        customerId: 'cust_005',
        customerName: 'أحمد عمر',
        customerPhone: '+218912345682',
        restaurantId: 'rest_005',
        restaurantName: 'مطعم الوجبات السريعة',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الأندلس، شارع الأمين',
          latitude: baseLat + 0.005,
          longitude: baseLng + 0.003,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي النصر، شارع الكورنيش',
          latitude: baseLat + 0.008,
          longitude: baseLng + 0.006,
        ),
        items: [
          OrderItem(name: 'ساندوتش دجاج', quantity: 2, price: 20.00),
          OrderItem(name: 'ناجتس', quantity: 1, price: 15.00),
          OrderItem(name: 'مشروب غازي', quantity: 2, price: 3.00),
        ],
        totalAmount: 38.00,
        paymentMethod: 'cash',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        deliveryFee: 28.00,
      ),
    ];
  }

  // Get a single mock order for quick testing
  static DriverOrderModel getSingleMockOrder() {
    // random from 1 to 5
    final randomIndex = Random().nextInt(getMockOrders().length);
    return getMockOrders()[randomIndex];
  }

  // Get active orders with different statuses for testing
  static List<DriverOrderModel> getActiveMockOrders() {
    // إحداثيات طرابلس، ليبيا (مرجعية)
    final double baseLat = 32.8872;
    final double baseLng = 13.1913;

    return [
      // Order 1: Going to Restaurant (accepted/going_to_restaurant)
      DriverOrderModel(
        id: 'active_order_001',
        orderNumber: 'ORD-8291',
        customerId: 'cust_active_001',
        customerName: 'سارة خالد',
        customerPhone: '+218912345690',
        restaurantId: 'rest_active_001',
        restaurantName: 'مطعم المذاق الأصيل',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الفاتح، شارع النصر',
          latitude: baseLat + 0.012,
          longitude: baseLng + 0.008,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي الدريبي، شارع السلام',
          latitude: baseLat + 0.018,
          longitude: baseLng + 0.015,
          label: 'المنزل',
        ),
        items: [
          OrderItem(name: 'منسف لحم', quantity: 2, price: 35.00),
          OrderItem(name: 'سلطة عربية', quantity: 1, price: 12.00),
          OrderItem(name: 'مشروب', quantity: 2, price: 4.00),
        ],
        totalAmount: 86.00,
        paymentMethod: 'cash',
        status: 'accepted', // or 'going_to_restaurant'
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        deliveryFee: 48.50,
        notes: 'الطابق الأول',
      ),

      // Order 2: At Restaurant (at_restaurant)
      DriverOrderModel(
        id: 'active_order_002',
        orderNumber: 'ORD-8292',
        customerId: 'cust_active_002',
        customerName: 'يوسف سالم',
        customerPhone: '+218912345691',
        restaurantId: 'rest_active_002',
        restaurantName: 'مطعم الأسماك الطازجة',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي السليمانية، شارع الكورنيش',
          latitude: baseLat - 0.005,
          longitude: baseLng + 0.012,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي الجميلية، شارع الخليج',
          latitude: baseLat - 0.008,
          longitude: baseLng + 0.018,
          label: 'العمل',
        ),
        items: [
          OrderItem(name: 'سمك مشوي', quantity: 3, price: 28.00),
          OrderItem(name: 'أرز بالزعفران', quantity: 2, price: 10.00),
          OrderItem(name: 'سلطة طحينة', quantity: 2, price: 8.00),
        ],
        totalAmount: 100.00,
        paymentMethod: 'card',
        status: 'at_restaurant',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        deliveryFee: 52.00,
      ),

      // Order 3: Going to Customer (picked_up/going_to_customer)
      DriverOrderModel(
        id: 'active_order_003',
        orderNumber: 'ORD-8293',
        customerId: 'cust_active_003',
        customerName: 'نورا أحمد',
        customerPhone: '+218912345692',
        restaurantId: 'rest_active_003',
        restaurantName: 'مطعم البيتزا الإيطالية',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الهضبة، شارع الوادي',
          latitude: baseLat + 0.02,
          longitude: baseLng - 0.01,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي السواني، شارع 23 يوليو',
          latitude: baseLat + 0.025,
          longitude: baseLng - 0.005,
          label: 'الشقة 3',
        ),
        items: [
          OrderItem(name: 'بيتزا كبيرة', quantity: 1, price: 45.00),
          OrderItem(name: 'صوص جبن إضافي', quantity: 1, price: 5.00),
          OrderItem(name: 'كولا', quantity: 2, price: 3.00),
        ],
        totalAmount: 53.00,
        paymentMethod: 'cash',
        status: 'picked_up', // or 'going_to_customer'
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        deliveryFee: 35.00,
        notes: 'الطابق الثالث - الجرس الأيسر',
      ),

      // Order 4: At Customer (at_customer)
      DriverOrderModel(
        id: 'active_order_004',
        orderNumber: 'ORD-8294',
        customerId: 'cust_active_004',
        customerName: 'أحمد محمد',
        customerPhone: '+218912345693',
        restaurantId: 'rest_active_004',
        restaurantName: 'مطعم الكوخ',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الأندلس، شارع الجهاد',
          latitude: baseLat + 0.01,
          longitude: baseLng + 0.01,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي النصر، شارع عمر المختار',
          latitude: baseLat + 0.02,
          longitude: baseLng + 0.02,
          label: 'المنزل',
        ),
        items: [
          OrderItem(name: 'برجر لحم', quantity: 2, price: 25.00),
          OrderItem(name: 'بطاطا مقلية', quantity: 1, price: 8.50),
          OrderItem(name: 'بيبسي', quantity: 2, price: 3.00),
        ],
        totalAmount: 64.50,
        paymentMethod: 'cash',
        status: 'at_customer',
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
        deliveryFee: 45.50,
        notes: 'يرجى الاتصال قبل الوصول',
      ),

      // Order 5: Another Going to Restaurant
      DriverOrderModel(
        id: 'active_order_005',
        orderNumber: 'ORD-8295',
        customerId: 'cust_active_005',
        customerName: 'ليلى محمود',
        customerPhone: '+218912345694',
        restaurantId: 'rest_active_005',
        restaurantName: 'مطعم المأكولات البحرية',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الزهراء، شارع الجمهورية',
          latitude: baseLat - 0.01,
          longitude: baseLng + 0.015,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي الفرناج، شارع الثورة',
          latitude: baseLat - 0.008,
          longitude: baseLng - 0.012,
          label: 'المنزل',
        ),
        items: [
          OrderItem(name: 'جمبري مقلي', quantity: 2, price: 42.00),
          OrderItem(name: 'أرز', quantity: 1, price: 8.00),
          OrderItem(name: 'سلطة', quantity: 1, price: 10.00),
        ],
        totalAmount: 60.00,
        paymentMethod: 'cash',
        status: 'going_to_restaurant',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        deliveryFee: 38.00,
      ),

      // Order 6: At Restaurant (another one)
      DriverOrderModel(
        id: 'active_order_006',
        orderNumber: 'ORD-8296',
        customerId: 'cust_active_006',
        customerName: 'عمر حسن',
        customerPhone: '+218912345695',
        restaurantId: 'rest_active_006',
        restaurantName: 'مطعم الدجاج المقلي',
        pickupLocation: PickupLocation(
          address: 'طرابلس، حي الساقية، شارع الجلاء',
          latitude: baseLat - 0.005,
          longitude: baseLng - 0.018,
        ),
        deliveryLocation: DeliveryLocation(
          address: 'طرابلس، حي الهضبة، شارع الوادي',
          latitude: baseLat + 0.02,
          longitude: baseLng - 0.01,
          label: 'الشقة 10',
        ),
        items: [
          OrderItem(name: 'دجاج مقلي', quantity: 4, price: 20.00),
          OrderItem(name: 'بطاطا', quantity: 2, price: 8.50),
          OrderItem(name: 'صوص', quantity: 2, price: 3.00),
        ],
        totalAmount: 63.00,
        paymentMethod: 'card',
        status: 'at_restaurant',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        deliveryFee: 40.00,
      ),
    ];
  }

  // Get a random active order with a specific status
  static DriverOrderModel getActiveOrderByStatus(String status) {
    final activeOrders = getActiveMockOrders();
    final filtered = activeOrders.where((order) => order.status == status).toList();
    if (filtered.isNotEmpty) {
      return filtered[Random().nextInt(filtered.length)];
    }
    // Fallback to first order and change status
    final order = activeOrders.first;
    return DriverOrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      restaurantId: order.restaurantId,
      restaurantName: order.restaurantName,
      pickupLocation: order.pickupLocation,
      deliveryLocation: order.deliveryLocation,
      items: order.items,
      totalAmount: order.totalAmount,
      paymentMethod: order.paymentMethod,
      status: status,
      createdAt: order.createdAt,
      deliveryFee: order.deliveryFee,
      notes: order.notes,
    );
  }
}

