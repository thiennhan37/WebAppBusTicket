import React from 'react';
import {motion} from 'framer-motion';
import {Route, Bus, Ticket, Wallet, CheckCircle2, Clock3, AlertCircle} from 'lucide-react';
import QuickStats from './QuickStats';
import ReportHeader from './ReportHeader';
import SalesChannel from './SalesChannel';
import UpcomingTrips from './UpcomingTrips';
import RevenueChart from './RevenueChart';
import TicketSales from './TicketSales';
import { useQueryClient } from '@tanstack/react-query';
import ReportService from '../../Services/ReportService';
import { useQuery } from '@tanstack/react-query';









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
    queryFn: async () => {
      const response = await ReportService.getStaffReport();
      return response.data.result;  
    } 
  });
  const {data: revenueReportData, isLoading: revenueIsLoading} = useQuery({
    queryKey: ['report-revenue'],
    queryFn: async () => {
      const response = await ReportService.getRevenueReport();
      return response.data.result;
    } 
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

  const {data: ticketReportData, isLoading: ticketIsLoading} = useQuery({
    queryKey: ['report-ticket'],
    queryFn: async () => {
      const response = await ReportService.getTicketReport();
      return response.data.result;
    } 
  });

  const TicketStatus = [
    { name: 'Đã thanh toán', value: ticketReportData?.paidTicketCount, color: '#3b82f6' },   // Blue
    { name: 'Đang xử lí', value: ticketReportData?.holdingTicketCount, color: '#8b5cf6' },  // Violet
    { name: 'Đã hủy', value: ticketReportData?.cancelledTicketCount, color: '#10b981' },  // Emerald
    { name: 'Đã hết hạn', value: ticketReportData?.expiredTicketCount, color: '#f59e0b' },    // Amber
  ]; 

  const channelData = [
    { label: 'Qua tổng đài', count: ticketReportData?.phoneBookedTicketCount, 
      percent: Math.round((ticketReportData?.phoneBookedTicketCount * 100) /
        (ticketReportData?.phoneBookedTicketCount + ticketReportData?.appBookedTicketCount)), 
      icon: CheckCircle2, color: 'text-emerald-500', bg: 'bg-emerald-50' 
    },
    { label: 'Qua app', count: ticketReportData?.appBookedTicketCount, 
      percent: 100 - Math.round((ticketReportData?.phoneBookedTicketCount * 100) /
        (ticketReportData?.phoneBookedTicketCount + ticketReportData?.appBookedTicketCount)), 
      icon: Clock3, color: 'text-amber-500', bg: 'bg-amber-50' 
    },
  ];


  const {data: tripReportData, isLoading: tripIsLoading} = useQuery({
    queryKey: ['report-trip'],
    queryFn: async () => {
      const response = await ReportService.getTripReport();
      return response.data.result;
    }
  });

  const upcomingTrips = tripReportData?.nextScheduledTripList ? tripReportData?.nextScheduledTripList : [];

  const {data: routeReportData, isLoading: routeIsLoading} = useQuery({
    queryKey: ['report-route'],
    queryFn: async () => {
      const response = await ReportService.getRouteReport();
      return response.data.result;
    }
  });  
  const routesData = routeReportData?.map((route) => ({
    route: route.routeName,
    soldCount: route.ticketCount,
  }));

  const statsData = [
    { title: 'Nhân viên (Tháng này)', value: staffReportData?.staffCountCurrentMonth, 
      trend: ` ${staffReportData?.staffCountCurrentMonth - staffReportData?.staffCountPreviousMonth >= 0 ? `+` : ``}
        ${staffReportData?.staffCountCurrentMonth - staffReportData?.staffCountPreviousMonth} nhân viên so với tháng trước`, 
      icon: Route, color: 'text-blue-600', bg: 'bg-blue-100' },
    
    { title: 'Vé bán ra (Tháng này)', value: ticketReportData?.ticketCountCurrentMonth, 
        trend: `${ticketReportData?.ticketCountCurrentMonth - ticketReportData?.ticketCountPreviousMonth >= 0 ? `+` : ``}
        ${ticketReportData?.ticketCountCurrentMonth - ticketReportData?.ticketCountPreviousMonth} vé so với tháng trước`,
       icon: Ticket, color: 'text-emerald-600', bg: 'bg-emerald-100' },

    { title: 'Chuyến h.động (Hôm nay)', value: tripReportData?.activeTripCount, trend: '', icon: Bus, color: 'text-violet-600', bg: 'bg-violet-100' },
    
    { title: 'Doanh thu (Tháng này)', value: revenueReportData?.revenueCurrentMonth, 
       trend: ``,
       icon: Wallet, color: 'text-amber-600', bg: 'bg-amber-100' },
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
        <SalesChannel TicketStatus={TicketStatus} channelData={channelData}/>

      </motion.div>

      {/* --- TABLES & LISTS SECTION --- */}
      <motion.div variants={itemVariants} className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        <UpcomingTrips upcomingTrips={upcomingTrips}/>
        <TicketSales routesData={routesData} itemVariants={itemVariants}></TicketSales>

      </motion.div>
    </motion.div>
  );
}

export default Report;
