import React, { useEffect, useState } from 'react';
import AdminReportService from '../../Services/AdminReportService';
import {
  Bus,
  Users,
  CircleDollarSign,
  Ban,
  TrendingUp,
  TrendingDown
} from 'lucide-react';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  BarChart, Bar, LineChart, Line, Legend
} from 'recharts';

// Component Card Thống kê
const StatCard = ({ title, value, icon: IconComponent, iconColor, bgColor }) => (
  <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
    <div className="flex justify-between items-start">
      <div>
        <p className="text-sm font-medium text-gray-500 mb-1">{title}</p>
        <h3 className="text-2xl font-bold text-gray-800">{value}</h3>
      </div>
      <div className={`p-3 rounded-xl ${bgColor} ${iconColor}`}>
        <IconComponent size={24} strokeWidth={2} />
      </div>
    </div>
  </div>
);

const formatVND = (v) => {
  if (v == null) return '0 ₫';
  return new Intl.NumberFormat('vi-VN').format(v) + ' ₫';
};

const AdminDashboard = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [monthlyData, setMonthlyData] = useState([]); // { month, revenue, tickets, newUsers }
  const [companies, setCompanies] = useState([]); // revenueCompanyList
  const [totals, setTotals] = useState({
    companiesCount: 0,
    totalCustomer: 0,
    totalTicketCurrentMonth: 0,
    canceledTicketCurrentMonth: 0,
    totalRevenueCurrentMonth: 0
  });

  useEffect(() => {
    let mounted = true;

    const loadReports = async () => {
      setLoading(true);
      setError(null);

      try {
        const [custRes, ticketRes, revRes, companyRes] = await Promise.all([
          AdminReportService.getCustomerReport(),
          AdminReportService.getTicketReport(),
          AdminReportService.getRevenueReport(), 
          AdminReportService.getCompanyReport()
        ]);

        if (!mounted) return;

        // Extract arrays
        const customerByMonth = custRes?.result?.customerByMonth || [];
        const ticketByMonth = ticketRes?.result?.ticketByMonth || [];
        const revenueByMonth = revRes?.result?.revenueByMonth || [];

        const length = Math.max(customerByMonth.length, ticketByMonth.length, revenueByMonth.length);
        const merged = [];
        for (let i = 0; i < length; i++) {
          const cm = customerByMonth[i] || { month: `M${i+1}`, customerCount: 0 };
          const tm = ticketByMonth[i] || { month: cm.month, ticketCount: 0 };
          const rm = revenueByMonth[i] || { month: cm.month, amount: 0 };

          merged.push({
            month: 'T' + parseInt(cm.month.slice(0, 2)),
            // làm tròn 2 chữ số thập phân sau khi chia để hiển thị doanh thu theo triệu
            revenue: Math.round((rm.amount / 1000000) * 100) / 100,
            tickets: tm.ticketCount,
            newUsers: cm.customerCount
          });
        }

        setMonthlyData(merged);

        const revenueCompanyList = revRes?.result?.revenueCompanyList || [];
        setCompanies(revenueCompanyList);

        setTotals((t) => ({
          ...t,
          totalCustomer: custRes?.result?.totalCustomer ?? 0,
          totalTicketCurrentMonth: ticketRes?.result?.totalTicketCurrentMonth ?? 0,
          canceledTicketCurrentMonth: ticketRes?.result?.canceledTicketCurrentMonth ?? 0,
          totalRevenueCurrentMonth: revRes?.result?.totalRevenueCurrentMonth ?? 0,
          companiesCount: companyRes?.result ?? 0
        }));

      } catch (err) {
        console.error(err);
        if (!mounted) return;
        setError('Lỗi khi tải dữ liệu báo cáo');
      } finally {
        if (mounted) setLoading(false);
      }
    };

    loadReports();

    return () => { mounted = false; };
  }, []);

  return (
    <div className="p-6 bg-slate-50 min-h-screen font-sans">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Tổng quan hệ thống</h1>
        <p className="text-gray-500 mt-1">Theo dõi các chỉ số hoạt động và doanh thu của nền tảng.</p>
      </div>

      {loading ? (
        <div className="text-center py-10 text-gray-500">Đang tải dữ liệu báo cáo...</div>
      ) : error ? (
        <div className="text-center py-10 text-red-500">{error}</div>
      ) : (
        <>
          {/* Grid 4 Cards Thống kê */}
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 mb-8">
            <StatCard
              title="Tổng số nhà xe"
              value={totals.companiesCount}
              icon={Bus}
              iconColor="text-blue-600"
              bgColor="bg-blue-50"
            />
            <StatCard
              title="Tổng số khách hàng"
              value={totals.totalCustomer.toLocaleString()}
              icon={Users}
              iconColor="text-indigo-600"
              bgColor="bg-indigo-50"
            />
            <StatCard
              title="Doanh thu tháng này"
              value={`${Math.round((totals.totalRevenueCurrentMonth / 1000000) * 100) / 100} Tr ₫`}
              icon={CircleDollarSign}
              iconColor="text-emerald-600"
              bgColor="bg-emerald-50" 
            />
            <StatCard
              title="Số vé hủy tháng này"
              value={totals.canceledTicketCurrentMonth}
              icon={Ban}
              iconColor="text-rose-600"
              bgColor="bg-rose-50"
            />
          </div>

          {/* Khu vực Biểu đồ */}
          <div className="grid grid-cols-1 lg:grid-cols-5 gap-6 mb-8">

            {/* Biểu đồ Doanh thu (Area Chart chiếm 2 cột) */}
            <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm lg:col-span-3">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-lg font-bold text-gray-800">Doanh thu theo tháng (VNĐ)</h2>
              </div>
              <div className="h-80 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={monthlyData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                    <defs>
                      <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#10b981" stopOpacity={0.3}/>
                        <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                    <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{fill: '#6b7280'}} dy={10} />
                    <YAxis axisLine={false} tickLine={false} tick={{fill: '#6b7280'}} />
                    <Tooltip
                      contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                      formatter={(value) => [`${value} Tr ₫`, 'Doanh thu']}
                    />
                    <Area type="monotone" dataKey="revenue" stroke="#10b981" strokeWidth={3} fillOpacity={1} fill="url(#colorRev)" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Biểu đồ Người dùng mới (Line Chart) */}
            <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm lg:col-span-2">
              <h2 className="text-lg font-bold text-gray-800 mb-6">Lượng người dùng mới</h2>
              <div className="h-80 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={monthlyData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                    <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{fill: '#6b7280'}} dy={10} />
                    <YAxis axisLine={false} tickLine={false} tick={{fill: '#6b7280'}} />
                    <Tooltip
                      contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                      formatter={(value) => [value, 'User mới']}
                    />
                    <Line type="monotone" dataKey="newUsers" stroke="#6366f1" strokeWidth={3} dot={{ r: 4, strokeWidth: 2 }} activeDot={{ r: 6 }} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>

          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

            {/* Biểu đồ Tổng số vé đã bán (Bar Chart) */}
            <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
              <h2 className="text-lg font-bold text-gray-800 mb-6">Tổng số vé đã bán theo tháng</h2>
              <div className="h-80 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={monthlyData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }} barSize={32}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                    <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{fill: '#6b7280'}} dy={10} />
                    <YAxis axisLine={false} tickLine={false} tick={{fill: '#6b7280'}} />
                    <Tooltip
                      cursor={{fill: '#f3f4f6'}}
                      contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                      formatter={(value) => [`${value} vé`, 'Đã bán']}
                    />
                    <Bar dataKey="tickets" fill="#3b82f6" radius={[6, 6, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Danh sách Top Nhà xe */}
            <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-lg font-bold text-gray-800">Top nhà xe doanh thu cao</h2>
                <a href="/admin/buses" className="text-sm font-medium text-blue-600 hover:text-blue-800">Xem tất cả</a>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="border-b border-gray-100 text-sm text-gray-500">
                      <th className="pb-3 font-medium">Nhà xe</th>
                      <th className="pb-3 font-medium">Số vé bán ra</th>
                      <th className="pb-3 font-medium">Doanh thu</th>
                    </tr>
                  </thead>
                  <tbody className="text-sm">
                    {companies.map((bus, idx) => (
                      <tr key={idx} className="border-b border-gray-50 hover:bg-slate-50 transition-colors">
                        <td className="py-4 font-semibold text-gray-800">{bus.companyName}</td>
                        <td className="py-4 text-gray-600">{(bus.ticketCount || 0).toLocaleString()}</td>
                        <td className="py-4 font-medium text-gray-900">{formatVND(bus.amount)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

          </div>
        </>
      )}

    </div>
  );
};

export default AdminDashboard;