import { publicApi } from "./api";

export const searchProvinces = (keyword) => {
  return publicApi.get("/provinces", { params: { keyword } });
};

export const getPickupStops = (provinceId, keyword) => {
  return publicApi.get(`/provinces/${provinceId}/pickup-stops`, {
    params: { keyword },
  });
};

export const getDropoffStops = (provinceId, keyword) => {
  return publicApi.get(`/provinces/${provinceId}/dropoff-stops`, {
    params: { keyword },
  });
};

export const findAllStops = (province, keyword) => {
  return publicApi.get("/stops", { params: { province, keyword } });
};
