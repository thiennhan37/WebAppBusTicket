import React, { useState } from "react";
import { Search, CheckCircle2, Clock, Loader2, Plus } from "lucide-react";
import Pagination from "../../components/other/Pagination";
import { getDisplayName, getInitials, formatTime, getUnreadCountForViewer } from "./ChatUtils";
import NewChatModal from "./NewChatModal";

const ChatSidebar = ({
  filterParams,
  onCustomerInfoChange,
  conversations,
  totalPages,
  totalElements,
  onPageChange,
  isFetching,
  apiStatus,
  activeConversationId,
  handleSelectConversation,
  onStartConversation,
  isStartingConversation = false,
  viewerRole = "COMPANY",
}) => {
  const [showNewChatModal, setShowNewChatModal] = useState(false);

  const handleSelectCustomer = async (customer) => {
    await onStartConversation(customer);
    setShowNewChatModal(false);
  };

  return (
    <aside className="flex h-full min-h-0 flex-col border-r border-slate-100 bg-white">
      <div className="border-b border-slate-100 p-4">
        <div className="relative flex gap-2 h-[40px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-blue-400" size={18} />
          <input
            value={filterParams.customerInfo}
            onChange={(event) => onCustomerInfoChange(event.target.value)}
            placeholder="Nhập tên/số điện thoại khách hàng"
            className="w-full rounded-2xl border border-slate-200 bg-slate-50 py-3 pl-10 pr-3 text-sm outline-none transition focus:border-blue-400 focus:bg-white focus:ring-4 focus:ring-blue-50"
          />
          <button
            type="button"
            onClick={() => setShowNewChatModal(true)}
            className="rounded-2xl bg-slate-900 px-3 text-white transition hover:bg-slate-700"
            title="Thêm hội thoại"
          >
            <Plus size={18} />
          </button>
        </div>

        <div className="mt-4 flex items-center justify-between text-xs text-slate-500">
          <span>{totalElements} hội thoại</span>
          <span className="inline-flex items-center gap-1">
            {isFetching ? (
              <>
                <Loader2 size={14} className="animate-spin text-blue-500" />
                Đang tải...
              </>
            ) : apiStatus === "success" ? (
              <>
                <CheckCircle2 size={14} className="text-emerald-500" />
                Đã tải API
              </>
            ) : (
              <>
                <Clock size={14} />
                Không tải được
              </>
            )}
          </span>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-3">
        {!conversations.length && !isFetching && (
          <div className="rounded-2xl border border-dashed border-slate-200 px-4 py-8 text-center text-sm text-slate-500">
            {filterParams.customerInfo ? "Không tìm thấy hội thoại phù hợp." : "Chưa có hội thoại nào."}
          </div>
        )}

        {conversations.map((conversation) => {
          const isActive = String(conversation.id) === String(activeConversationId);
          const name = getDisplayName(conversation);

          let lastMsgContent = "Chưa có tin nhắn";
          let prefix = "";
          const lastMsgObj = conversation.lastMessage;

          if (typeof lastMsgObj === "string") {
            lastMsgContent = lastMsgObj;
          } else if (lastMsgObj) {
            lastMsgContent = lastMsgObj.content || "Chưa có tin nhắn";
            if (lastMsgObj.senderRole === "CUSTOMER" || (!lastMsgObj.senderRole && lastMsgObj.id)) {
              prefix = "Khách hàng: ";
            } else if (lastMsgObj.senderRole) {
              prefix = "Nhà xe: ";
            }
          }

          const unreadCount = getUnreadCountForViewer(conversation, viewerRole);

          return (
            <button
              key={conversation.id}
              type="button"
              onClick={() => handleSelectConversation(conversation.id)}
              className={`mb-2 flex w-full gap-3 rounded-3xl p-3 text-left transition ${
                isActive ? "bg-blue-50 shadow-sm ring-1 ring-blue-100" : "hover:bg-slate-50"
              }`}
            >
              <div
                className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl text-sm font-bold ${
                  isActive ? "bg-blue-600 text-white" : "bg-slate-100 text-slate-600"
                }`}
              >
                {getInitials(name)}
              </div>
              <div className="min-w-0 flex-1">
                <div className="flex items-center justify-between gap-2">
                  <p className="truncate font-semibold text-slate-800">{name}</p>
                  <div className="flex items-center gap-2">
                    <span className="shrink-0 text-[11px] text-slate-400">{formatTime(conversation.lastMessageAt)}</span>
                    {unreadCount > 0 && (
                      <span className="ml-2 inline-flex items-center justify-center rounded-full bg-red-600 px-2 py-0.5 text-xs font-semibold text-white">
                        {unreadCount}
                      </span>
                    )}
                  </div>
                </div>
                <div className="mt-1 line-clamp-1 text-[14px] text-slate-500">
                  {prefix && <span className="font-medium text-slate-600">{prefix}</span>}
                  {lastMsgContent}
                </div>
              </div>
            </button>
          );
        })}
      </div>

      {totalPages > 1 && (
        <div className="border-t border-slate-100 p-3">
          <Pagination page={filterParams.page} totalPages={totalPages} onPageChange={onPageChange} />
        </div>
      )}

      {showNewChatModal && (
        <NewChatModal
          onClose={() => setShowNewChatModal(false)}
          onSelectCustomer={handleSelectCustomer}
          isStarting={isStartingConversation}
        />
      )}
    </aside>
  );
};

export default ChatSidebar;
