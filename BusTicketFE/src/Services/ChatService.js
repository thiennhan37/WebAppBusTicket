import api from "./api";

const ChatService = {
  getConversations({ busCompanyId, page = 0, size = 20, keyword = "" } = {}) {
    return api.get("/api/chat/conversations", {
      params: { busCompanyId, page, size, keyword: keyword || null },
    });
  },

  getMessages({ conversationId, page = 0, size = 20 } = {}) {
    return api.get(`/api/chat/conversations/${conversationId}/messages`, {
      params: { page, size },
    });
  },
};

export default ChatService;