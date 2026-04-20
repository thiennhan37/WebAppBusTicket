-- KEYS[1]: compMakeOrderKey (Key kiểm tra staff)
-- KEYS[2]: tempOrderKey (Key của đơn hàng tạm)
-- KEYS[3 ... N]: Danh sách các key trip_seat_id (ghế)
-- ARGV[1]: orderId (Dùng để đối chiếu, đảm bảo không xóa nhầm key của người khác)

-- 1. Lấy giá trị hiện tại của compMakeOrderKey (Staff key)
local currentOrder = redis.call('GET', KEYS[1])

-- 2. Kiểm tra xem key này có đúng là do orderId hiện tại đang giữ hay không
if currentOrder == ARGV[1] then
    -- Nếu khớp, chứng tỏ TTL chưa hết và mình vẫn đang làm chủ các key này.
    -- Tiến hành xóa toàn bộ các KEYS truyền vào.
    -- Hàm unpack(KEYS) sẽ bung mảng KEYS thành các tham số rời rạc cho lệnh DEL để xóa hàng loạt trong 1 lần gọi.
    redis.call('DEL', KEYS[1], KEYS[2])
    for i = 3, #KEYS do
        local orderId = redis.call('GET', KEYS[i]);
        if(orderId == currentOrder) then
            redis.call('DEL', KEYS[i]);
        end
    end


    return 1 -- Rollback thành công
end

-- 3. Trường hợp key không tồn tại (đã hết TTL) hoặc đã bị order khác chiếm
return 0 -- Không làm gì cả để bảo vệ dữ liệu của người đến sau