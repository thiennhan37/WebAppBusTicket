import React from 'react';
import { X } from 'lucide-react';

const CompanyDetailModal = ({ isOpen, onClose, busCompany }) => {
  if (!isOpen || !busCompany) return null;

  const formatDate = dateString => {
    if (!dateString) return "";
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
        return (
          <span className="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
            Chờ duyệt
          </span>
        );
    }
  };

  // Close modal when clicking on the background overlay
  const handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div 
      className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 backdrop-blur-sm transition-opacity"
      onClick={handleOverlayClick}
    >
      <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl max-h-[90vh] flex flex-col transform transition-all overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h3 className="text-xl font-semibold text-gray-900">Thông tin chi tiết Nhà xe</h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-500 hover:bg-gray-100 p-2 rounded-full transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto custom-scrollbar">
          <div className="flex flex-col sm:flex-row gap-6 mb-8 items-center sm:items-start">
            <div className="flex-shrink-0">
              {busCompany.avatarUrl ? (
                <img
                  src={busCompany.avatarUrl}
                  alt={busCompany.companyName}
                  className="w-32 h-32 rounded-lg object-cover border border-gray-200 shadow-sm"
                />
              ) : (
                <div className="w-32 h-32 rounded-lg bg-gray-100 border border-gray-200 flex items-center justify-center text-gray-400 shadow-sm">
                  <span className="text-sm">Không có ảnh</span>
                </div>
              )}
            </div>
            
            <div className="flex-1 space-y-3 text-center sm:text-left">
              <div>
                <h4 className="text-2xl font-bold text-gray-900">{busCompany.companyName}</h4>
                <p className="text-sm text-gray-500 mt-1">ID: <span className="font-mono">{busCompany.id}</span></p>
              </div>
              <div className="flex items-center justify-center sm:justify-start gap-2">
                <span className="text-sm font-medium text-gray-500 w-24">Trạng thái:</span>
                {getStatusBadge(busCompany.status)}
              </div>
              <div className="flex items-center justify-center sm:justify-start gap-2">
                <span className="text-sm font-medium text-gray-500 w-24">Ngày đăng ký:</span>
                <span className="text-sm text-gray-900">{formatDate(busCompany.createdAt)}</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            <div className="bg-gray-50 p-4 rounded-lg border border-gray-100">
              <span className="block text-xs font-medium text-gray-500 uppercase tracking-wider mb-1">
                Đại diện pháp luật (Chủ nhà xe)
              </span>
              <span className="block text-sm font-medium text-gray-900">
                {busCompany.hostName || 'Chưa cập nhật'}
              </span>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg border border-gray-100">
              <span className="block text-xs font-medium text-gray-500 uppercase tracking-wider mb-1">
                Số điện thoại liên hệ (Hotline)
              </span>
              <span className="block text-sm font-medium text-gray-900">
                {busCompany.hotline || 'Chưa cập nhật'}
              </span>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg border border-gray-100 sm:col-span-2">
              <span className="block text-xs font-medium text-gray-500 uppercase tracking-wider mb-1">
                Địa chỉ Email
              </span>
              <span className="block text-sm font-medium text-gray-900">
                {busCompany.email || 'Chưa cập nhật'}
              </span>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg border border-gray-100 sm:col-span-2">
              <span className="block text-xs font-medium text-gray-500 uppercase tracking-wider mb-1">
                Chính sách & Quy định nhà xe
              </span>
              <div className="text-sm text-gray-900 whitespace-pre-wrap mt-2 bg-white p-3 rounded border border-gray-200 max-h-48 overflow-y-auto">
                {busCompany.policy || 'Không có thông tin chính sách nào được cập nhật.'}
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="flex justify-end p-6 border-t border-gray-200 bg-gray-50">
          <button
            onClick={onClose}
            className="px-6 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors shadow-sm"
          >
            Đóng
          </button>
        </div>
      </div>
    </div>
  );
};

export default CompanyDetailModal;
