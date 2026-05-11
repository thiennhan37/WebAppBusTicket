import { publicApi } from "./api";


const BusService = {
    getBusTypeList(){
        return publicApi.get("/bus-type");
    }, 
    
}

export default BusService;