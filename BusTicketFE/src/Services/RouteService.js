import api from "./api"

const RouteService = {
    getRoutes({filterParams}){
        const params = {...filterParams, 
            page: filterParams.page - 1};
        if(params.arrival === "") params.arrival = null;
        if(params.destination === "") params.destination = null;
        if(!params.keyword) params.keyword = null;
        return api.get("/nhaxe/routes", {params:params});
    },
    getRouteStop({routeId, params}){
        return api.get(`/nhaxe/routes/${routeId}`, {params:params});
    }, 
    getStops({filterParams}){
        const params = {...filterParams, page:0};
        if(!params.keyword) params.keyword = null;
        if(!params.province) return Promise.resolve({data:{result: []}}); // nếu không có tỉnh thì trả về mảng rỗng luôn, tránh gọi API không cần thiết
        return api.get(`/stops`, {params:params});
    }
}

export default RouteService;