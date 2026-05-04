-- KEYS[1]: compMakeOrderKey (Key kiểm tra staff đang tạo đơn)
-- KEYS[2]: tempOrderKey (Key của đơn hàng tạm)
-- KEYS[3 ... N]: Danh sách các key trip_seat_id (ghế)
-- ARGV[1]: ttlSeconds (Thời gian sống - giây)
-- ARGV[2]: orderId (Dùng làm value cho ghế và staff)
-- ARGV[3 .. N]: List các trip-seat cho key orderID


redis.log(redis.LOG_WARNING, "Gia tri cua bien keys1 la: " .. tostring(KEYS[1]))
-- 1.1 Kiểm tra Staff đã có order đang xử lý chưa
if redis.call('EXISTS', KEYS[1]) == 1 then
    return -1 -- Tương ứng: BOOKING_ANOTHER_ORDER
end

-- 1.2 Kiểm tra OrderId đã tồn tại chưa (Dù xác suất thấp do generate UID)
if redis.call('EXISTS', KEYS[2]) == 1 then
    return -2 -- Tương ứng: ORDER_EXISTED
end

-- 1.3 Kiểm tra xem có ghế nào đã bị giữ chưa
for i = 3, #KEYS do
    if redis.call('EXISTS', KEYS[i]) == 1 then
        return -3 -- Tương ứng: TRIP_SEAT_BOOKED
    end
end



-- 2.1 Lưu trạng thái Staff đang xử lý
redis.call('SETEX', KEYS[1], ARGV[1], ARGV[2])

-- 2.2 Lưu Temp Order - Set các trip_seat
redis.call('SADD', KEYS[2], unpack(ARGV, 3))
redis.call('EXPIRE', KEYS[2], ARGV[1])

-- 2.3 Lưu danh sách ghế
for i = 3, #KEYS do
    redis.call('SETEX', KEYS[i], ARGV[1], ARGV[2])
end

return 1