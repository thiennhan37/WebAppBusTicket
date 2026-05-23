import api from "./api";

const AdminReportService = {
  // Lấy báo cáo khách hàng theo tháng
  async getCustomerReport() {
    const res = await api.get('/admin-report/customer');
    return res.data;
  },

  // Lấy báo cáo vé theo tháng
  async getTicketReport() {
    const res = await api.get('/admin-report/ticket');
    return res.data;
  },

  // Lấy báo cáo doanh thu theo tháng và danh sách doanh thu theo công ty
  async getRevenueReport() {
    const res = await api.get('/admin-report/revenue');
    return res.data;
  }
};

export default AdminReportService;
