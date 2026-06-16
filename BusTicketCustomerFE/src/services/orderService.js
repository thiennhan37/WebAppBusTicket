import api from "./api";

export const holdSeats = (tripId, seatData) => {
  return api.post(`/customer/orders/hold-seats/${tripId}`, seatData);
};

export const createPayment = (orderId, paymentData) => {
  return api.post(`/customer/orders/payment/${orderId}`, paymentData);
};

export const getRecentOrders = () => {
  return api.get("/customer/orders/recent");
};

export const getOrderDetail = (orderId) => {
  return api.get(`/customer/order/detail/${orderId}`);
};

export const unholdSeats = (orderId) => {
  return api.post(`/customer/orders/unhold-seats/${orderId}`);
};

export const isOrderPaid = (bookingOrderId) => {
  return api.get("/customer/orders/payment-status", {
    params: { bookingOrderId },
  });
};

export const createVNPayPayment = (orderId) => {
  return api.post(`/vnpay/payment-url/${orderId}`);
};

export const rateTrip = (orderId, ratingData) => {
  return api.post(`/customer/orders/${orderId}/rating`, ratingData);
};

export const getTripRating = (orderId) => {
  return api.get(`/customer/orders/${orderId}/rating`);
};
