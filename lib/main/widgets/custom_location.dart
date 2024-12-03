import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CustomLocation{

  CustomLocation();

  Future<String> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        // Placemark 객체에서 필요한 정보 추출
        final placemark = placemarks.first;
        return '${placemark.locality} ${placemark.subLocality}'; // 예: 강동구 암사동
      }
      return '주소를 찾을 수 없습니다.';
    } catch (e) {
      print('주소 변환 실패: $e');
      return '주소 변환 실패';
    }
  }

  Future<String> fetchCurrentLocationAndAddress() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('permissions are denied');
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      return getAddressFromLatLng(position);
    } catch (e) {
      print('위치 정보 가져오기 실패: $e');
      return "위치 정보 가져오기 실패";
    }
  }

  Future<Position?> fetchCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('permissions are denied');
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      print('위치 정보 가져오기 실패: $e');
      return null;
    }
  }
}