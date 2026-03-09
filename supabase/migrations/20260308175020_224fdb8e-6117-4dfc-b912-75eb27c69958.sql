
-- Add location columns to profiles
ALTER TABLE public.profiles 
  ADD COLUMN latitude double precision,
  ADD COLUMN longitude double precision;

-- Create a function to calculate distance between two points (Haversine formula, returns km)
CREATE OR REPLACE FUNCTION public.calculate_distance(
  lat1 double precision, lng1 double precision,
  lat2 double precision, lng2 double precision
)
RETURNS double precision
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT 6371 * acos(
    LEAST(1.0, 
      cos(radians(lat1)) * cos(radians(lat2)) * cos(radians(lng2) - radians(lng1)) +
      sin(radians(lat1)) * sin(radians(lat2))
    )
  )
$$;

-- Create a function to get nearby profiles sorted by distance
CREATE OR REPLACE FUNCTION public.get_nearby_profiles(
  user_lat double precision,
  user_lng double precision,
  max_distance_km double precision DEFAULT 100,
  age_min integer DEFAULT 18,
  age_max integer DEFAULT 70,
  gender_filter text DEFAULT NULL,
  exclude_user_ids uuid[] DEFAULT '{}'
)
RETURNS TABLE (
  id uuid,
  user_id uuid,
  display_name text,
  bio text,
  age integer,
  gender public.gender_type,
  looking_for public.gender_type,
  city text,
  avatar_url text,
  photos text[],
  interests text[],
  onboarding_complete boolean,
  distance_km double precision,
  latitude double precision,
  longitude double precision,
  min_age integer,
  max_age integer,
  created_at timestamptz,
  updated_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT 
    p.id, p.user_id, p.display_name, p.bio, p.age, p.gender, p.looking_for,
    p.city, p.avatar_url, p.photos, p.interests, p.onboarding_complete,
    CASE 
      WHEN p.latitude IS NOT NULL AND p.longitude IS NOT NULL 
      THEN public.calculate_distance(user_lat, user_lng, p.latitude, p.longitude)
      ELSE 99999
    END as distance_km,
    p.latitude, p.longitude, p.min_age, p.max_age, p.created_at, p.updated_at
  FROM public.profiles p
  WHERE p.onboarding_complete = true
    AND NOT (p.user_id = ANY(exclude_user_ids))
    AND p.age >= age_min
    AND p.age <= age_max
    AND (gender_filter IS NULL OR p.gender::text = gender_filter)
    AND (
      p.latitude IS NULL OR p.longitude IS NULL OR
      public.calculate_distance(user_lat, user_lng, p.latitude, p.longitude) <= max_distance_km
    )
  ORDER BY distance_km ASC
  LIMIT 50
$$;
