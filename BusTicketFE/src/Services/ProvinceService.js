import { publicApi } from "./api";

const ProvinceService = {
    getProvinces({filterParams}){
        const params = {...filterParams, page: 0};
        return publicApi.get("/provinces", {params:params});
    }, 
    getStops({filterParams}){
        const params = {...filterParams, page:0};
        if(!params.keyword) params.keyword = null;
        if(!params.province) return Promise.resolve({data:{result: []}}); // nếu không có tỉnh thì trả về mảng rỗng luôn, tránh gọi API không cần thiết
        return publicApi.get(`/stops`, {params:params});
    }, 
}

export default ProvinceService;