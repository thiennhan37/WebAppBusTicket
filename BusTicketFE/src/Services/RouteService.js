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
    createRoute({newRoute}){
        let route = {};
        route.name = newRoute.name;
        route.upStopIdList = newRoute.upStopList.map(stop => (stop.id));
        route.downStopIdList = newRoute.downStopList.map(stop => (stop.id));
        route.arrivalId = newRoute.arrival.id;
        route.destinationId = newRoute.destination.id;
        route.busCompanyId = JSON.parse(localStorage.getItem("company")).id;
        // console.log("Creating route with data: ", route);
        return api.post("/nhaxe/routes", route);
    }
}

export default RouteService;