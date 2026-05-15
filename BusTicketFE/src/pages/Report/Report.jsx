import React from 'react';
import {motion} from 'framer-motion';
import {Route, Bus, Ticket, Wallet} from 'lucide-react';
import QuickStats from './QuickStats';
import ReportHeader from './ReportHeader';
import SalesChannel from './SalesChannel';
import UpcomingTrips from './UpcomingTrips';
import RevenueChart from './RevenueChart';
import TicketSales from './TicketSales';
import { useQueryClient } from '@tanstack/react-query';
import ReportService from '../../Services/ReportService';
import { useQuery } from '@tanstack/react-query';

const statsData = [
  { title: 'Nhân viên', value: '24', trend: '+2 nhân viên mới', icon: Route, color: 'text-blue-600', bg: 'bg-blue-100' },
  { title: 'Chuyến h.động (Hôm nay)', value: '156', trend: 'Hoạt động 98%', icon: Bus, color: 'text-violet-600', bg: 'bg-violet-100' },
  { title: 'Vé bán ra (Hôm nay)', value: '1,240', trend: '+12% so với hôm qua', icon: Ticket, color: 'text-emerald-600', bg: 'bg-emerald-100' },
  { title: 'Doanh thu (Hôm nay)', value: '315M', trend: '+5% so với tuần trước', icon: Wallet, color: 'text-amber-600', bg: 'bg-amber-100' },
];



const salesData = [
  { route: 'HN - Sapa', soldCount: 38 },
  { route: 'HCM - Đà Lạt', soldCount: 32 },
  { route: 'HN - Hải Phòng', soldCount: 25 },
  { route: 'Đà Nẵng - Huế', soldCount: 15 },
];

const upcomingTrips = [
  { id: 'TR-101', route: 'Hà Nội - Sapa', time: '10:30', status: 'Sắp khởi hành', fill: '38/40', type: 'Limousine 34T' },
  { id: 'TR-102', route: 'HCM - Đà Lạt', time: '11:00', status: 'Đang đón khách', fill: '32/34', type: 'Giường nằm 40C' },
  { id: 'TR-103', route: 'Hà Nội - Hải Phòng', time: '11:30', status: 'Lên lịch', fill: '25/45', type: 'Ghế ngồi 45C' },
  { id: 'TR-104', route: 'Đà Nẵng - Huế', time: '12:00', status: 'Lên lịch', fill: '15/30', type: 'Limousine 9C' },
];

const recentActivities = [
  { id: 1, action: 'Bán vé thành công', details: '2 vé - Chuyến HN-Sapa (10:30)', time: '5 phút trước' },
  { id: 2, action: 'Gửi link thanh toán', details: 'Khách hàng: Nguyễn Văn A', time: '12 phút trước' },
  { id: 3, action: 'Cập nhật chuyến', details: 'Gán xe 29B-123.45 cho chuyến TR-102', time: '30 phút trước' },
  { id: 4, action: 'Bán vé qua tổng đài', details: '1 vé - Chuyến HCM-Đà Lạt', time: '45 phút trước' },
];

// ==========================================
// 2. ANIMATION VARIANTS
// ==========================================
  const containerVariants = {
    hidden: { opacity: 0 },
    show: { opacity: 1, transition: { staggerChildren: 0.1 } }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { duration: 0.4 } }
  };

const Report = () => {
  const queryClient = useQueryClient();
  const {data: staffReportData, isLoading} = useQuery({
    queryKey: ['report-staffs'],
    queryFn: () => ReportService.getStaffReport().data.result,  
  });
  const {data: revenueReportData, isLoading: revenueIsLoading} = useQuery({
    queryKey: ['report-revenue'],
    queryFn: async () => {
      const response = await ReportService.getRevenueReport().data.result;
      return response;
    } 
  });  

  const {data: ticketReportData, isLoading: ticketIsLoading} = useQuery({
    queryKey: ['report-ticket'],
    queryFn: () => ReportService.getTicketReport().data.result,
  });
  const {data: tripReportData, isLoading: tripIsLoading} = useQuery({
    queryKey: ['report-trip'],
    queryFn: () => ReportService.getTripReport().data.result,
  });
  const {data: routeReportData, isLoading: routeIsLoading} = useQuery({
    queryKey: ['report-route'],
    queryFn: () => ReportService.getRouteReport().data.result,
  });  
  const revenueData = [
  { day: 'T2', revenue: revenueReportData?.revenueWeekList?.[0] },
  { day: 'T3', revenue: revenueReportData?.revenueWeekList?.[1] },
  { day: 'T4', revenue: revenueReportData?.revenueWeekList?.[2] },
  { day: 'T5', revenue: revenueReportData?.revenueWeekList?.[3] },
  { day: 'T6', revenue: revenueReportData?.revenueWeekList?.[4] },
  { day: 'T7', revenue: revenueReportData?.revenueWeekList?.[5] },
  { day: 'CN', revenue: revenueReportData?.revenueWeekList?.[6] },
];
  return (
    <motion.div 
      className="min-h-screen bg-slate-50 text-slate-800 p-6 font-sans"
      variants={containerVariants}
      initial="hidden"
      animate="show"
    >
      <ReportHeader itemVariants={itemVariants}></ReportHeader>

      <QuickStats statsData={statsData} itemVariants={itemVariants}></QuickStats>

      <motion.div variants={itemVariants} className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
            
        <RevenueChart revenueData={revenueData} itemVariants={itemVariants}></RevenueChart>
        <SalesChannel/>

      </motion.div>

      {/* --- TABLES & LISTS SECTION --- */}
      <motion.div variants={itemVariants} className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        <UpcomingTrips upcomingTrips={upcomingTrips}/>
        <TicketSales salesData={salesData} itemVariants={itemVariants}></TicketSales>

      </motion.div>
    </motion.div>
  );
}

export default Report;
