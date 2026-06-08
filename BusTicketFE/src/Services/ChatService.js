import api from "./api";

const ChatService = {
  getConversations({ customerInfo = "", companyInfo = "", page = 0, size = 10 } = {}) {
    return api.get("/api/chat/conversations", {
      params: {
        customerInfo: customerInfo || null,
        companyInfo: companyInfo || null,
        page,
        size,
      },
    });
  },

  getMessages({ conversationId, page = 0, size = 20 } = {}) {
    return api.get(`/api/chat/conversations/${conversationId}/messages`, {
      params: { page, size },
    });
  },
};

export default ChatService;