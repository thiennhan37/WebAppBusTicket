import axios from "axios";

const appURL = "http://47.129.116.239:8080/vexedat";
// const appURL = "http://localhost:8080/vexedat";
const timeout = 20000;

export const publicApi = axios.create({
    baseURL: appURL,
    timeout: timeout,
    withCredentials: true,
    headers: {
        "Content-Type": "application/json",
    },
});

publicApi.interceptors.response.use(
    (config) => config,
    (error) => Promise.reject(error)
);

const api = axios.create({
    baseURL: appURL,
    timeout: timeout,
    headers: {
        "Content-Type": "application/json",
    },
});

api.interceptors.request.use(
    (config) => {
        const accessToken = localStorage.getItem("accessToken");
        if (accessToken) {
            config.headers.Authorization = `Bearer ${accessToken}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

let isRefreshing = false;
let requestRunningList = [];

const pushRequestIntoQueue = (resolve, reject) => {
    requestRunningList.push({resolve, reject});
};

const onSuccess = (token) => {
    requestRunningList.forEach(({resolve}) => resolve(token));
    requestRunningList = [];
};

const onFailed = (error) => {
    requestRunningList.forEach(({reject}) => reject(error));
    requestRunningList = [];
};

api.interceptors.response.use(
    (response) => response,
    async (error) => {
        const {config, response} = error;
        const originalRequest = config;

        if (response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;

            if (!isRefreshing) {
                isRefreshing = true;

                try {
                    const res = await publicApi.post("/auth/refresh-token", {});
                    const {accessToken} = res.data.result;
                    localStorage.setItem("accessToken", accessToken);

                    isRefreshing = false;
                    onSuccess(accessToken);

                    originalRequest.headers.Authorization = `Bearer ${accessToken}`;
                    return api(originalRequest);
                } catch (refreshError) {
                    isRefreshing = false;
                    window.location.href = "/khachhang/dang-nhap";
                    localStorage.clear();
                    onFailed(refreshError);
                    return Promise.reject(refreshError);
                }
            }

            return new Promise((resolve, reject) => {
                pushRequestIntoQueue(
                    (token) => {
                        originalRequest.headers.Authorization = `Bearer ${token}`;
                        resolve(api(originalRequest));
                    },
                    (error) => {
                        reject(error);
                    }
                );
            });
        }

        return Promise.reject(error);
    }
);

export default api;
