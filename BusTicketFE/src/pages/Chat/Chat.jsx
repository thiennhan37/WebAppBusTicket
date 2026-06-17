import { useCallback, useContext, useEffect, useMemo, useRef, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { keepPreviousData, useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Client } from "@stomp/stompjs";
import { AlertCircle, MessagesSquare, RefreshCw, Wifi, WifiOff } from "lucide-react";
import { toast } from "sonner";
import AuthContext from "../../context/AuthContext";
import ChatService from "../../Services/ChatService";
import { normalizePagedResult } from "./ChatUtils";
import ChatSidebar from "./ChatSidebar";
import ChatWindow from "./ChatWindow";

const MESSAGE_PAGE_SIZE = 20;

const createEmptyMessagesMeta = () => ({
  page: -1,
  totalPages: 0,
  hasMore: false,
  loading: false,
  loadingMore: false,
});

const mapConversations = (conversations = []) =>
  conversations.map((conv) => ({
    ...conv,
    unreadCustomerCount: conv.unreadCustomerCount ?? conv.lastMessage?.unreadCustomerCount ?? 0,
    unreadCompanyCount: conv.unreadCompanyCount ?? conv.lastMessage?.unreadCompanyCount ?? 0,
  }));

const isProduction = import.meta.env.PROD;

// 2. Ép URL chạy qua Domain thay vì chạy qua IP trực tiếp khi lên Vercel
const API_HTTP_URL = isProduction 
  ? `${window.location.protocol}//${window.location.host}/vexedat` // Kết quả trên Vercel: https://bus-ticket...vercel.app/vexedat
  : import.meta.env.VITE_FULL_API_URL;

const API_WS_URL = isProduction
  ? "wss://api.bus-ticket.xyz/vexedat"
  : import.meta.env.VITE_FULL_API_URL.replace(/^http/, "ws");
  
const WEBSOCKET_PATH = "/ws";
const SEND_DESTINATION = "/app/chat.send";
const TOPIC_PREFIX = "/topic/conversation/";

const Chat = () => {
  const { user, company } = useContext(AuthContext);
  const queryClient = useQueryClient();
  const [conversations, setConversations] = useState([]);
  const [activeConversationId, setActiveConversationId] = useState("");
  const [messagesByConversation, setMessagesByConversation] = useState({});
  const [messagesMetaByConversation, setMessagesMetaByConversation] = useState({});
  const [messageInput, setMessageInput] = useState("");
  const [connectionStatus, setConnectionStatus] = useState("disconnected");
  const [lastError, setLastError] = useState("");
  const [searchParams, setSearchParams] = useSearchParams();
  const stompClientRef = useRef(null);
  // Map of conversationId -> STOMP subscription. We subscribe to all visible conversations
  // so previews update even when a different conversation is active.
  const conversationSubscriptionsRef = useRef({});
  const activeConversationIdRef = useRef(activeConversationId);
  const messagesEndRef = useRef(null);

  const accessToken = useMemo(() => localStorage.getItem("accessToken") || "", []);
  const currentUserId = user?.id || user?.userId || user?.email || user?.phone || "";

  const getFilterParams = () => ({
    page: Number(searchParams.get("page")) || 1,
    customerInfo: searchParams.get("customerInfo") || "",
  });

  const filterParams = getFilterParams();

  const updateFilterParams = (updater) => {
    setSearchParams({
      page: String(updater.page || 1),
      customerInfo: updater.customerInfo ?? "",
    });
  };

  const onPageChange = (newPage) => {
    updateFilterParams({ ...filterParams, page: newPage });
  };

  const onCustomerInfoChange = (customerInfo) => {
    updateFilterParams({ ...filterParams, customerInfo, page: 1 });
  };

  const {
    data: conversationResult,
    isFetching: isFetchingConversations,
    isError: isConversationError,
  } = useQuery({
    queryKey: ["chatConversations", filterParams],
    queryFn: async () => {
      const response = await ChatService.getConversations({
        customerInfo: filterParams.customerInfo,
        page: filterParams.page > 0 ? filterParams.page - 1 : 0,
      });
      return normalizePagedResult(response);
    },
    placeholderData: keepPreviousData,
    staleTime: 0,
  });

  const totalPages = conversationResult?.page?.totalPages || 1;
  const totalElements = conversationResult?.page?.totalElements ?? conversations.length;
  const apiStatus = isConversationError ? "fallback" : "success";

  useEffect(() => {
    activeConversationIdRef.current = activeConversationId;
  }, [activeConversationId]);

  useEffect(() => {
    if (!conversationResult) return;

    const mapped = mapConversations(conversationResult.content);
    setConversations(mapped);
    setActiveConversationId((current) => {
      if (!mapped.length) return "";
      if (!mapped.some((conversation) => String(conversation.id) === String(current))) {
        return String(mapped[0].id);
      }
      return current;
    }); 
  }, [conversationResult]);
  const activeConversation = useMemo(
    () => conversations.find((conversation) => String(conversation.id) === String(activeConversationId)),
    [activeConversationId, conversations]
  );

  const activeMessages = useMemo(
    () => messagesByConversation[activeConversationId] || [],
    [activeConversationId, messagesByConversation]
  );

  const activeMessagesMeta = useMemo(
    () => messagesMetaByConversation[activeConversationId] || createEmptyMessagesMeta(),
    [activeConversationId, messagesMetaByConversation]
  );

  const upsertConversationPreview = useCallback((message) => {    setConversations((current) => {
      const exists = current.some((conversation) => String(conversation.id) === String(message.conversationId));
      const updated = current.map((conversation) => {
        if (String(conversation.id) !== String(message.conversationId)) return conversation;
        const isActive = String(message.conversationId) === String(activeConversationId);
        // Prefer authoritative counts from message when available, otherwise increment based on senderRole
        const unreadCustomerCount = isActive
          ? 0
          : (message.unreadCustomerCount != null
              ? message.unreadCustomerCount
              : (conversation.unreadCustomerCount || 0) + (message.senderRole === 'COMPANY' ? 1 : 0));
        const unreadCompanyCount = isActive
          ? 0
          : (message.unreadCompanyCount != null
              ? message.unreadCompanyCount
              : (conversation.unreadCompanyCount || 0) + (message.senderRole === 'CUSTOMER' ? 1 : 0));

        return {
          ...conversation,
          lastMessage: message,
          lastMessageAt: message.sentAt,
          unreadCustomerCount,
          unreadCompanyCount,
        };
      });

      if (exists) return updated;

      const isActiveNew = String(message.conversationId) === String(activeConversationId);
      return [
        {
          id: message.conversationId,
          customerName: `Khách hàng #${message.conversationId}`,
          lastMessage: message,
          lastMessageAt: message.sentAt,
          status: "OPEN",
          unreadCustomerCount: isActiveNew ? 0 : (message.unreadCustomerCount ?? (message.senderRole === 'COMPANY' ? 1 : 0)),
          unreadCompanyCount: isActiveNew ? 0 : (message.unreadCompanyCount ?? (message.senderRole === 'CUSTOMER' ? 1 : 0)),
        },
        ...updated,
      ];
    });
  }, [activeConversationId]);

  const addMessage = useCallback((message) => {
    if (!message?.conversationId) return;
    setMessagesByConversation((current) => {
      const key = String(message.conversationId);
      const previousMessages = current[key] || [];
      if (message.id && previousMessages.some((item) => item.id === message.id)) return current;
      return { ...current, [key]: [...previousMessages, message] };
    });
    upsertConversationPreview(message);
  }, [upsertConversationPreview]);

  const subscribeToConversation = useCallback(
    (conversationId) => {
      const client = stompClientRef.current;
      if (!client?.connected || !conversationId) return;
      const key = String(conversationId);
      if (conversationSubscriptionsRef.current[key]) return; // already subscribed

      try {
        const sub = client.subscribe(
          `${TOPIC_PREFIX}${conversationId}`,
          (frame) => {
            try {
              const message = JSON.parse(frame.body);
              addMessage(message);
            } catch (error) {
              console.error("Không thể đọc tin nhắn websocket", error);
            }
          },
          { ack: "auto" }
        );
        conversationSubscriptionsRef.current[key] = sub;
      } catch (err) {
        console.warn("Không thể subscribe topic", conversationId, err);
      }
    },
    [addMessage]
  );

  const unsubscribeFromConversation = useCallback((conversationId) => {
    const key = String(conversationId);
    const sub = conversationSubscriptionsRef.current[key];
    if (!sub) return;
    try {
      sub.unsubscribe();
    } catch (e) {
      // ignore
    }
    delete conversationSubscriptionsRef.current[key];
  }, []);

  const unsubscribeAllConversations = useCallback(() => {
    Object.keys(conversationSubscriptionsRef.current).forEach((key) => {
      try {
        conversationSubscriptionsRef.current[key]?.unsubscribe();
      } catch (e) {
        // ignore
      }
    });
    conversationSubscriptionsRef.current = {};
  }, []);

  const connectSocket = useCallback(() => {
    if (!accessToken) {
      setLastError("Không tìm thấy access token. Vui lòng đăng nhập lại để dùng webChat.");
      setConnectionStatus("error");
      return;
    }

    if (stompClientRef.current?.active) {
      return;
    }

    setConnectionStatus("connecting");
    setLastError("");

    const client = new Client({
      brokerURL: `${API_WS_URL}${WEBSOCKET_PATH}?token=${encodeURIComponent(accessToken)}`,
      connectHeaders: {},
      reconnectDelay: 5000,
      heartbeatIncoming: 10000,
      heartbeatOutgoing: 10000,
      onConnect: () => {
        setConnectionStatus("connected");
        // once connected, we'll subscribe to all conversations in a dedicated effect
      },
      onStompError: (frame) => {
        setConnectionStatus("error");
        setLastError(frame.body || frame.headers?.message || "STOMP trả về lỗi kết nối.");
      },
      onWebSocketError: () => {
        setConnectionStatus("error");
        setLastError("Không thể kết nối WebSocket. Kiểm tra BusTicketBE và token đăng nhập.");
      },
      onWebSocketClose: () => {
        // clear any tracked subscriptions
        unsubscribeAllConversations();
        setConnectionStatus((currentStatus) => (currentStatus === "error" ? "error" : "disconnected"));
      },
    });

    stompClientRef.current = client;
    client.activate();
  }, [accessToken, subscribeToConversation, unsubscribeAllConversations]);

  const disconnectSocket = useCallback(() => {
    unsubscribeAllConversations();

    const client = stompClientRef.current;
    stompClientRef.current = null;
    if (client?.active) {
      client.deactivate();
    }
    setConnectionStatus("disconnected");
  }, [unsubscribeAllConversations]);

  const loadMessages = useCallback(async (conversationId, { page = 0, prepend = false } = {}) => {
    if (!conversationId) return;

    const key = String(conversationId);
    setMessagesMetaByConversation((current) => ({
      ...current,
      [key]: {
        ...(current[key] || createEmptyMessagesMeta()),
        loading: !prepend,
        loadingMore: prepend,
      },
    }));

    try {
      const response = await ChatService.getMessages({
        conversationId,
        page,
        size: MESSAGE_PAGE_SIZE,
      });
      const { content, page: pageInfo } = normalizePagedResult(response);

      setMessagesByConversation((current) => {
        const previousMessages = current[key] || [];
        if (prepend) {
          const existingIds = new Set(previousMessages.map((item) => item.id).filter(Boolean));
          const olderMessages = content.filter((item) => !item.id || !existingIds.has(item.id));
          return { ...current, [key]: [...olderMessages, ...previousMessages] };
        }
        return { ...current, [key]: content };
      });

      setMessagesMetaByConversation((current) => ({
        ...current,
        [key]: {
          page: pageInfo.number,
          totalPages: pageInfo.totalPages,
          hasMore: pageInfo.number + 1 < pageInfo.totalPages,
          loading: false,
          loadingMore: false,
        },
      }));
    } catch (error) {
      setMessagesMetaByConversation((current) => ({
        ...current,
        [key]: {
          ...(current[key] || createEmptyMessagesMeta()),
          loading: false,
          loadingMore: false,
        },
      }));
      console.warn("API lịch sử tin nhắn chưa sẵn sàng.", error);
    }
  }, []);

  const loadOlderMessages = useCallback(() => {
    if (!activeConversationId) return;

    const key = String(activeConversationId);
    const meta = messagesMetaByConversation[key] || createEmptyMessagesMeta();
    if (!meta.hasMore || meta.loading || meta.loadingMore) return;

    loadMessages(activeConversationId, {
      page: (meta.page ?? 0) + 1,
      prepend: true,
    });
  }, [activeConversationId, loadMessages, messagesMetaByConversation]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      connectSocket();
    }, 0);
    return () => {
      window.clearTimeout(timer);
      disconnectSocket();
    };
  }, [connectSocket, disconnectSocket]);

  useEffect(() => {
    if (!activeConversationId) return;
    const timer = window.setTimeout(() => {
      loadMessages(activeConversationId);
      setConversations((current) =>
        current.map((conversation) =>
          String(conversation.id) === String(activeConversationId)
            ? { ...conversation, unreadCompanyCount: 0 }
            : conversation
        )
      );
      // subscription to conversation topics is handled centrally to keep previews updated
    }, 0);
    return () => window.clearTimeout(timer);
  }, [activeConversationId, loadMessages]);

  // Maintain subscriptions for all conversations while connected. Subscribe to newly
  // loaded conversations and unsubscribe from removed ones.
  useEffect(() => {
    if (connectionStatus !== "connected") return;

    const currentSubs = new Set(Object.keys(conversationSubscriptionsRef.current));
    const newIds = new Set(conversations.map((c) => String(c.id)));

    // subscribe to new conversations
    conversations.forEach((c) => {
      const id = String(c.id);
      if (!currentSubs.has(id)) subscribeToConversation(id);
    });

    // unsubscribe removed conversations
    currentSubs.forEach((id) => {
      if (!newIds.has(id)) {
        try {
          conversationSubscriptionsRef.current[id]?.unsubscribe();
        } catch (e) {}
        delete conversationSubscriptionsRef.current[id];
      }
    });
  }, [conversations, connectionStatus, subscribeToConversation]);

  const handleSelectConversation = (conversationId) => {
    setActiveConversationId(String(conversationId));
  };

  const { mutateAsync: startConversation, isPending: isStartingConversation } = useMutation({
    mutationFn: async (customer) => {
      const response = await ChatService.createOrGetConversation({ customerId: customer.id });
      return response?.data?.result;
    },
    onSuccess: (conversation) => {
      if (!conversation?.id) return;

      const [mappedConversation] = mapConversations([conversation]);
      setConversations((current) => {
        const exists = current.some((item) => String(item.id) === String(mappedConversation.id));
        if (exists) {
          return current.map((item) =>
            String(item.id) === String(mappedConversation.id) ? { ...item, ...mappedConversation } : item
          );
        }
        return [mappedConversation, ...current];
      });
      setActiveConversationId(String(conversation.id));
      subscribeToConversation(conversation.id);
      queryClient.invalidateQueries({ queryKey: ["chatConversations"] });
      toast.success("Đã mở hội thoại với khách hàng");
    },
    onError: (error) => {
      toast.error(error?.response?.data?.message || "Không thể tạo hội thoại với khách hàng");
      throw error;
    },
  });

  const handleStartConversation = async (customer) => {
    await startConversation(customer);
  };

  const handleSendMessage = (event) => {
    event.preventDefault();
    const content = messageInput.trim();
    if (!content || !activeConversationId) return;

    const client = stompClientRef.current;
    if (!client?.connected || connectionStatus !== "connected") {
      toast.error("WebSocket chưa kết nối. Vui lòng bấm Kết nối lại.");
      return;
    }

    client.publish({
      destination: SEND_DESTINATION,
      body: JSON.stringify({ conversationId: String(activeConversationId), content }),
      headers: { "content-type": "application/json" },
    });
    setMessageInput("");
  };

  const statusView = {
    connected: { label: "Đang kết nối", icon: Wifi, className: "bg-emerald-50 text-emerald-700 border-emerald-200" },
    connecting: { label: "Đang mở kết nối", icon: RefreshCw, className: "bg-amber-50 text-amber-700 border-amber-200" },
    disconnected: { label: "Mất kết nối", icon: WifiOff, className: "bg-slate-50 text-slate-600 border-slate-200" },
    error: { label: "Lỗi kết nối", icon: AlertCircle, className: "bg-red-50 text-red-700 border-red-200" },
  }[connectionStatus];
  const StatusIcon = statusView.icon;

  return (
    <div className="min-h-full bg-[#f5f7fb] p-5">
      <div className="mx-auto flex max-w-7xl flex-col gap-5">
        <section className="rounded-[28px] border border-slate-100 bg-white p-6 shadow-sm">
          <div className="flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
            <div>
              <div className="flex items-center gap-3 text-blue-600">
                <span className="rounded-2xl bg-blue-50 p-3">
                  <MessagesSquare size={26} />
                </span>
                <div>
                  <p className="text-sm font-semibold uppercase tracking-wider text-blue-500">WebChat nhà xe</p>
                  <h1 className="text-2xl font-bold text-slate-900">Trao đổi trực tiếp với khách hàng</h1>
                </div>
              </div>
            </div>

            <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
              <div className={`flex items-center gap-2 rounded-full border px-4 py-2 text-sm font-semibold ${statusView.className}`}>
                <StatusIcon size={18} className={connectionStatus === "connecting" ? "animate-spin" : ""} />
                {statusView.label}
              </div>
              <button
                type="button"
                onClick={() => {
                  disconnectSocket();
                  setTimeout(connectSocket, 50);
                }}
                className="inline-flex items-center justify-center gap-2 rounded-full bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700"
              >
                <RefreshCw size={16} />
                Kết nối lại
              </button>
            </div>
          </div>

          {lastError && (
            <div className="mt-4 flex items-start gap-3 rounded-2xl border border-red-100 bg-red-50 p-4 text-sm text-red-700">
              <AlertCircle className="mt-0.5 shrink-0" size={18} />
              <span>{lastError}</span>
            </div>
          )}
        </section>

        <section className="grid h-[calc(100vh-200px)] min-h-[550px] grid-cols-1 overflow-hidden rounded-[28px] border border-slate-100 bg-white shadow-sm lg:grid-cols-[360px_minmax(0,1fr)]">
          <ChatSidebar
            filterParams={filterParams}
            onCustomerInfoChange={onCustomerInfoChange}
            conversations={conversations}
            totalPages={totalPages}
            totalElements={totalElements}
            onPageChange={onPageChange}
            isFetching={isFetchingConversations}
            apiStatus={apiStatus}
            activeConversationId={activeConversationId}
            handleSelectConversation={handleSelectConversation}
            onStartConversation={handleStartConversation}
            isStartingConversation={isStartingConversation}
            viewerRole={user?.role}
          />

          <ChatWindow
            activeConversation={activeConversation}
            company={company}
            activeConversationId={activeConversationId}
            activeMessages={activeMessages}
            activeMessagesMeta={activeMessagesMeta}
            currentUserId={currentUserId}
            messagesEndRef={messagesEndRef}
            messageInput={messageInput}
            setMessageInput={setMessageInput}
            handleSendMessage={handleSendMessage}
            onLoadOlderMessages={loadOlderMessages}
            connectionStatus={connectionStatus}
          />
        </section>
      </div>
    </div>
  );
};

export default Chat;