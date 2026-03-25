import SideBar from "../components/Sidebar/SideBar"
import CompanyHeader from "../components/CompanyHeader"
import { Outlet } from "react-router-dom"
const CompanyLayout = () => {
    return (
        <div className="flex h-screen overflow-hidden bg-white">
            <SideBar></SideBar>

            <div className="flex-1 flex flex-col min-w-0">
                <CompanyHeader />
                
                <main className="flex-1 p-0 bg-gray-50/30 overflow-y-auto scrollbar-hide">
                    <Outlet></Outlet>
                </main>
            </div>
        </div>
    )
}

export default CompanyLayout;