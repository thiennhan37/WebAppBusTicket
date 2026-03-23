import api from "./api";

const StaffService = {
    getAllStaff(){
        return api.get("/nhaxe/member");
    }
    
}

export default StaffService