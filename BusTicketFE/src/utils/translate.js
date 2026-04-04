const object = {
    "MANAGER": "Quản lí",
    "STAFF": "Nhân viên", 
    "CUSTOMER": "Khách hàng", 
    "ADMIN": "Quản trị viên", 
    "ACTIVE": "Đang hoạt động", 
    "BLOCKED": "Đã khóa",
    "ALL": "Tất Cả", 
};

const reverseObject = Object.fromEntries(
    Object.entries(object).map(([key, value]) => [value, key])
);

const toVN = (eng) => object[eng];

const toEng = (vnm) => reverseObject[vnm];

export {toVN, toEng};