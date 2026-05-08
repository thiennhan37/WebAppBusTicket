-- ============================================
-- UPDATE ROUTE TABLE: ADD DURATION_MINUTES
-- ============================================

-- Thêm cột duration_minutes vào bảng route
ALTER TABLE route ADD COLUMN duration_minutes INT DEFAULT 300;

-- Update dữ liệu mẫu cho các route hiện có
-- Giả sử thời gian hành trình trung bình là 5 giờ (300 phút)
UPDATE route SET duration_minutes = 300 WHERE duration_minutes IS NULL;

-- Ví dụ update cụ thể cho từng route:
-- Route từ Quảng Ngãi đến TP.HCM: khoảng 5-6 giờ
UPDATE route SET duration_minutes = 330 WHERE arrival_id = 'QNG' AND destination_id = 'HCM';

-- Route từ TP.HCM đến Quảng Ngãi: khoảng 5-6 giờ
UPDATE route SET duration_minutes = 330 WHERE arrival_id = 'HCM' AND destination_id = 'QNG';

-- Route từ Hà Nội đến Sapa: khoảng 6-7 giờ
UPDATE route SET duration_minutes = 420 WHERE arrival_id = 'HNO' AND destination_id = 'XXX'; -- Thay XXX bằng ID tỉnh Sapa nếu có

-- ============================================
-- VERIFY DATA
-- ============================================

-- Kiểm tra dữ liệu đã được thêm
SELECT r.id, r.name, p1.name as from_province, p2.name as to_province, r.duration_minutes
FROM route r
JOIN province p1 ON r.arrival_id = p1.id
JOIN province p2 ON r.destination_id = p2.id;

-- ============================================
-- TEST QUERY
-- ============================================

-- Test tìm chuyến xe từ Quảng Ngãi đến TP.HCM
SELECT t.id, t.departure_time,
       DATE_ADD(t.departure_time, INTERVAL r.duration_minutes MINUTE) as estimated_arrival,
       r.duration_minutes / 60 as hours, r.duration_minutes % 60 as minutes,
       CONCAT(r.duration_minutes / 60, 'h ', r.duration_minutes % 60, 'm') as duration_formatted
FROM trip t
JOIN route r ON t.route_id = r.id
WHERE r.arrival_id = 'QNG'
  AND r.destination_id = 'HCM'
  AND DATE(t.departure_time) = '2026-05-07'
  AND t.status IN ('SCHEDULED', 'OPEN');
