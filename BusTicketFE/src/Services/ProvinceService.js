import { publicApi } from "./api";

const ProvinceService = {
    getProvinces(filterParams){
        const params = {...filterParams, page: 0};
        if(!params.keyword) params.keyword = null;
        return publicApi.get("/nhaxe/routes", {params:params});
    }
}

export default ProvinceService;