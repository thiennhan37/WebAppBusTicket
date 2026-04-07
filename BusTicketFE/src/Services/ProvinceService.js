import { publicApi } from "./api";

const ProvinceService = {
    getProvinces({filterParams}){
        const params = {...filterParams, page: 0};
        return publicApi.get("/provinces", {params:params});
    }
}

export default ProvinceService;