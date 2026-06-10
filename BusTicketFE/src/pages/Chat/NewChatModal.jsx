import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { ChevronLeft, ChevronRight, Loader2, MessageCircle, Phone, Search, X } from "lucide-react";
import BusCompanyService from "../../Services/BusCompanyService";
import { getInitials } from "./ChatUtils";

const PAGE_SIZE = 10;

const NewChatModal = ({ onClose, onSelectCustomer, isStarting }) => {
  const [phone, setPhone] = useState("");
  const [searchPhone, setSearchPhone] = useState("");
  const [page, setPage] = useState(1);

  const { data: customers = [], isFetching, isError } = useQuery({
    queryKey: ["chatCustomers", searchPhone, page],
    queryFn: async () => {
      const response = await BusCompanyService.getCustomersForChat({
        phone: searchPhone,
        page: page - 1,
        size: PAGE_SIZE,
      });
      return response?.data?.result ?? [];
    },
    staleTime: 0,
  });

  const hasNextPage = customers.length === PAGE_SIZE;

  const handleSearch = (event) => {
    event?.preventDefault();
    setPage(1);
    setSearchPhone(phone.trim());
  };

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose} />
      <div className="relative flex max-h-[85vh] w-full max-w-lg flex-col overflow-hidden rounded-[28px] bg-white shadow-2xl">
        <div className="flex items-center justify-between border-b border-slate-100 px-6 py-5">
          <div>
            <h3 className="text-lg font-bold text-slate-900">Tìm khách hàng</h3>
            <p className="mt-1 text-sm text-slate-500">Tìm theo số điện thoại để bắt đầu hội thoại mới</p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-xl p-2 text-slate-400 transition hover:bg-slate-100 hover:text-slate-600"
          >
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSearch} className="border-b border-slate-100 px-6 py-4">
          <div className="flex gap-2">
            <div className="relative flex-1">
              <Phone className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
              <input
                value={phone}
                onChange={(event) => setPhone(event.target.value.replace(/\D/g, ""))}
                placeholder="Nhập số điện thoại khách hàng"
                className="w-full rounded-2xl border border-slate-200 bg-slate-50 py-3 pl-10 pr-3 text-sm outline-none transition focus:border-blue-400 focus:bg-white focus:ring-4 focus:ring-blue-50"
              />
            </div>
            <button
              type="submit"
              className="inline-flex items-center gap-2 rounded-2xl bg-blue-600 px-4 text-sm font-semibold text-white transition hover:bg-blue-700"
            >
              <Search size={16} />
              Tìm
            </button>
          </div>
        </form>

        <div className="min-h-[280px] flex-1 overflow-y-auto p-4">
          {isFetching && (
            <div className="flex items-center justify-center gap-2 py-16 text-sm text-slate-500">
              <Loader2 size={18} className="animate-spin text-blue-500" />
              Đang tìm khách hàng...
            </div>
          )}

          {!isFetching && isError && (
            <div className="rounded-2xl border border-red-100 bg-red-50 px-4 py-8 text-center text-sm text-red-600">
              Không thể tải danh sách khách hàng. Vui lòng thử lại.
            </div>
          )}

          {!isFetching && !isError && !customers.length && (
            <div className="rounded-2xl border border-dashed border-slate-200 px-4 py-10 text-center text-sm text-slate-500">
              {searchPhone
                ? "Không tìm thấy khách hàng phù hợp."
                : "Chưa có khách hàng nào từng đặt vé với nhà xe."}
            </div>
          )}

          {!isFetching &&
            customers.map((customer) => {
              const name = customer.fullName || "Khách hàng";
              return (
                <button
                  key={customer.id}
                  type="button"
                  disabled={isStarting}
                  onClick={() => onSelectCustomer(customer)}
                  className="mb-2 flex w-full items-center gap-3 rounded-2xl border border-slate-100 p-3 text-left transition hover:border-blue-100 hover:bg-blue-50 disabled:cursor-not-allowed disabled:opacity-60"
                >
                  <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-slate-100 text-sm font-bold text-slate-600">
                    {getInitials(name)}
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="truncate font-semibold text-slate-800">{name}</p>
                    <p className="mt-0.5 flex items-center gap-1 text-sm text-slate-500">
                      <Phone size={14} />
                      {customer.phone || "Chưa có số điện thoại"}
                    </p>
                    {customer.email && <p className="mt-0.5 truncate text-xs text-slate-400">{customer.email}</p>}
                  </div>
                  <span className="inline-flex items-center gap-1 rounded-full bg-blue-600 px-3 py-1.5 text-xs font-semibold text-white">
                    <MessageCircle size={14} />
                    Nhắn tin
                  </span>
                </button>
              );
            })}
        </div>

        {(page > 1 || hasNextPage) && (
          <div className="flex items-center justify-between border-t border-slate-100 px-6 py-4">
            <button
              type="button"
              onClick={() => setPage((current) => Math.max(1, current - 1))}
              disabled={page <= 1 || isFetching}
              className="inline-flex items-center gap-1 rounded-xl border border-slate-200 px-3 py-2 text-sm text-slate-600 transition hover:bg-slate-50 disabled:opacity-40"
            >
              <ChevronLeft size={16} />
              Trước
            </button>
            <span className="text-sm text-slate-500">Trang {page}</span>
            <button
              type="button"
              onClick={() => setPage((current) => current + 1)}
              disabled={!hasNextPage || isFetching}
              className="inline-flex items-center gap-1 rounded-xl border border-slate-200 px-3 py-2 text-sm text-slate-600 transition hover:bg-slate-50 disabled:opacity-40"
            >
              Sau
              <ChevronRight size={16} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default NewChatModal;
