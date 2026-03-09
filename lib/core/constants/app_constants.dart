class AppConstants {
  AppConstants._();

  static const String appName = 'HeartLink';
  static const String appTagline = '설레는 만남의 시작';

  // Premium Plans
  static const int freeMaxLikes = 30;
  static const int goldMaxLikes = 100;
  static const int platinumMaxLikes = 300;

  static const int goldPrice = 11900;
  static const int platinumPrice = 22900;

  static const int goldRewindsPerDay = 5;
  static const int platinumRewindsPerDay = 15;

  static const int goldSuperLikesPerDay = 3;
  static const int platinumSuperLikesPerDay = 10;

  static const int goldAiAnalysisPerDay = 10;
  static const int platinumAiAnalysisPerDay = 30;

  static const int goldIcebreakerPerMatch = 3;
  static const int platinumIcebreakerPerMatch = 10;

  static const int goldBoostsPerMonth = 1;
  static const int platinumBoostsPerMonth = 3;

  // Super Like
  static const int maxSuperLikesPerDay = 3;

  // Age
  static const int minAge = 18;
  static const int maxAge = 50;

  // Location
  static const double defaultMaxDistanceKm = 50.0;

  // Interests
  static const List<String> interestOptions = [
    '여행', '운동', '음악', '영화', '독서', '요리',
    '게임', '사진', '패션', '카페', '등산', '반려동물',
  ];
}
