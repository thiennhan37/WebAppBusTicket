import { useCallback, useContext, useEffect, useMemo, useRef, useState } from "react";
import { Client } from "@stomp/stompjs";
import { AlertCircle, MessagesSquare, RefreshCw, Wifi, WifiOff } from "lucide-react";
import { toast } from "sonner";
import AuthContext from "../../context/AuthContext";
import ChatService from "../../Services/ChatService";
import { normalizePageContent, buildFallbackConversations, getDisplayName } from "./ChatUtils";
import ChatSidebar from "./ChatSidebar";
import ChatWindow from "./ChatWindow";

const API_HTTP_URL = "http://localhost:8080/vexedat";
const API_WS_URL = API_HTTP_URL.replace(/^http/, "ws");
const WEBSOCKET_PATH = "/ws";
const SEND_DESTINATION = "/app/chat.send";
const TOPIC_PREFIX = "/topic/conversation/";

const Chat = () => {
  const { user, company } = useContext(AuthContext);
  const [conversations, setConversations] = useState([]);
  const [activeConversationId, setActiveConversationId] = useState("");
  const [messagesByConversation, setMessagesByConversation] = useState({});
  const [messageInput, setMessageInput] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [manualConversationId, setManualConversationId] = useState("");
  const [connectionStatus, setConnectionStatus] = useState("disconnected");
  const [apiStatus, setApiStatus] = useState("idle");
  const [lastError, setLastError] = useState("");
  const stompClientRef = useRef(null);
  const conversationSubscriptionRef = useRef(null);
  const subscribedConversationRef = useRef(null);
  const activeConversationIdRef = useRef(activeConversationId);
  const messagesEndRef = useRef(null);

  const accessToken = useMemo(() => localStorage.getItem("accessToken") || "", []);
  const currentUserId = user?.id || user?.userId || user?.email || user?.phone || "";

  useEffect(() => {
    activeConversationIdRef.current = activeConversationId;
  }, [activeConversationId]);

  const activeConversation = useMemo(
    () => conversations.find((conversation) => String(conversation.id) === String(activeConversationId)),
    [activeConversationId, conversations]
  );

  const activeMessages = useMemo(
    () => messagesByConversation[activeConversationId] || [],
    [activeConversationId, messagesByConversation]
  );

  const filteredConversations = useMemo(() => {
    const normalizedSearch = searchTerm.trim().toLowerCase();
    if (!normalizedSearch) return conversations;
    return conversations.filter((conversation) => {
      const lastMessageText = typeof conversation.lastMessage === 'string' 
        ? conversation.lastMessage 
        : conversation.lastMessage?.content || "";
      const text = `${getDisplayName(conversation)} ${conversation.id} ${lastMessageText}`.toLowerCase();
      return text.includes(normalizedSearch);
    });
  }, [conversations, searchTerm]);

  const upsertConversationPreview = useCallback((message) => {
    setConversations((current) => {
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

  const subscribeToConversation = useCallback((conversationId) => {
    const client = stompClientRef.current;
    if (!client?.connected || !conversationId) return;

    conversationSubscriptionRef.current?.unsubscribe();
    conversationSubscriptionRef.current = client.subscribe(
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
    subscribedConversationRef.current = String(conversationId);
  }, [addMessage]);

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
        subscribeToConversation(activeConversationIdRef.current);
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
        conversationSubscriptionRef.current = null;
        subscribedConversationRef.current = null;
        setConnectionStatus((currentStatus) => (currentStatus === "error" ? "error" : "disconnected"));
      },
    });

    stompClientRef.current = client;
    client.activate();
  }, [accessToken, subscribeToConversation]);

  const disconnectSocket = useCallback(() => {
    conversationSubscriptionRef.current?.unsubscribe();
    conversationSubscriptionRef.current = null;
    subscribedConversationRef.current = null;

    const client = stompClientRef.current;
    stompClientRef.current = null;
    if (client?.active) {
      client.deactivate();
    }
    setConnectionStatus("disconnected");
  }, []);

  const loadConversations = useCallback(async () => {
    setApiStatus("loading");
    try {
      const response = await ChatService.getConversations({
        busCompanyId: company?.id || user?.busCompanyId,
        keyword: searchTerm,
      });
      const data = normalizePageContent(response);
      if (data.length) {
        // Normalize unread counts: backend may include them only on lastMessage
        const mapped = data.map((conv) => ({
          ...conv,
          unreadCustomerCount: conv.unreadCustomerCount ?? conv.lastMessage?.unreadCustomerCount ?? 0,
          unreadCompanyCount: conv.unreadCompanyCount ?? conv.lastMessage?.unreadCompanyCount ?? 0,
        }));
        setConversations(mapped);
        setActiveConversationId(String(mapped[0].id));
      }
      setApiStatus(data.length ? "success" : "fallback");
    } catch (error) {
      setApiStatus("fallback");
      console.warn("API danh sách hội thoại chưa sẵn sàng, dùng dữ liệu nhập tay.", error);
    }
  }, [company, searchTerm, user]);

  const loadMessages = useCallback(async (conversationId) => {
    if (!conversationId) return;
    try {
      const response = await ChatService.getMessages({ conversationId });
      const data = normalizePageContent(response);
      setMessagesByConversation((current) => ({ ...current, [String(conversationId)]: data }));
    } catch (error) {
      console.warn("API lịch sử tin nhắn chưa sẵn sàng.", error);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      loadConversations();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadConversations]);

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
            ? { ...conversation, unreadCustomerCount: 0, unreadCompanyCount: 0 }
            : conversation
        )
      );

      if (connectionStatus === "connected" && subscribedConversationRef.current !== String(activeConversationId)) {
        subscribeToConversation(activeConversationIdRef.current);
      }
    }, 0);
    return () => window.clearTimeout(timer);
  }, [activeConversationId, connectionStatus, loadMessages, subscribeToConversation]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [activeMessages]);

  const handleSelectConversation = (conversationId) => {
    setActiveConversationId(String(conversationId));
  };

  const handleAddManualConversation = () => {
    const id = manualConversationId.trim();
    if (!id) return;
    setConversations((current) => {
      if (current.some((conversation) => String(conversation.id) === id)) return current;
      return [
        {
          id,
          customerName: `Khách hàng #${id}`,
          lastMessage: "Hội thoại được thêm thủ công để kết nối WebSocket.",
          lastMessageAt: new Date().toISOString(),
          status: "OPEN",
          unreadCount: 0,
        },
        ...current,
      ];
    });
    setActiveConversationId(id);
    setManualConversationId("");
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
            searchTerm={searchTerm}
            setSearchTerm={setSearchTerm}
            manualConversationId={manualConversationId}
            setManualConversationId={setManualConversationId}
            handleAddManualConversation={handleAddManualConversation}
            filteredConversations={filteredConversations}
            apiStatus={apiStatus}
            activeConversationId={activeConversationId}
            handleSelectConversation={handleSelectConversation}
          />

          <ChatWindow
            activeConversation={activeConversation}
            company={company}
            activeConversationId={activeConversationId}
            activeMessages={activeMessages}
            currentUserId={currentUserId}
            messagesEndRef={messagesEndRef}
            messageInput={messageInput}
            setMessageInput={setMessageInput}
            handleSendMessage={handleSendMessage}
            connectionStatus={connectionStatus}
          />
        </section>
      </div>
    </div>
  );
};

export default Chat;