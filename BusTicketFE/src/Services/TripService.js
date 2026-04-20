import { toEng } from "../utils/translate";
import { publicApi } from "./api";
import api from "./api";

const TripService = {
    getTripList({filterParams}){
        const params = {...filterParams, 
            page: filterParams.page - 1};
        if(params.status === "Tất Cả" || !params.status) params.status = null;
        else params.status = toEng(params.status);
        if(params.busType === "Tất Cả" || !params.busType) params.busType = null;
        return api.get("/nhaxe/trips", {params:params});
    }, 
    createTrip(newTrip){
        const trip = {
            routeId: newTrip.route.id, 
            busTypeId: newTrip.busType.id,
            departureTime: newTrip.departureTime
        }
        trip.price = (Number.isFinite(newTrip.price) ? newTrip.price : null)
        trip.licensePlate = (newTrip.licensePlate ? newTrip.licensePlate : null)
        trip.driver = (newTrip.driver ? newTrip.driver : null)
        return api.post("/nhaxe/trips", trip)
    }, 
    updateTrip(selectedTrip){
        // console.log("in service")
        const trip = {
            routeId: selectedTrip.route.id, 
            busTypeId: selectedTrip.busType.id,
            departureTime: selectedTrip.departureTime,
            status: selectedTrip.status
        }
        trip.price = (Number.isFinite(selectedTrip.price) ? selectedTrip.price : null)
        trip.licensePlate = (selectedTrip.licensePlate ? selectedTrip.licensePlate : null)
        trip.driver = (selectedTrip.driver ? selectedTrip.driver : null)
        return api.put(`/nhaxe/trips/${selectedTrip.id}`, trip)
    }, 
    openTrip(tripId){
        return api.put(`/nhaxe/trips/open/${tripId}`);
    }
}

export default TripService;