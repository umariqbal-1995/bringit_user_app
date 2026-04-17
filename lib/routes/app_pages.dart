import 'package:get/get.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/send_otp_view.dart';
import '../modules/auth/views/verify_otp_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/restaurants/bindings/restaurant_binding.dart';
import '../modules/restaurants/views/restaurant_list_view.dart';
import '../modules/restaurants/views/restaurant_detail_view.dart';
import '../modules/stores/bindings/store_binding.dart';
import '../modules/stores/views/store_list_view.dart';
import '../modules/stores/views/store_detail_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/checkout/views/order_success_view.dart';
import '../modules/orders/bindings/order_binding.dart';
import '../modules/orders/bindings/track_order_binding.dart';
import '../modules/orders/views/order_list_view.dart';
import '../modules/orders/views/order_detail_view.dart';
import '../modules/orders/views/track_order_view.dart';
import '../modules/notifications/bindings/notification_binding.dart';
import '../modules/notifications/views/notification_view.dart';
import '../modules/favourites/bindings/favourites_binding.dart';
import '../modules/favourites/views/favourites_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/addresses_view.dart';
import '../modules/profile/views/add_address_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/user_setup/bindings/user_setup_binding.dart';
import '../modules/user_setup/views/user_setup_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(
      name: AppRoutes.userSetup,
      page: () => const UserSetupView(),
      binding: UserSetupBinding(),
    ),
    GetPage(
      name: AppRoutes.sendOtp,
      page: () => const SendOtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.restaurants,
      page: () => const RestaurantListView(),
      binding: RestaurantBinding(),
    ),
    GetPage(
      name: AppRoutes.restaurantDetail,
      page: () => const RestaurantDetailView(),
      binding: RestaurantBinding(),
    ),
    GetPage(
      name: AppRoutes.stores,
      page: () => const StoreListView(),
      binding: StoreBinding(),
    ),
    GetPage(
      name: AppRoutes.storeDetail,
      page: () => const StoreDetailView(),
      binding: StoreBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.orderSuccess,
      page: () => const OrderSuccessView(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderListView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.trackOrder,
      page: () => const TrackOrderView(),
      binding: TrackOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.favourites,
      page: () => const FavouritesView(),
      binding: FavouritesBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressesView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.addAddress,
      page: () => const AddAddressView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
  ];
}
