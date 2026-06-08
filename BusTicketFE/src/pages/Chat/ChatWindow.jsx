import React from "react";
import { MessageCircle, Building2, MessagesSquare, UserRound, Send } from "lucide-react";
import { getDisplayName, getInitials, formatTime } from "./ChatUtils";
import { toVN } from "../../utils/translate";

const ChatWindow = ({
  activeConversation,
  company,
  activeConversationId,
  activeMessages,
  currentUserId,
  messagesEndRef,
  messageInput,
  setMessageInput,
  handleSendMessage,
  connectionStatus,
}) => {
  return (
    <main className="flex h-full min-h-0 flex-col bg-slate-50/60">
      <div className="flex items-center justify-between border-b border-slate-100 bg-white px-6 py-4">
        <div className="flex items-center gap-3">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-600 text-sm font-bold text-white">
            {/* {console.log(activeConversation)} */}
            {getInitials(getDisplayName(activeConversation))}
          </div>
          <div>
            <h2 className="font-bold text-slate-900">
              {getDisplayName(activeConversation)} - {activeConversation?.customer?.phone}
            </h2>
            <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-slate-500">
              <span className="inline-flex items-center gap-1 rounded-full bg-slate-100 px-2 py-1">
                <MessageCircle size={13} /> Hội thoại #{activeConversationId}
              </span>
              {/* <span className="inline-flex items-center gap-1 rounded-full bg-blue-50 px-2 py-1 text-blue-600">
                <Building2 size={13} /> {company?.companyName || activeConversation?.busCompanyName || "Nhà xe"}
              </span> */}
            </div>
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-6 py-5">
        {!activeMessages.length && (
          <div className="mx-auto mt-20 max-w-md rounded-3xl border border-dashed border-slate-200 bg-white p-8 text-center text-slate-500">
            <MessagesSquare className="mx-auto mb-4 text-blue-500" size={42} />
            <h3 className="font-bold text-slate-800">Chưa có tin nhắn trong phiên này</h3>
          </div>
        )}

        <div className="space-y-4">
          {activeMessages.map((message, index) => {
            const isMine = String(message.senderId) === String(currentUserId);
            const isCustomer = message.senderRole === "CUSTOMER" || (!message.senderRole && !isMine);
            const isSameCompany = !isMine && !isCustomer;
            const isRightSide = isMine || isSameCompany;

            let bgClass = "bg-white text-slate-700";
            let timeColorClass = "text-slate-400";
            let senderLabel = "";

            if (isMine) {
              bgClass = "bg-blue-600 text-white";
              timeColorClass = "text-blue-100";
              senderLabel = "Bạn";
            } else if (isSameCompany) {
              bgClass = "bg-emerald-600 text-white";
              timeColorClass = "text-emerald-100";
              senderLabel = message.senderId ? `${toVN(message.senderRole)} (${message.senderId})` : "Nhân viên khác";
            } else {
              senderLabel = message.senderId || "";
            }

            return (
              <div key={message.id || `${message.sentAt}-${index}`} className={`flex gap-3 ${isRightSide ? "justify-end" : "justify-start"}`}>
                {!isRightSide && (
                  <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-white text-slate-500 shadow-sm">
                    <UserRound size={17} />
                  </div>
                )}
                <div className={`max-w-[72%] rounded-3xl px-4 py-3 shadow-sm ${bgClass}`}>
                  <p className="whitespace-pre-wrap break-words text-sm leading-6">{message.content}</p>
                  <div className={`mt-2 text-[11px] ${timeColorClass}`}>
                    {formatTime(message.sentAt)} {senderLabel ? `• ${senderLabel}` : ""}
                  </div>
                </div>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>
      </div>

      <form onSubmit={handleSendMessage} className="border-t border-slate-100 bg-white p-4">
        <div className="flex items-end gap-3 rounded-3xl border border-slate-200 bg-slate-50 p-2 transition focus-within:border-blue-400 focus-within:bg-white focus-within:ring-4 focus-within:ring-blue-50">
          <textarea
            value={messageInput}
            onChange={(event) => setMessageInput(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault();
                handleSendMessage(event);
              }
            }}
            rows={1}
            placeholder="Nhập nội dung trả lời khách hàng..."
            className="max-h-32 min-h-11 flex-1 resize-none bg-transparent px-3 py-3 text-sm outline-none"
          />
          <button
            type="submit"
            disabled={!messageInput.trim() || connectionStatus !== "connected"}
            className="inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-blue-600 text-white transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-slate-300"
          >
            <Send size={18} />
          </button>
        </div>
      </form>
    </main>
  );
};

export default ChatWindow;
