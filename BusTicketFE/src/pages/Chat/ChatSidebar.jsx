import React from "react";
import { Search, Plus, CheckCircle2, Clock } from "lucide-react";
import { getDisplayName, getInitials, formatTime } from "./ChatUtils";

const ChatSidebar = ({
  searchTerm,
  setSearchTerm,
  manualConversationId,
  setManualConversationId,
  handleAddManualConversation,
  filteredConversations,
  apiStatus,
  activeConversationId,
  handleSelectConversation,
}) => {
  return (
    <aside className="flex h-full min-h-0 flex-col border-r border-slate-100 bg-white">
      <div className="border-b border-slate-100 p-4">
        {/* <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
          <input
            value={searchTerm}
            onChange={(event) => setSearchTerm(event.target.value)}
            placeholder="Tìm khách hàng hoặc mã hội thoại"
            className="w-full rounded-2xl border border-slate-200 bg-slate-50 py-3 pl-10 pr-3 text-sm outline-none transition focus:border-blue-400 focus:bg-white focus:ring-4 focus:ring-blue-50"
          />
        </div> */}

        <div className="mt-2 flex gap-2 h-[40px]">
          <input
            value={manualConversationId}
            onChange={(event) => setManualConversationId(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === "Enter") handleAddManualConversation();
            }}
            placeholder="Nhập mã hội thoại"
            className="min-w-0 flex-1 rounded-2xl border border-slate-200 px-3 py-2 text-sm outline-none transition focus:border-blue-400 focus:ring-4 focus:ring-blue-50"
          />
          <button
            type="button"
            onClick={handleAddManualConversation}
            className="rounded-2xl bg-slate-900 px-3 text-white transition hover:bg-slate-700"
            title="Thêm hội thoại"
          >
            <Plus size={18} />
          </button>
        </div>

        <div className="mt-4 flex items-center justify-between text-xs text-slate-500">
          <span>{filteredConversations.length} hội thoại</span>
          <span className="inline-flex items-center gap-1">
            {apiStatus === "success" ? <CheckCircle2 size={14} className="text-emerald-500" /> : <Clock size={14} />}
            {apiStatus === "success" ? "Đã tải API" : "Có thể nhập tay"}
          </span>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-3">
        {filteredConversations.map((conversation) => {
          const isActive = String(conversation.id) === String(activeConversationId);
          const name = getDisplayName(conversation);
          
          let lastMsgContent = "Chưa có tin nhắn";
          let prefix = "";
          const lastMsgObj = conversation.lastMessage;
          
          if (typeof lastMsgObj === 'string') {
             lastMsgContent = lastMsgObj;
          } else if (lastMsgObj) {
             lastMsgContent = lastMsgObj.content || "Chưa có tin nhắn";
             if (lastMsgObj.senderRole === "CUSTOMER" || (!lastMsgObj.senderRole && lastMsgObj.id)) {
               prefix = "Khách hàng: ";
             } else if (lastMsgObj.senderRole) {
               prefix = "Nhà xe: ";
             }
          }

          // Calculate unread counts (from backend: unreadCustomerCount, unreadCompanyCount)
          const unreadCustomer = Number(conversation.unreadCustomerCount || 0);
          const unreadCompany = Number(conversation.unreadCompanyCount || 0);
          const totalUnread = unreadCustomer + unreadCompany;
          
          return (
            <button
              key={conversation.id}
              type="button"
              onClick={() => handleSelectConversation(conversation.id)}
              className={`mb-2 flex w-full gap-3 rounded-3xl p-3 text-left transition ${
                isActive ? "bg-blue-50 shadow-sm ring-1 ring-blue-100" : "hover:bg-slate-50"
              }`}
            >
              <div className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl text-sm font-bold ${isActive ? "bg-blue-600 text-white" : "bg-slate-100 text-slate-600"}`}>
                {getInitials(name)}
              </div>
              <div className="min-w-0 flex-1">
                <div className="flex items-center justify-between gap-2">
                  <p className="truncate font-semibold text-slate-800">{name}</p>
                    <div className="flex items-center gap-2">
                    <span className="shrink-0 text-[11px] text-slate-400">{formatTime(conversation.lastMessageAt)}</span>
                      {totalUnread > 0 && (
                      <span className="ml-2 inline-flex items-center justify-center rounded-full bg-red-600 px-2 py-0.5 text-xs font-semibold text-white">
                        {totalUnread}
                      </span>
                    )}
                  </div>
                </div>
                <div className="mt-1 text-[14px] text-slate-500 line-clamp-1">
                  {prefix && <span className="font-medium text-slate-600">{prefix}</span>}
                  {lastMsgContent}
                </div>
              </div>
            </button>
          );
        })}
      </div>
    </aside>
  );
};

export default ChatSidebar;
