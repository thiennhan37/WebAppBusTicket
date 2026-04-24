import { publicApi } from "./api";

const OrderService = {
    holdSeats: async ({tripId, tricketIdList}) => {
        const res = await publicApi.post(`/orders/hold-seats/${tripId}`, tricketIdList);
        return res;
    }
}

export default OrderService;