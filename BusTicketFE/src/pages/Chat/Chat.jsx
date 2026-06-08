import { useCallback, useContext, useEffect, useMemo, useRef, useState } from "react";
import {
  AlertCircle,
  Building2,
  CheckCircle2,
  Clock,
  MessageCircle,
  MessagesSquare,
  Plus,
  RefreshCw,
  Search,
  Send,
  UserRound,
  Wifi,
  WifiOff,
} from "lucide-react";
import { toast } from "sonner";
import AuthContext from "../../context/AuthContext";
import ChatService from "../../Services/ChatService";

const API_HTTP_URL = "http://localhost:8080/vexedat";
const API_WS_URL = API_HTTP_URL.replace(/^http/, "ws");
const WEBSOCKET_PATH = "/ws";
const SEND_DESTINATION = "/app/chat.send";
const TOPIC_PREFIX = "/topic/conversation/";

const normalizePageContent = (payload) => {
  const data = payload?.data?.result ?? payload?.result ?? payload;
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.content)) return data.content;
  if (Array.isArray(data?.data)) return data.data;
  return [];
};

const buildFallbackConversations = (company, user) => [
  {
    id: "1",
    customerName: "Khách hàng #1",
    lastMessage: "Nhập mã hội thoại thật để kết nối đúng phòng chat.",
    lastMessageAt: new Date().toISOString(),
    status: "OPEN",
    busCompanyName: company?.companyName,
    unreadCount: 0,
    isLocal: true,
  },
  {
    id: "2",
    customerName: "Khách hàng #2",
    lastMessage: `${user?.fullName || user?.email || "Nhân viên"} có thể cùng đồng nghiệp xem hội thoại này khi chọn cùng mã.`,
    lastMessageAt: new Date(Date.now() - 1000 * 60 * 8).toISOString(),
    status: "OPEN",
    busCompanyName: company?.companyName,
    unreadCount: 0,
    isLocal: true,
  },
];

const parseStompFrames = (chunk) =>
  chunk
    .split("\0")
    .map((frame) => frame.trim())
    .filter(Boolean)
    .map((frame) => {
      const separatorIndex = frame.indexOf("\n\n");
      const headerPart = separatorIndex >= 0 ? frame.slice(0, separatorIndex) : frame;
      const body = separatorIndex >= 0 ? frame.slice(separatorIndex + 2) : "";
      const [command, ...headerLines] = headerPart.split("\n");
      const headers = headerLines.reduce((result, line) => {
        const delimiterIndex = line.indexOf(":");
        if (delimiterIndex > -1) {
          result[line.slice(0, delimiterIndex)] = line.slice(delimiterIndex + 1);
        }
        return result;
      }, {});
      return { command, headers, body };
    });

const createStompFrame = ({ command, headers = {}, body = "" }) => {
  const headerText = Object.entries(headers)
    .filter(([, value]) => value !== undefined && value !== null)
    .map(([key, value]) => `${key}:${value}`)
    .join("\n");
  return `${command}\n${headerText}\n\n${body}\0`;
};

const getDisplayName = (conversation) =>
  conversation?.customerName ||
  conversation?.customer?.fullName ||
  conversation?.customer?.name ||
  conversation?.customerPhone ||
  `Hội thoại #${conversation?.id}`;

