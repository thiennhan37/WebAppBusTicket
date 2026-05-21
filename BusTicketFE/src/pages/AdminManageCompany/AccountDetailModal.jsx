import React from 'react';
import { X, User, Phone, Mail, Calendar, MapPin, Building, ShieldCheck, Activity } from 'lucide-react';

const AccountDetailModal = ({ isOpen, onClose, account, type }) => {
  if (!isOpen || !account) return null;

  const formatDate = dateString => {
    if (!dateString) return "Chưa cập nhật";
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    }).format(date);
  };

  const formatDateTime = dateString => {
    if (!dateString) return "Chưa cập nhật";
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
        return <span className="px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-green-100 text-green-800">Đang hoạt động</span>;
      case 'BLOCKED':
        return <span className="px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-gray-200 text-gray-800">Đã khóa</span>;
      default:
        return <span className="px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">{status}</span>;
    }
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:p-0">
        <div className="fixed inset-0 transition-opacity bg-gray-500 bg-opacity-75" onClick={onClose}></div>
        <div className="relative inline-block w-full max-w-2xl overflow-hidden text-left align-middle transition-all transform bg-white rounded-2xl shadow-xl sm:my-8">
          
          <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200 bg-gray-50">
            <h3 className="text-xl font-bold text-gray-900 flex items-center gap-2">
              <User className="text-blue-600" size={24} />
              Thông tin chi tiết tài khoản {type === 'CUSTOMER' ? 'Khách hàng' : 'Nhân viên'}
            </h3>
            <button onClick={onClose} className="text-gray-400 hover:text-gray-500 focus:outline-none transition-colors">
              <X size={24} />
            </button>
          </div>

          <div className="px-6 py-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="col-span-2">
                <div className="flex items-center space-x-4">
                  <div className="h-16 w-16 rounded-full bg-blue-100 flex items-center justify-center">
                    <span className="text-2xl font-bold text-blue-600">
                      {account.fullName ? account.fullName.charAt(0).toUpperCase() : 'U'}
                    </span>
                  </div>
                  <div>
                    <h4 className="text-xl font-bold text-gray-900">{account.fullName || 'Chưa cập nhật'}</h4>
                    <p className="text-sm text-gray-500">ID: {account.id}</p>
                    <div className="mt-1">{getStatusBadge(account.status)}</div>
                  </div>
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                    <Mail size={16} /> Email
                  </label>
                  <p className="mt-1 text-base text-gray-900">{account.email || 'Chưa cập nhật'}</p>
                </div>

                <div>
                  <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                    <Phone size={16} /> Số điện thoại
                  </label>
                  <p className="mt-1 text-base text-gray-900">{account.phone || 'Chưa cập nhật'}</p>
                </div>

                <div>
                  <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                    <Calendar size={16} /> Ngày sinh
                  </label>
                  <p className="mt-1 text-base text-gray-900">{formatDate(account.dob)}</p>
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                    <User size={16} /> Giới tính
                  </label>
                  <p className="mt-1 text-base text-gray-900">
                    {account.gender === 'MALE' ? 'Nam' : account.gender === 'FEMALE' ? 'Nữ' : 'Khác'}
                  </p>
                </div>

                <div>
                  <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                    <ShieldCheck size={16} /> Vai trò
                  </label>
                  <p className="mt-1 text-base text-gray-900">{account.role}</p>
                </div>

                <div>
                  <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                    <Activity size={16} /> Ngày tạo
                  </label>
                  <p className="mt-1 text-base text-gray-900">{formatDateTime(account.createdAt)}</p>
                </div>
              </div>

              {type === 'CUSTOMER' && account.idRegion && (
                <div className="col-span-2 pt-4 border-t border-gray-100">
                  <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                    <MapPin size={16} /> Khu vực (Mã vùng)
                  </label>
                  <p className="mt-1 text-base text-gray-900">{account.idRegion}</p>
                </div>
              )}

              {type === 'STAFF' && account.busCompany && (
                <div className="col-span-2 pt-4 border-t border-gray-100">
                  <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                    <Building size={16} /> Nhà xe trực thuộc
                  </label>
                  <div className="mt-2 bg-gray-50 p-4 rounded-lg border border-gray-200">
                    <p className="text-base font-semibold text-gray-900">{account.busCompany.companyName}</p>
                    <p className="text-sm text-gray-500 mt-1">ID Nhà xe: {account.busCompany.id}</p>
                    <p className="text-sm text-gray-500">Email: {account.busCompany.email}</p>
                    <p className="text-sm text-gray-500">Hotline: {account.busCompany.hotline}</p>
                  </div>
                </div>
              )}
            </div>
          </div>
          
          <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-end">
            <button
              onClick={onClose}
              className="px-4 py-2 bg-white border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
            >
              Đóng
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AccountDetailModal;
