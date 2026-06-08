export const normalizePageContent = (payload) => {
  const data = payload?.data?.result ?? payload?.result ?? payload;
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.content)) return data.content;
  if (Array.isArray(data?.data)) return data.data;
  return [];
};

export const buildFallbackConversations = (company, user) => [
  // {
  //   id: "1",
  //   customerName: "Khách hàng #1",
  //   lastMessage: "Nhập mã hội thoại thật để kết nối đúng phòng chat.",
  //   lastMessageAt: new Date().toISOString(),
  //   status: "OPEN",
  //   busCompanyName: company?.companyName,
  //   unreadCount: 0,
  //   isLocal: true,
  // },
  // {
  //   id: "2",
  //   customerName: "Khách hàng #2",
  //   lastMessage: `${user?.fullName || user?.email || "Nhân viên"} có thể cùng đồng nghiệp xem hội thoại này khi chọn cùng mã.`,
  //   lastMessageAt: new Date(Date.now() - 1000 * 60 * 8).toISOString(),
  //   status: "OPEN",
  //   busCompanyName: company?.companyName,
  //   unreadCount: 0,
  //   isLocal: true,
  // },
];

export const getDisplayName = (conversation) =>
  `${conversation?.customer?.fullName ? conversation?.customer?.fullName : ""}`;

export const formatTime = (value) => {
  if (!value) return "";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleString("vi-VN", {
    hour: "2-digit",
    minute: "2-digit",
    day: "2-digit",
    month: "2-digit",
  });
};

export const getInitials = (name) => {
  if (!name) return "KH";
  // if (name === undefined) console.log("name: undefined");
  const words = name.trim().split(/\s+/);
  return words.slice(-2).map((word) => word[0]).join("").toUpperCase();
};
