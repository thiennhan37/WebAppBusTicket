-- ============================================
-- TRIP SEARCH QUERIES DOCUMENTATION
-- ============================================

-- Query 1: Lấy danh sách trip dựa trên tỉnh khởi hành, tỉnh đến, và ngày đi
-- Điều kiện:
--   - Tỉnh khởi hành (arrivalProvince)
--   - Tỉnh đến (destinationProvince)
--   - Ngày đi (departureDate - chỉ so sánh ngày, không kể giờ)
-- Kết quả: ID chuyến, thời gian khởi hành, tên tuyến, tên công ty, giá vé
SELECT t.id,
       t.departure_time,
       r.name,
       bc.company_name,
       t.price
FROM trip t
JOIN route r ON t.route_id = r.id
JOIN bus_company bc ON t.bus_company_id = bc.id
WHERE r.arrival_id = 'DNG'  -- Tỉnh khởi hành (ví dụ: Đà Nẵng)
  AND r.destination_id = 'QNG'  -- Tỉnh đến (ví dụ: Quảng Ngãi)
  AND DATE(t.departure_time) = '2026-05-07'  -- Ngày đi
  AND t.status IN ('SCHEDULED', 'OPEN')
ORDER BY t.departure_time ASC;

-- ============================================

-- Query 2: Lấy số ghế available cho một chuyến xe cụ thể
-- Điều kiện:
--   - ID chuyến xe (tripId)
-- Kết quả: Số ghế còn trống
SELECT COUNT(ts.id)
FROM trip_seat ts
WHERE ts.trip_id = 'N2MNTNCEM6'  -- ID chuyến xe
  AND ts.status = 'AVAILABLE';

-- ============================================

-- Query 3: Lấy bến khởi hành của một tuyến đường
-- Điều kiện:
--   - ID tuyến đường (routeId)
-- Kết quả: Tên bến khởi hành
SELECT s.name
FROM stop s
JOIN route_stop rs ON s.id = rs.stop_id
WHERE rs.route_id = 23  -- ID tuyến đường
  AND rs.type = 'UP'
ORDER BY rs.id ASC
LIMIT 1;

-- ============================================

-- Query 4: Lấy bến đến của một tuyến đường
-- Điều kiện:
--   - ID tuyến đường (routeId)
-- Kết quả: Tên bến đến
SELECT s.name
FROM stop s
JOIN route_stop rs ON s.id = rs.stop_id
WHERE rs.route_id = 23  -- ID tuyến đường
  AND rs.type = 'DOWN'
ORDER BY rs.id DESC
LIMIT 1;

-- ============================================

-- HOẶC combine khách Query 3 và 4 thành một:
-- Lấy cả bến khởi hành và bến đến
SELECT
    MAX(CASE WHEN rs.type = 'UP' THEN s.name END) as departure_station,
    MAX(CASE WHEN rs.type = 'DOWN' THEN s.name END) as arrival_station
FROM route_stop rs
JOIN stop s ON rs.stop_id = s.id
WHERE rs.route_id = 23;

-- ============================================

-- Query 5: Lấy thông tin bus type (loại xe)
-- Điều kiện:
--   - ID chuyến xe (tripId)
-- Kết quả: Tên loại xe
SELECT bt.name
FROM bus_type bt
JOIN trip t ON bt.id = t.bus_type_id
WHERE t.id = 'N2MNTNCEM6';

-- ============================================

-- COMPLETE FULL SEARCH QUERY - Trả về tất cả thông tin cần thiết
-- Đây là query kết hợp mọi thứ lại
SELECT
    t.id,
    TIME_FORMAT(t.departure_time, '%H:%i') as departure_time,
    DATE_ADD(t.departure_time, INTERVAL 5 HOUR) as arrival_time_estimate,
    '5 giờ' as duration,
    (SELECT s.name FROM stop s
     JOIN route_stop rs ON s.id = rs.stop_id
     WHERE rs.route_id = r.id AND rs.type = 'UP'
     LIMIT 1) as departure_station,
    (SELECT s.name FROM stop s
     JOIN route_stop rs ON s.id = rs.stop_id
     WHERE rs.route_id = r.id AND rs.type = 'DOWN'
     LIMIT 1) as arrival_station,
    t.price,
    (SELECT COUNT(*) FROM trip_seat WHERE trip_id = t.id AND status = 'AVAILABLE') as available_seats,
    bc.company_name,
    bt.name as bus_type,
    4.5 as rating,  -- Default rating (update if Review table exists)
    0 as review_count  -- Default review count
FROM trip t
JOIN route r ON t.route_id = r.id
JOIN bus_company bc ON t.bus_company_id = bc.id
JOIN bus_type bt ON t.bus_type_id = bt.id
WHERE r.arrival_id = 'DNG'
  AND r.destination_id = 'QNG'
  AND DATE(t.departure_time) = '2026-05-07'
  AND t.status IN ('SCHEDULED', 'OPEN')
ORDER BY t.departure_time ASC;

-- ============================================
-- ENDPOINT USAGE
-- ============================================
-- POST /trip/search
-- {
--   "departureProvinceId": "DNG",
--   "arrivalProvinceId": "QNG",
--   "departureDate": "2026-05-07"
-- }

-- Response:
-- {
--   "code": 1000,
--   "message": "Success",
--   "data": [
--     {
--       "id": "N2MNTNCEM6",
--       "departureTime": "01:18",
--       "arrivalTime": "06:18",
--       "duration": "5 giờ",
--       "departureStation": "Bến xe Quảng Ngãi",
--       "arrivalStation": "Bến xe Miền Đông mới",
--       "price": 120000,
--       "availableSeats": 4,
--       "busCompanyName": "Xe Khách Sĩ Hà",
--       "busType": "Xe giường nằm phổ thông",
--       "rating": 4.5,
--       "reviewCount": 0
--     }
--   ]
-- }

