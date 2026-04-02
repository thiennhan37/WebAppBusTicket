import axios from "axios";

const appURL = "http://localhost:8080/vexedat";
const timeout = 5000;
export const publicApi = axios.create({
	baseURL: appURL, 
	timeout: timeout, 
	headers: {
		"Content-Type": "application/json"
	}
});
publicApi.interceptors.response.use(
	(config) => {
		// console.log(config)
		return config;
	}, 
	(error) =>{
		// console.log(error);
		return Promise.reject(error);
	}
)

const api = axios.create({
	baseURL: appURL,
	//   withCredentials: true,
	timeout: timeout,
	headers: {
		"Content-Type": "application/json"
	}
});

api.interceptors.request.use(
	(config) => {
		const accessToken = localStorage.getItem("accessToken");
		if(accessToken){
			config.headers.Authorization = `Bearer ${accessToken}`
		}
		return config;
	}, 
	(error) =>{
		console.log("loi request api", error);
		return Promise.reject(error);
	}
)



let isRefreshing = false;
let requestRunningList = [];
const pushRequestIntoQueue = (resolve, reject) => {
	requestRunningList.push({resolve, reject});
};
// Hàm để chạy lại các request trong hàng đợi sau khi đã có token mới
const onSuccess = (token) => {
	requestRunningList.forEach(({resolve}) => resolve(token));
	requestRunningList = [];
};
const onFailed = (error) =>{
	requestRunningList.forEach(({reject}) => reject(error));
	requestRunningList = [];
}

api.interceptors.response.use(
	(response) => response,
	async (error) => {
		const { config, response } = error; 
		const originalRequest = config;
		// console.log(response);
		if (response?.status === 401 && !originalRequest._retry) {
			originalRequest._retry = true;
			if (!isRefreshing) {
				isRefreshing = true;

				try {
				// 1. Gọi API lấy token mới (thường dùng Refresh Token lưu trong Cookie hoặc LocalStorage)
					const res = await publicApi.post("/auth/refresh-token", {refreshToken: localStorage.getItem("refreshToken")})
					// console.log(res);
					const { accessToken } = res.data.result;
					localStorage.setItem("accessToken", accessToken);

					isRefreshing = false;
					onSuccess(accessToken); // Thông báo cho các request đang đợi
					
					// 2. Thực hiện lại request bị lỗi ban đầu với token mới
					originalRequest.headers.Authorization = `Bearer ${accessToken}`;
					return api(originalRequest);
				} catch (refreshError) {
					// Nếu refresh token cũng hết hạn -> Logout luôn
					isRefreshing = false;
					let homeLink;
					const role = localStorage.getItem("user").role;
					if(role === "CUSTOMER") homeLink = "/customer";
					else if(role === "ADMIN") homeLink = "/admin";
					else homeLink = "/nhaxe";
					window.location.href = homeLink;
					localStorage.clear();
					console.log(error);
					onFailed(refreshError);
					return Promise.reject(refreshError);
				}
			}

			// Nếu đang trong quá trình refresh, cho các request sau "đứng đợi"
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
		// else if()

		return Promise.reject(error);
	}
);

export default api;