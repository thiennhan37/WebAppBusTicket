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
        const res = api.post(`/nhaxe/orders/book-order/${tripId}`, payload);
        return res;
    }, 
    cancelTicketByCompany({tripId, ticketIdList}){
        const res = api.post(`/nhaxe/orders/cancel-tickets/${tripId}`, {ticketIdList});
        return res;
    }, 
    updateTicketByCompany({tripId, payload}){
        console.log(payload);
        if(!payload.arrialId) payload.arrialId = null;
        if(!payload.destinationId) payload.destinationId = null;
        if(!payload.customerName) payload.customerName = null;
        if(!payload.customerPhone) payload.customerPhone = null;
        const res = api.put(`/nhaxe/orders/update-ticket/${tripId}`, payload);
        return res;
    }
}

export default OrderService;