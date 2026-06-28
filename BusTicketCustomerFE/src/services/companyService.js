import { publicApi } from "./api";

export const getCompaniesWithHighRating = () => {
  return publicApi.get("/customer/companiesWithHighRating");
};
