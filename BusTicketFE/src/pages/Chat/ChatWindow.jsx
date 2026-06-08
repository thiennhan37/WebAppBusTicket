import React, { useCallback, useEffect, useLayoutEffect, useRef } from "react";
import { Loader2, MessageCircle, MessagesSquare, UserRound, Send } from "lucide-react";
import { getDisplayName, getInitials, formatTime } from "./ChatUtils";
import { toVN } from "../../utils/translate";

const SCROLL_BOTTOM_THRESHOLD = 120;

const ChatWindow = ({
  activeConversation,
  activeConversationId,
  activeMessages,
  activeMessagesMeta,
  currentUserId,
  messagesEndRef,
  messageInput,
  setMessageInput,
  handleSendMessage,
  onLoadOlderMessages,
  connectionStatus,
}) => {
  const scrollContainerRef = useRef(null);
  const topSentinelRef = useRef(null);
  const messagesMetaRef = useRef(activeMessagesMeta);
  const initialScrollDoneRef = useRef(new Set());
  const scrollAnchorRef = useRef(null);
  const isRestoringScrollRef = useRef(false);
  const canTriggerLoadRef = useRef(true);
  const previousMessageCountRef = useRef(0);
  const previousFirstMessageIdRef = useRef(null);
  const previousLastMessageIdRef = useRef(null);

  messagesMetaRef.current = activeMessagesMeta;

  const isNearBottom = useCallback(() => {
    const container = scrollContainerRef.current;
    if (!container) return true;
    return container.scrollHeight - container.scrollTop - container.clientHeight < SCROLL_BOTTOM_THRESHOLD;
  }, []);

  const scrollToBottom = useCallback((behavior = "auto") => {
    messagesEndRef.current?.scrollIntoView({ behavior });
  }, [messagesEndRef]);

  const captureScrollAnchor = useCallback(() => {
    const container = scrollContainerRef.current;
    if (!container) return;

    const anchor = container.querySelector("[data-message-id]");
    if (!anchor) return;

    scrollAnchorRef.current = {
      id: anchor.dataset.messageId,
      offsetFromTop: anchor.getBoundingClientRect().top - container.getBoundingClientRect().top,
    };
  }, []);

  const restoreScrollAnchor = useCallback(() => {
    const container = scrollContainerRef.current;
    const anchorData = scrollAnchorRef.current;
    if (!container || !anchorData) return false;

    const anchor = container.querySelector(`[data-message-id="${anchorData.id}"]`);
    if (!anchor) {
      scrollAnchorRef.current = null;
      canTriggerLoadRef.current = true;
      return false;
    }

    isRestoringScrollRef.current = true;
    const nextOffset = anchor.getBoundingClientRect().top - container.getBoundingClientRect().top;
    container.scrollTop += nextOffset - anchorData.offsetFromTop;
    scrollAnchorRef.current = null;

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        isRestoringScrollRef.current = false;
        canTriggerLoadRef.current = true;
      });
    });

    return true;
  }, []);

  useEffect(() => {
    initialScrollDoneRef.current.clear();
    previousMessageCountRef.current = 0;
    previousFirstMessageIdRef.current = null;
    previousLastMessageIdRef.current = null;
    scrollAnchorRef.current = null;
    isRestoringScrollRef.current = false;
    canTriggerLoadRef.current = true;
  }, [activeConversationId]);

  useEffect(() => {
    const container = scrollContainerRef.current;
    const sentinel = topSentinelRef.current;
    if (!container || !sentinel || !onLoadOlderMessages) return undefined;

    const observer = new IntersectionObserver(
      (entries) => {
        const [entry] = entries;
        const meta = messagesMetaRef.current;

        if (
          !entry?.isIntersecting ||
          isRestoringScrollRef.current ||
          !canTriggerLoadRef.current ||
          !meta?.hasMore ||
          meta.loading ||
          meta.loadingMore
        ) {
          return;
        }

        canTriggerLoadRef.current = false;
        captureScrollAnchor();
        onLoadOlderMessages();
      },
      { root: container, rootMargin: "24px 0px 0px 0px", threshold: 0 }
    );

    observer.observe(sentinel);
    return () => observer.disconnect();
  }, [activeConversationId, captureScrollAnchor, onLoadOlderMessages]);

  useLayoutEffect(() => {
    const container = scrollContainerRef.current;
    const previousCount = previousMessageCountRef.current;
    const previousFirstId = previousFirstMessageIdRef.current;
    const previousLastId = previousLastMessageIdRef.current;
    const currentCount = activeMessages.length;
    const currentFirstId = activeMessages[0]?.id ?? null;
    const currentLastId = activeMessages[currentCount - 1]?.id ?? null;

    if (!currentCount) {
      previousMessageCountRef.current = 0;
      previousFirstMessageIdRef.current = null;
      previousLastMessageIdRef.current = null;
      return;
    }

    const isPrepend =
      currentCount > previousCount &&
      currentFirstId !== previousFirstId &&
      currentLastId === previousLastId;

    if (isPrepend) {
      if (!restoreScrollAnchor()) {
        canTriggerLoadRef.current = true;
      }
    } else if (!initialScrollDoneRef.current.has(activeConversationId)) {
      scrollToBottom("auto");
      initialScrollDoneRef.current.add(activeConversationId);
    } else if (currentCount > previousCount && !isPrepend && isNearBottom()) {
      scrollToBottom("auto");
    }

    previousMessageCountRef.current = currentCount;
    previousFirstMessageIdRef.current = currentFirstId;
    previousLastMessageIdRef.current = currentLastId;
  }, [activeConversationId, activeMessages, isNearBottom, restoreScrollAnchor, scrollToBottom]);

  const showInitialLoading = activeMessagesMeta?.loading && !activeMessages.length;
  const showEmptyState = !activeMessages.length && !activeMessagesMeta?.loading;

  return (
    <main className="flex h-full min-h-0 flex-col bg-slate-50/60">
      <div className="flex items-center justify-between border-b border-slate-100 bg-white px-6 py-4">
        <div className="flex items-center gap-3">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-600 text-sm font-bold text-white">
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
            </div>
          </div>
        </div>
      </div>

      <div
        ref={scrollContainerRef}
        className="relative flex-1 overflow-y-auto overflow-anchor-none px-6 py-5 [overflow-anchor:none]"
      >
        {activeMessagesMeta?.loadingMore && (
          <div className="pointer-events-none absolute inset-x-0 top-0 z-10 flex justify-center bg-gradient-to-b from-slate-50/95 via-slate-50/80 to-transparent px-6 pb-6 pt-3">
            <div className="inline-flex items-center gap-2 rounded-full bg-white/95 px-3 py-1.5 text-xs text-slate-500 shadow-sm backdrop-blur-sm">
              <Loader2 size={14} className="animate-spin text-blue-500" />
              <span>Đang tải...</span>
            </div>
          </div>
        )}

        {showInitialLoading && (
          <div className="flex items-center justify-center gap-2 py-10 text-sm text-slate-500">
            <Loader2 size={18} className="animate-spin text-blue-500" />
            Đang tải tin nhắn...
          </div>
        )}

        {showEmptyState && (
          <div className="mx-auto mt-20 max-w-md rounded-3xl border border-dashed border-slate-200 bg-white p-8 text-center text-slate-500">
            <MessagesSquare className="mx-auto mb-4 text-blue-500" size={42} />
            <h3 className="font-bold text-slate-800">Chưa có tin nhắn trong phiên này</h3>
          </div>
        )}

        <div className="space-y-4">
          <div ref={topSentinelRef} className="h-px w-full shrink-0" aria-hidden="true" />

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
              <div
                key={message.id || `${message.sentAt}-${index}`}
                data-message-id={message.id || `${message.sentAt}-${index}`}
                className={`flex gap-3 ${isRightSide ? "justify-end" : "justify-start"}`}
              >
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
