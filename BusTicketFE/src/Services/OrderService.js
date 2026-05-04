import api from "./api";

const OrderService = {
    createPayment({payload}){
        const res = api.post(`/momo/payment`, payload);
        return res;
    },
    holdSeats({tripId, tripSeatIdList}){
        const res = api.post(`/nhaxe/orders/hold-seats/${tripId}`, {tripSeatIdList});
        return res;
    }, 
    unHoldSeats({tripId, bookingOrderId, tripSeatIdList}){
        const res = api.post(`/nhaxe/orders/unhold-seats/${tripId}`, {bookingOrderId, tripSeatIdList});
        return res;
    }, 
    bookOrderByCompany({tripId, payload}){
        console.log(tripId, payload);
        const res = api.post(`/nhaxe/orders/book-order/${tripId}`, payload);
        return res;
    }
}

export default OrderService;