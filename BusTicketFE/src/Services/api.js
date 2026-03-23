import axios from "axios";

let token = 
"eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ2ZXhlZGF0LmNvbSIsInN1YiI6InN0YWZmXzAwMkBnbWFpbC5jb20iLCJyb2xlIjoiU1RBRkYiLCJleHAiOjE3NzQwODYyNjcsImlhdCI6MTc3NDA4MzI2NywianRpIjoiNmViMWEyNzctM2JlYS00YTY4LWE2MmItYzkwYWY1ZDRlODUzIn0.uxINQkRuOY-_zEW-_V9ywlN2Tk0Z7P8kJNKiYu9BaNg"
const api = axios.create({
//   baseURL: "https://fakestoreapi.com",
  baseURL: "http://localhost:8080/vexedat",
//   withCredentials: true,
  timeout: 5000,
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
    // Authorization: `Bearer ${localStorage.getItem('token')}`;
  }
});

export default api;