const formatTime = (value) => {
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

const getInitials = (name) => {
  if (!name) return "KH";
  const words = name.trim().split(/\s+/);
  return words.slice(-2).map((word) => word[0]).join("").toUpperCase();
};

const Chat = () => {
  const { user, company } = useContext(AuthContext);
  const [conversations, setConversations] = useState(() => buildFallbackConversations(company, user));
  const [activeConversationId, setActiveConversationId] = useState("1");
  const [messagesByConversation, setMessagesByConversation] = useState({});
  const [messageInput, setMessageInput] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [manualConversationId, setManualConversationId] = useState("");
  const [connectionStatus, setConnectionStatus] = useState("disconnected");
  const [apiStatus, setApiStatus] = useState("idle");
  const [lastError, setLastError] = useState("");
  const socketRef = useRef(null);
  const subscribedConversationRef = useRef(null);
  const messagesEndRef = useRef(null);

  const accessToken = useMemo(() => localStorage.getItem("accessToken") || "", []);
  const currentUserId = user?.id || user?.userId || user?.email || user?.phone || "";

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
      const text = `${getDisplayName(conversation)} ${conversation.id} ${conversation.lastMessage || ""}`.toLowerCase();
      return text.includes(normalizedSearch);
    });
  }, [conversations, searchTerm]);

  const upsertConversationPreview = useCallback((message) => {
    setConversations((current) => {
      const exists = current.some((conversation) => String(conversation.id) === String(message.conversationId));
      const updated = current.map((conversation) =>
        String(conversation.id) === String(message.conversationId)
          ? {
              ...conversation,
              lastMessage: message.content,
              lastMessageAt: message.sentAt,
              unreadCount:
                String(message.conversationId) === String(activeConversationId)
                  ? 0
                  : (conversation.unreadCount || 0) + 1,
            }
          : conversation
      );
      if (exists) return updated;
      return [
        {
          id: message.conversationId,
          customerName: `Khách hàng #${message.conversationId}`,
          lastMessage: message.content,
          lastMessageAt: message.sentAt,
          status: "OPEN",
          unreadCount: 0,
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
    const socket = socketRef.current;
    if (!socket || socket.readyState !== WebSocket.OPEN || !conversationId) return;
    subscribedConversationRef.current = String(conversationId);
    socket.send(
      createStompFrame({
        command: "SUBSCRIBE",
        headers: {
          id: `conversation-${conversationId}`,
          destination: `${TOPIC_PREFIX}${conversationId}`,
          ack: "auto",
        },
      })
    );
  }, []);

  const connectSocket = useCallback(() => {
    if (!accessToken) {
      setLastError("Không tìm thấy access token. Vui lòng đăng nhập lại để dùng webChat.");
      setConnectionStatus("error");
      return;
    }

    if (socketRef.current && [WebSocket.OPEN, WebSocket.CONNECTING].includes(socketRef.current.readyState)) {
      return;
    }

    setConnectionStatus("connecting");
    setLastError("");
    const socket = new WebSocket(`${API_WS_URL}${WEBSOCKET_PATH}?token=${encodeURIComponent(accessToken)}`);
    socketRef.current = socket;

    socket.onopen = () => {
      socket.send(
        createStompFrame({
          command: "CONNECT",
          headers: { "accept-version": "1.2", "heart-beat": "10000,10000" },
        })
      );
    };

    socket.onmessage = (event) => {
      parseStompFrames(event.data).forEach((frame) => {
        if (frame.command === "CONNECTED") {
          setConnectionStatus("connected");
          subscribeToConversation(activeConversationId);
          return;
        }

        if (frame.command === "MESSAGE") {
          try {
            const message = JSON.parse(frame.body);
            addMessage(message);
          } catch (error) {
            console.error("Không thể đọc tin nhắn websocket", error);
          }
          return;
        }

        if (frame.command === "ERROR") {
          setConnectionStatus("error");
          setLastError(frame.body || "WebSocket trả về lỗi kết nối.");
        }
      });
    };

    socket.onerror = () => {
      setConnectionStatus("error");
      setLastError("Không thể kết nối WebSocket. Kiểm tra BusTicketBE và token đăng nhập.");
    };

    socket.onclose = () => {
      setConnectionStatus((currentStatus) => (currentStatus === "error" ? "error" : "disconnected"));
    };
  }, [accessToken, activeConversationId, addMessage, subscribeToConversation]);

  const disconnectSocket = useCallback(() => {
    const socket = socketRef.current;
    if (socket && socket.readyState === WebSocket.OPEN) {
      socket.send(createStompFrame({ command: "DISCONNECT" }));
      socket.close();
    }
    socketRef.current = null;
    subscribedConversationRef.current = null;
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
        setConversations(data);
        setActiveConversationId(String(data[0].id));
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
          String(conversation.id) === String(activeConversationId) ? { ...conversation, unreadCount: 0 } : conversation
        )
      );

      if (connectionStatus === "connected" && subscribedConversationRef.current !== String(activeConversationId)) {
        subscribeToConversation(activeConversationId);
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

    const socket = socketRef.current;
    if (!socket || socket.readyState !== WebSocket.OPEN || connectionStatus !== "connected") {
      toast.error("WebSocket chưa kết nối. Vui lòng bấm Kết nối lại.");
      return;
    }

    socket.send(
      createStompFrame({
        command: "SEND",
        headers: { destination: SEND_DESTINATION, "content-type": "application/json" },
        body: JSON.stringify({ conversationId: String(activeConversationId), content }),
      })
    );
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
              <p className="mt-3 max-w-3xl text-sm leading-6 text-slate-500">
                Mỗi hội thoại được subscribe theo topic <span className="font-semibold text-slate-700">/topic/conversation/&lt;id&gt;</span>.
                Nhân viên cùng nhà xe chỉ cần chọn cùng mã hội thoại để xem và phản hồi chung trong một phòng chat.
              </p>
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

        <section className="grid min-h-[660px] grid-cols-1 overflow-hidden rounded-[28px] border border-slate-100 bg-white shadow-sm lg:grid-cols-[360px_minmax(0,1fr)]">
          <aside className="flex min-h-[660px] flex-col border-r border-slate-100 bg-white">
            <div className="border-b border-slate-100 p-5">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
                <input
                  value={searchTerm}
                  onChange={(event) => setSearchTerm(event.target.value)}
                  placeholder="Tìm khách hàng hoặc mã hội thoại"
                  className="w-full rounded-2xl border border-slate-200 bg-slate-50 py-3 pl-10 pr-3 text-sm outline-none transition focus:border-blue-400 focus:bg-white focus:ring-4 focus:ring-blue-50"
                />
              </div>

              <div className="mt-3 flex gap-2">
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
                        <span className="shrink-0 text-[11px] text-slate-400">{formatTime(conversation.lastMessageAt)}</span>
                      </div>
                      <p className="mt-1 line-clamp-2 text-sm text-slate-500">{conversation.lastMessage || "Chưa có tin nhắn"}</p>
                      <div className="mt-2 flex items-center justify-between">
                        <span className="rounded-full bg-slate-100 px-2 py-0.5 text-[11px] font-semibold text-slate-500">
                          ID: {conversation.id}
                        </span>
                        {!!conversation.unreadCount && (
                          <span className="rounded-full bg-red-500 px-2 py-0.5 text-[11px] font-bold text-white">
                            {conversation.unreadCount}
                          </span>
                        )}
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          </aside>

          <main className="flex min-h-[660px] flex-col bg-slate-50/60">
            <div className="flex items-center justify-between border-b border-slate-100 bg-white px-6 py-4">
              <div className="flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-600 text-sm font-bold text-white">
                  {getInitials(getDisplayName(activeConversation))}
                </div>
                <div>
                  <h2 className="font-bold text-slate-900">{getDisplayName(activeConversation)}</h2>
                  <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-slate-500">
                    <span className="inline-flex items-center gap-1 rounded-full bg-slate-100 px-2 py-1">
                      <MessageCircle size={13} /> Hội thoại #{activeConversationId}
                    </span>
                    <span className="inline-flex items-center gap-1 rounded-full bg-blue-50 px-2 py-1 text-blue-600">
                      <Building2 size={13} /> {company?.companyName || activeConversation?.busCompanyName || "Nhà xe"}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto px-6 py-5">
              {!activeMessages.length && (
                <div className="mx-auto mt-20 max-w-md rounded-3xl border border-dashed border-slate-200 bg-white p-8 text-center text-slate-500">
                  <MessagesSquare className="mx-auto mb-4 text-blue-500" size={42} />
                  <h3 className="font-bold text-slate-800">Chưa có tin nhắn trong phiên này</h3>
                  <p className="mt-2 text-sm leading-6">
                    Nếu API lịch sử chưa mở, tin nhắn mới vẫn sẽ hiển thị realtime sau khi WebSocket kết nối thành công.
                  </p>
                </div>
              )}

              <div className="space-y-4">
                {activeMessages.map((message, index) => {
                  const isMine = String(message.senderId) === String(currentUserId);
                  return (
                    <div key={message.id || `${message.sentAt}-${index}`} className={`flex gap-3 ${isMine ? "justify-end" : "justify-start"}`}>
                      {!isMine && (
                        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-white text-slate-500 shadow-sm">
                          <UserRound size={17} />
                        </div>
                      )}
                      <div className={`max-w-[72%] rounded-3xl px-4 py-3 shadow-sm ${isMine ? "bg-blue-600 text-white" : "bg-white text-slate-700"}`}>
                        <p className="whitespace-pre-wrap break-words text-sm leading-6">{message.content}</p>
                        <div className={`mt-2 text-[11px] ${isMine ? "text-blue-100" : "text-slate-400"}`}>
                          {formatTime(message.sentAt)} {message.senderId ? `• ${isMine ? "Bạn" : message.senderId}` : ""}
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
              <p className="mt-2 px-2 text-xs text-slate-400">
                Gửi đến <span className="font-semibold text-slate-600">{SEND_DESTINATION}</span> với payload gồm conversationId và content.
              </p>
            </form>
          </main>
        </section>
      </div>
    </div>
  );
};

export default Chat;