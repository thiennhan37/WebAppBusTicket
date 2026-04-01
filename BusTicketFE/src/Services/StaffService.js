import api from "./api";
import {toVN, toEng} from "../utils/translate"
const StaffService = {
    getStaff(filterParams){
        const params = {...filterParams};

        const role = params.role;
        params.role = (role === "Tất Cả" ? null : toEng(role));
        const status = params.status;
        params.status = (status === "Tất Cả" ? null : toEng(status));
        const page = params.page;
        params.page = (page > 0 ? page - 1 : 0);
        console.log(params);
        return api.get("/nhaxe/member", {params: params});
    },
    createStaff(staff){
        const userRaw = localStorage.getItem("user")
        const user = userRaw ? JSON.parse(userRaw) : null;
        staff.role = toEng(staff.role);
        
        const newStaff = {...staff, busCompanyId:user.busCompanyId};
        console.log("create:", newStaff);

        return api.post("/nhaxe/member", newStaff);
    }
}

export default StaffService