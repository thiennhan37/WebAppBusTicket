import api from "./api";

const StaffService = {
    getAllStaff(){
        return api.get("/users");
    }
    
}

export default StaffService