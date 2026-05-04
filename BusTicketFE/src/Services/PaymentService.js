import api, { publicApi } from "./api";

const OrderService = {
    getPayUrlForCustomer(paymentId){
        console.log(typeof paymentId);
        const res = publicApi.post(`/momo/payment-url`, {paymentId});
        return res;
    },

}

export default OrderService;