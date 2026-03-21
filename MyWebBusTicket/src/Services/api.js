import axios from "axios";

let token = 
"eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJUaGllbk5oYW4uY29tIiwic3ViIjoiYWRtaW4iLCJleHAiOjE3NzM0MTk3NDEsImlhdCI6MTc3MzQxNjc0MSwianRpIjoiNGE5YTYyYTEtMjlkNC00MDJjLWFmMWQtZDZmYzgzZTAyMjY4Iiwic2NvcGUiOiJST0xFX0FETUlOIENSRUFURV9EQVRBIFJFSkVDVF9QT1NUIEFQUFJPVkVfUE9TVCBST0xFX1VTRVIgQ1JFQVRFX0RBVEEgVVBEQVRFX0RBVEEifQ.p_AtcuFNBK_-wEZ-IqL1DROgQA6HBdVDKg3JqtGBPaM"
const api = axios.create({
//   baseURL: "https://fakestoreapi.com",
  baseURL: "http://localhost:8080/identity",
//   withCredentials: true,
  timeout: 5000,
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
    // Authorization: `Bearer ${localStorage.getItem('token')}`;
  }
});

export default api;