import api from "./api";

const AdminService = {
    getBusCompanyPage({filterParams}){
        const params = {...filterParams, 
            page: filterParams.page - 1};
        if(params.status === "All" || !params.status) params.status = null; 
        if (params.sortOrder === "All" || !params.sortOrder) {
            params.sort = `createdAt,desc`;
        } else {
            params.sort = `createdAt,${params.sortOrder}`;
        }
        delete params.sortOrder;
        return api.get("/admin/company-page", {params:params});
    },
    changeStatusBusCompany(companyId, newStatus){
        return api.put(`/admin/company-status/${companyId}`, { status: newStatus });
    },
    getCompanyRegisterPage({filterParams}){
       
        const params = {...filterParams, 
            page: filterParams.page - 1};
        if(params.status === "All" || !params.status) params.status = null;

        if (params.sortOrder === "All" || !params.sortOrder) {
            params.sort = `updatedAt,desc`;
        } else {
            params.sort = `updatedAt,${params.sortOrder}`;
        }
        delete params.sortOrder;
        return api.get("/admin/company-register-page", {params:params});
    }, 
    acceptCompanyRegistration(companyRegisterId){
        return api.post(`/admin/company-register/accepted/${companyRegisterId}`);
    }, 
    rejectCompanyRegistration(companyRegisterId){
        return api.post(`/admin/company-register/rejected/${companyRegisterId}`); 
    },
    getAccountPage({filterParams, type}){
        const params = {...filterParams, 
            page: filterParams.page - 1};
        if(params.status === "All" || !params.status) params.status = null; 
        if (params.sortOrder === "All" || !params.sortOrder) {
            params.sort = `createdAt,desc`;
        } else {
            params.sort = `createdAt,${params.sortOrder}`;
        }
        delete params.sortOrder;
        console.log("params",  params);
        // type: 'CUSTOMER' or 'STAFF' 
        return api.get(`/admin/${type.toLowerCase()}-page`, {params:params});
    },

    changeStatusAccount(id, type, newStatus){
        return api.put(`/admin/${type.toLowerCase()}-status/${id}`, { status: newStatus });
    }  
}

export default AdminService;
