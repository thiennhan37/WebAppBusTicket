

import api from "../services/api"

const ReportService = {
    getStaffReport(){
        return api.get(`/nhaxe/report/staff`);
    },
    getRevenueReport(){
        return api.get(`/nhaxe/report/revenue`);
    },
    getTicketReport(){
        return api.get(`/nhaxe/report/ticket`);
    },
    getTripReport(){
        return api.get(`/nhaxe/report/trip`);
    }, 
    getRouteReport(){
        return api.get(`/nhaxe/report/route`);
    },

}

export default ReportService;