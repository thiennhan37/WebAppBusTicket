import React, { useState } from 'react';
import { BookText, LockKeyhole, UnlockKeyhole } from 'lucide-react';
import { keepPreviousData, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSearchParams } from 'react-router-dom';
import AdminService from '../../Services/AdminService';
import Pagination from '../../components/other/Pagination';
import { toast } from 'sonner';

const AdminManageCompany = () => {
  const queryClient = useQueryClient();
  const [searchParams, setSearchParams] = useSearchParams();

  const page = Number(searchParams.get('page')) || 1;
  const statusFilter = searchParams.get('status') || 'All';
  const keyword = searchParams.get('keyword') || '';
  const sortOrder = searchParams.get('sortOrder') || 'desc';

  const params = { page, keyword, status: statusFilter, sortOrder };

  const updateFilter = ({ field, value }) => {
    const currentParams = new URLSearchParams(searchParams);
    if (value) currentParams.set(field, value);
    else currentParams.delete(field);

    if (field !== 'page') currentParams.set('page', 1);
    setSearchParams(currentParams);
  };

  const { data } = useQuery({
    queryKey: ['busCompanyPage', page, keyword, statusFilter, sortOrder],
    queryFn: async () => {
        if(page) console.log(page)
      const response = await AdminService.getBusCompanyPage({ filterParams: params });
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
      const response = await AdminService.changeStatusBusCompany(id, newStatus);
      return response.data.result;
    },
    onSuccess: () => {
        toast.success("Cập nhật thành công");
      queryClient.invalidateQueries({ queryKey: ['busCompanyPage'] });
    },
    onError: () => {
      toast.error("Cập nhật thất bại");
    } 
  });

  const handleStatusChange = (id, newStatus) => {
    changeStatus({ id, newStatus });
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
            <h1 className="text-2xl font-bold text-gray-900">Quản lý Nhà xe hoạt động</h1>

            <p className="mt-1 text-sm text-gray-500">
              Quản lý các nhà xe đã được duyệt và đưa vào hoạt động.
            </p>
          </div>
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

            <input type="text" placeholder="Tìm kiếm theo tên nhà xe..."
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
            <option value="desc">Ngày đăng ký: Mới nhất</option>
            <option value="asc">Ngày đăng ký: Cũ nhất</option>
          </select>
        </div>

        {/* table */}
        <div className="bg-white shadow-sm rounded-lg border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto h-[410px]">
            <table className="min-w-full divide-y divide-gray-200 ">
              <thead className="bg-gray-50"> 
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Nhà xe
                  </th>

                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Liên hệ
                  </th>

                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Thời gian đăng ký
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
                  currentItems.map(operator => (
                    <tr key={operator.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{operator.companyName}</div>
                        <div className="text-sm text-gray-500">ID: {operator.id}</div>
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{operator.email}</div>
                        <div className="text-sm text-gray-500">{operator.hotline}</div>
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatDate(operator.createdAt)}
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        {getStatusBadge(operator.status)}
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex justify-end gap-2">
                          {/* detail */}
                          <button className="text-blue-600 hover:text-blue-900 bg-blue-50 p-2 rounded-md transition-colors"
                            title="Xem chi tiết">
                              <BookText size={18} />
                          </button>

                          {/* lock */}
                          {operator.status === 'ACTIVE' && (
                            <button onClick={() => handleStatusChange(operator.id,'BLOCKED')}
                              className="text-red-600 hover:text-red-900 bg-gray-100 p-2 rounded-md transition-colors"
                              title="Khóa tài khoản">
                              <LockKeyhole size={18} />
                            </button>
                          )}

                          {/* unlock */}
                          {operator.status === 'BLOCKED' && (
                            <button onClick={() => handleStatusChange(operator.id,'ACTIVE')}
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
                    <td colSpan="5" className="px-6 py-10 text-center text-gray-500">
                      Không tìm thấy nhà xe nào phù hợp.
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
      </div>
    </div>
  );
};

export default AdminManageCompany;