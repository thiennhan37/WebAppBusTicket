import React, { useState } from 'react';
import { BookText, LockKeyhole, UnlockKeyhole, Users, UserCircle } from 'lucide-react';
import { keepPreviousData, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSearchParams } from 'react-router-dom';
import AdminService from '../../Services/AdminService';
import Pagination from '../../components/other/Pagination';
import { toast } from 'sonner';
import AccountDetailModal from './AccountDetailModal';
import ConfirmModal from '../../components/other/ConfirmModal';

const AdminManageAccount = () => {
  const queryClient = useQueryClient();
  const [searchParams, setSearchParams] = useSearchParams();

  const [selectedAccount, setSelectedAccount] = useState(null);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [confirmData, setConfirmData] = useState({ id: null, newStatus: null });

  const handleOpenDetailModal = (account) => {
    setSelectedAccount(account);
    setIsDetailModalOpen(true);
  };

  const handleCloseDetailModal = () => {
    setSelectedAccount(null);
    setIsDetailModalOpen(false);
  };

  const page = Number(searchParams.get('page')) || 1;
  const statusFilter = searchParams.get('status') || 'All';
  const keyword = searchParams.get('keyword') || '';
  const sortOrder = searchParams.get('sortOrder') || 'desc';
  const accountType = searchParams.get('type') || 'CUSTOMER'; // CUSTOMER or STAFF

  const params = { page, keyword, status: statusFilter, sortOrder };

  const updateFilter = ({ field, value }) => {
    const currentParams = new URLSearchParams(searchParams);
    if (value) currentParams.set(field, value);
    else currentParams.delete(field);

    if (field !== 'page') currentParams.set('page', 1);
    setSearchParams(currentParams);
  };

  const { data } = useQuery({
    queryKey: ['accountPage', accountType, page, keyword, statusFilter, sortOrder],
    queryFn: async () => {
      const response = await AdminService.getAccountPage({ filterParams: params, type: accountType });
      return response.data.result;
    },
    placeholderData: keepPreviousData,
    staleTime: 5000,
  });

  const totalPage = data?.page?.totalPages || 1;
  const onPageChange = (newPage) => {
    updateFilter({ field: 'page', value: newPage });
  };
  const currentItems = data?.content || [];

  const { mutate: changeStatus } = useMutation({
    mutationFn: async ({ id, newStatus }) => {
      const response = await AdminService.changeStatusAccount(id, accountType, newStatus);
      return response.data.result;
    },
    onSuccess: () => {
      toast.success("Cập nhật trạng thái thành công");
      queryClient.invalidateQueries({ queryKey: ['accountPage'] });
    },
    onError: () => {
      toast.error("Cập nhật trạng thái thất bại");
    } 
  });

  const handleStatusChangeClick = (id, newStatus) => {
    setConfirmData({ id, newStatus });
    setShowConfirm(true);
  };

  const handleConfirmStatusChange = () => {
    changeStatus(confirmData);
    setShowConfirm(false);
  };

  const formatDate = dateString => {
    if(!dateString) return "";
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(date);
  };

  const getStatusBadge = status => {
    switch (status) {
      case 'ACTIVE':
        return (
          <span className="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
            Đang hoạt động
          </span>
        );
      case 'BLOCKED':
        return (
          <span className="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-200 text-gray-800">
            Đã khóa
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <div className="max-w-7xl mx-auto">
        <div className="mb-8 flex flex-col md:flex-row md:items-center md:justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Quản lý Tài khoản</h1>
            <p className="mt-1 text-sm text-gray-500">
              Quản lý thông tin và trạng thái của khách hàng và nhân viên nhà xe.
            </p>
          </div>
        </div>

        {/* Tabs for Account Type */}
        <div className="flex space-x-4 border-b border-gray-200 mb-6">
          <button
            onClick={() => updateFilter({ field: 'type', value: 'CUSTOMER' })}
            className={`py-2 px-4 inline-flex items-center gap-2 border-b-2 font-medium text-sm transition-colors ${
              accountType === 'CUSTOMER'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            <Users size={18} />
            Khách hàng
          </button>
          <button
            onClick={() => updateFilter({ field: 'type', value: 'STAFF' })}
            className={`py-2 px-4 inline-flex items-center gap-2 border-b-2 font-medium text-sm transition-colors ${
              accountType === 'STAFF'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            <UserCircle size={18} />
            Nhân viên nhà xe
          </button>
        </div>

        {/* toolbar */}
        <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200 mb-6 flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg className="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" 
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
              </svg>
            </div>
            <input type="text" placeholder="Tìm kiếm theo tên, email, sđt..."
              className="pl-10 block w-full rounded-md border-gray-300 border py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
              value={keyword}
              onChange={e => updateFilter({ field: 'keyword', value: e.target.value })}
            />
          </div>

          <select
            className="block w-full md:w-48 rounded-md border-gray-300 border py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            value={statusFilter}
            onChange={e => updateFilter({ field: 'status', value: e.target.value })}
          >
            <option value="All">Tất cả trạng thái</option>
            <option value="ACTIVE">Đang hoạt động</option>
            <option value="BLOCKED">Đã khóa</option>
          </select>

          <select
            className="block w-full md:w-56 rounded-md border-gray-300 border py-2 px-3 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            value={sortOrder}
            onChange={e => updateFilter({ field: 'sortOrder', value: e.target.value })}
          >
            <option value="desc">Ngày tạo: Mới nhất</option>
            <option value="asc">Ngày tạo: Cũ nhất</option>
          </select>
        </div>

        {/* table */}
        <div className="bg-white shadow-sm rounded-lg border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto min-h-[410px]">
            <table className="min-w-full divide-y divide-gray-200 ">
              <thead className="bg-gray-50"> 
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    ID
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Người dùng
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Liên hệ
                  </th>
                  {accountType === 'STAFF' && (
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Trực thuộc
                    </th>
                  )}
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Thời gian tạo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Trạng thái
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Thao tác
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {currentItems.length > 0 ? (
                  currentItems.map(account => (
                    <tr key={account.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900 font-mono">{account.id}</div>
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{account.fullName || 'Chưa có tên'}</div>
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{account.email}</div>
                        <div className="text-sm text-gray-500">{account.phone}</div>
                      </td>

                      {accountType === 'STAFF' && (
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="text-sm text-gray-900 max-w-[150px] truncate" title={account.busCompanyName}>
                            {account.busCompanyName || 'Không xác định'}
                          </div>
                        </td>
                      )}

                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatDate(account.createdAt)}
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        {getStatusBadge(account.status)}
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex justify-end gap-2">
                          {/* detail */}
                          <button onClick={() => handleOpenDetailModal(account)} className="text-blue-600 hover:text-blue-900 bg-blue-50 p-2 rounded-md transition-colors"
                            title="Xem chi tiết">
                              <BookText size={18} />
                          </button>

                          {/* lock */}
                          {account.status === 'ACTIVE' && (
                            <button onClick={() => handleStatusChangeClick(account.id, 'BLOCKED')}
                              className="text-red-600 hover:text-red-900 bg-gray-100 p-2 rounded-md transition-colors"
                              title="Khóa tài khoản">
                              <LockKeyhole size={18} />
                            </button>
                          )}

                          {/* unlock */}
                          {account.status === 'BLOCKED' && (
                            <button onClick={() => handleStatusChangeClick(account.id, 'ACTIVE')}
                              className="text-green-600 hover:text-green-900 bg-blue-50 p-2 rounded-md transition-colors"
                              title="Mở khóa">
                              <UnlockKeyhole size={18} />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={accountType === 'STAFF' ? 8 : 7} className="px-6 py-10 text-center text-gray-500">
                      Không tìm thấy tài khoản nào phù hợp.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          <div className="border-t border-slate-100 px-4 py-4 bg-white">
            <Pagination page={page} onPageChange={onPageChange} totalPages={totalPage} />
          </div>
        </div>

        {/* Detail Modal */}
        <AccountDetailModal 
          isOpen={isDetailModalOpen} 
          onClose={handleCloseDetailModal} 
          account={selectedAccount} 
          type={accountType}
        />
        <ConfirmModal 
          view={"absolute"}
          isOpen={showConfirm}
          onClose={() => setShowConfirm(false)}
          onConfirm={handleConfirmStatusChange}
          title="Xác nhận thay đổi trạng thái"
          message={`Bạn có chắc chắn muốn ${confirmData.newStatus === "BLOCKED" ? "khóa" : "mở khóa"} tài khoản này?`}
        />
      </div>
    </div>
  );
};

export default AdminManageAccount;
