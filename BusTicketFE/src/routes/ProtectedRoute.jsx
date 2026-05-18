import { useContext } from "react";
import AuthContext from "../context/AuthContext";
import { Navigate, Outlet } from "react-router-dom";

const ProtectedRoute = (props) => {
  const { user } = useContext(AuthContext);
  const {type} = props;
  // Nếu chưa đăng nhập, đá về trang login
  // Bình thường, khi bạn điều hướng (chuyển trang), trình duyệt sẽ lưu trang đó vào History Stack (lịch sử duyệt web).
  // nếu ko replace, khi user bấm back về trang cũ, lại bị đá ra trang login gây khó chịu
  // replace sẽ thay thế trang cũ -> login, không gây vòng lặp khó chịu

  console.log(user, type);
  let homeLink;
  if(type === "customer") homeLink = "/customer/home";
	else if(type === "admin") homeLink = "/admin";
	else homeLink = "/nhaxe";
  if(!user){
    return <Navigate to={homeLink} replace></Navigate>
  }

  // Nếu đã đăng nhập, cho phép hiển thị các component con (Outlet)
  return <Outlet></Outlet>
};

export default ProtectedRoute;