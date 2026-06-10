
import api from "./api";

const BusCompanyService = {
    getBusCompanyById(companyId){
        return api.get(`/nhaxe/bus-company/${companyId}`);
    },
    updateBusCompany({companyId, params}){
        console.log("params of update bus company: ", params);
        const formData = new FormData();
        formData.append('policy', params.policy);
        if(params.avatarFile){
            formData.append('avatarFile', params.avatarFile);
        }

        return api.put(`/nhaxe/bus-company/${companyId}`, formData,
            { headers:{"Content-Type":"multipart/form-data"}}
        ); 
    },
    getCustomersForChat({ phone = "", page = 0, size = 10 } = {}) {
        return api.get("/nhaxe/customer-info-chat", {
            params: {
                phone: phone || "",
                page,
                size,
            },
        });
    },
}

export default BusCompanyService;