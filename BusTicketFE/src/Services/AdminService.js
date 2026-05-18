import api from "./api";

const AdminService = {
    getBusCompanyPage({filterParams}){
        const params = {...filterParams, 
            page: filterParams.page - 1};
        if(params.status === "All" || !params.status) params.status = null;
        if(params.sortOrder === "All" || !params.sortOrder) params.sortOrder = null;
        return api.get("/admin/company-page", {params:params});
    },
    changeStatusBusCompany(companyId, newStatus){
        return api.put(`/admin/company-status/${companyId}`, { status: newStatus });
    },
    getCompanyRegisterPage({filterParams}){
       
        const params = {...filterParams, 
            page: filterParams.page - 1};
        if(params.status === "All" || !params.status) params.status = null;
        if(params.sortOrder === "All" || !params.sortOrder) params.sortOrder = null;
        console.log("params", params);
        return api.get("/admin/company-register-page", {params:params});
    }, 
    // changeStatusCompanyRegister(companyId, newStatus){
    //     return api.put(`/admin/company-register-status/${companyId}`, { status: newStatus });
    // }
}

export default AdminService;
