import api from "./api";
import {toEng} from "../utils/translate"
const StaffService = {
    getStaff(filterParams){
        const params = {...filterParams};
        const role = params.role;
        params.role = (role === "Tất Cả" ? null : toEng(role));
        const status = params.status;
        params.status = (status === "Tất Cả" ? null : toEng(status));
        const page = params.page;
        params.page = (page > 0 ? page - 1 : 0);
        return api.get("/nhaxe/member", {params: params});
    },
    createStaff(staff){
        const userRaw = localStorage.getItem("user")
        const user = userRaw ? JSON.parse(userRaw) : null;
        
        const newStaff = {...staff, busCompanyId:user.busCompanyId, 
            role: toEng(staff.role), gender: toEng(staff.gender)};
        return api.post("/nhaxe/member", newStaff);
    }, 
    updateStaff(updatedStaff){
        const staff = {...updatedStaff, gender: toEng(updatedStaff.gender)};
        return api.put(`/nhaxe/member/${staff.id}`, staff)
    }
}
export default StaffService