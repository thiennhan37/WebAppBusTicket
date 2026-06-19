import { publicApi } from "./api";

export const searchTrips = (params) => {
  return publicApi.get("/trips/search", { params });
};

export const getBusDiagram = (tripId) => {
  return publicApi.get("/trips/bus-diagram", { params: { tripId } });
};

export const getTripStops = (tripId) => {
  return publicApi.get("/trips/stops", { params: { tripId } });
};

export const getStops = (provinceID) => {
  return publicApi.get("/trips/stops", { params: { provinceID } });
};

export const getCompaniesInfo = (provinceID) => {
  return publicApi.get("/trips/get-companies-info", { params: { provinceID } });
};
