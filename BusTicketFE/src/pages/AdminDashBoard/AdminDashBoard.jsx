import React from 'react';
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

// Mock data cho các biểu đồ
const monthlyData = [
  { month: 'T1', revenue: 450, tickets: 2400, newUsers: 400 },
  { month: 'T2', revenue: 380, tickets: 1398, newUsers: 300 },
  { month: 'T3', revenue: 520, tickets: 4800, newUsers: 550 },
  { month: 'T4', revenue: 480, tickets: 3908, newUsers: 480 },
  { month: 'T5', revenue: 610, tickets: 5800, newUsers: 620 },
  { month: 'T6', revenue: 590, tickets: 5400, newUsers: 590 },
  { month: 'T7', revenue: 750, tickets: 7300, newUsers: 850 },
];

const topBusCompanies = [
  { id: 1, name: 'Phương Trang', revenue: '1.250.000.000 ₫', tickets: 5420, trend: 'up', trendValue: '+15%' },
  { id: 2, name: 'Thành Bưởi', revenue: '980.000.000 ₫', tickets: 4100, trend: 'up', trendValue: '+8%' },
  { id: 3, name: 'Hải Vân', revenue: '750.000.000 ₫', tickets: 3200, trend: 'down', trendValue: '-2%' },
  { id: 4, name: 'Hoàng Long', revenue: '620.000.000 ₫', tickets: 2800, trend: 'up', trendValue: '+5%' },
  { id: 5, name: 'Kumho Samco', revenue: '450.000.000 ₫', tickets: 1950, trend: 'up', trendValue: '+11%' },
];

// Component Card Thống kê
const StatCard = ({ title, value, icon: Icon, trend, trendValue, iconColor, bgColor }) => (
  <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
    <div className="flex justify-between items-start">
      <div>
        <p className="text-sm font-medium text-gray-500 mb-1">{title}</p>
        <h3 className="text-2xl font-bold text-gray-800">{value}</h3>
      </div>
      <div className={`p-3 rounded-xl ${bgColor} ${iconColor}`}>
        <Icon size={24} strokeWidth={2} />
      </div>
    </div>
    <div className={`flex items-center mt-4 text-sm ${trend === 'up' ? 'text-emerald-600' : 'text-red-600'}`}>
      {trend === 'up' ? <TrendingUp size={16} className="mr-1"/> : <TrendingDown size={16} className="mr-1"/>}
      <span className="font-semibold">{trendValue}</span>
      <span className="text-gray-400 ml-2 font-normal">so với tháng trước</span>
    </div>
  </div>
);

const AdminDashboard = () => {
  return (
    <div className="p-6 bg-slate-50 min-h-screen font-sans">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Tổng quan hệ thống</h1>
        <p className="text-gray-500 mt-1">Theo dõi các chỉ số hoạt động và doanh thu của nền tảng.</p>
      </div>

      {/* Grid 4 Cards Thống kê */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 mb-8">
        <StatCard 
          title="Tổng số nhà xe" 
          value="128" 
          icon={Bus} 
          trend="up" 
          trendValue="+12" 
          iconColor="text-blue-600" 
          bgColor="bg-blue-50" 
        />
        <StatCard 
          title="Tổng số khách hàng" 
          value="45,231" 
          icon={Users} 
          trend="up" 
          trendValue="+18.2%" 
          iconColor="text-indigo-600" 
          bgColor="bg-indigo-50" 
        />
        <StatCard 
          title="Doanh thu toàn hệ thống" 
          value="8.45 Tỉ ₫" 
          icon={CircleDollarSign} 
          trend="up" 
          trendValue="+24.5%" 
          iconColor="text-emerald-600" 
          bgColor="bg-emerald-50" 
        />
        <StatCard 
          title="Tỉ lệ hủy vé" 
          value="3.2%" 
          icon={Ban} 
          trend="down" 
          trendValue="-0.8%" 
          iconColor="text-rose-600" 
          bgColor="bg-rose-50" 
        />
      </div>

      {/* Khu vực Biểu đồ */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        
        {/* Biểu đồ Doanh thu (Area Chart chiếm 2 cột) */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm lg:col-span-2">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-lg font-bold text-gray-800">Doanh thu theo tháng (Triệu VNĐ)</h2>
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
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
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
                  <th className="pb-3 font-medium text-right">Tăng trưởng</th>
                </tr>
              </thead>
              <tbody className="text-sm">
                {topBusCompanies.map((bus) => (
                  <tr key={bus.id} className="border-b border-gray-50 hover:bg-slate-50 transition-colors">
                    <td className="py-4 font-semibold text-gray-800">{bus.name}</td>
                    <td className="py-4 text-gray-600">{bus.tickets.toLocaleString()}</td>
                    <td className="py-4 font-medium text-gray-900">{bus.revenue}</td>
                    <td className="py-4 text-right">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        bus.trend === 'up' ? 'bg-emerald-100 text-emerald-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {bus.trendValue}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </div>
  );
};

export default AdminDashboard;