import { useQuery, keepPreviousData } from "@tanstack/react-query";
import { useState } from "react";
import RouteService from "../../Services/routeService";
import Pagination from "../StaffManagement/Pagination";
import { Search } from "lucide-react";
import RouteStops from "./RouteStops";
const LocalRoutes = () => {
  const [filterParams, setFilterParams] = useState({ page: 1, arrival: "", destination: "", keyword: "" });

  const { data: result, isLoading, isError } = useQuery({
    queryKey: ['staffs', filterParams],
    queryFn: async () => {
        // console.log("Đang gọi API với params:", filterParams);
        const response = await RouteService.getRoutes(filterParams);
        // console.log(response);
        return response.data.result;
    },
    placeholderData: keepPreviousData,
    staleTime: 5000,
  });


  const routePage = result?.content || []; 
  const totalPages = result?.page?.totalPages || 1;
  console.log(routePage); 

  const onPageChange = (newPage) => {
    setFilterParams((prev) => ({ ...prev, page: newPage }));
  };

  if (isLoading) return <div>Đang tải...</div>;
  if (isError) return <div>Đã xảy ra lỗi khi lấy dữ liệu!</div>;
  const handleViewRoute = async (route) => {
    
  }

  return(
    
    <div className="w-full max-h-screen overflow-auto bg-slate-50 p-4 lg:p-4">
      
      <div className="flex flex-col xl:flex-row gap-6"> 

        <div className="flex-1 flex flex-col min-h-[580px] max-w-[580px] bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          {/* <StaffListHeader setRightPanelMode={setRightPanelMode} 
            filterParams={filterParams} setFilterParams={setFilterParams}></StaffListHeader> */}
          
          <div className="flex-1 overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50/80 text-slate-500 text-[11px] uppercase tracking-widest font-bold">
                  <th className="px-4 py-2">Tuyến Đường</th>
                  <th className="px-4 py-2">Điểm bắt đầu</th>
                  <th className="px-4 py-2">Điểm kết thúc</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {routePage.map((route) => (
                    <tr key={route.id} className="hover:bg-slate-50/50 transition-colors" >
                      <td className="px-4 py-2 font-bold text-slate-700">{route.name}</td>
                      <td className="px-4 py-2 font-medium text-slate-800">{route.arrivalProvince.name}</td>
                      <td className="px-4 py-2 font-medium text-slate-800">{route.destinationProvince.name}</td>
                      <td className="px-4 py-2 text-center">
                        {/* <StatusBadge type={staff.status} /> */}
                      </td>
                      <td className="px-4 py-2">
                        <div className="flex justify-center gap-1">
                          <RouteStops routeId={route.id}></RouteStops>
                          {/* <button className="py-2 px-1 text-orange-600 hover:bg-orange-50 rounded-lg transition-colors"
                            onClick={() => handleViewRoute(route)} ><Search size={21}/></button> */}
                          {/* <button className="py-2 px-1 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors 
                              disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-transparent" 
                            disabled={staff.status === "ACTIVE" || staff.role == "MANAGER"}> <ShieldCheck size={21}/> </button> */}
                        </div>
                      </td>
                    </tr>
                ))}
              </tbody>
            </table>
          </div>
            
          <Pagination page={filterParams.page} totalPages={totalPages} onPageChange={onPageChange}/>
        </div>

            {/* Component Tạo mới: Luôn trong DOM, ẩn bằng CSS */}
            {/* <div className={`${rightPanelMode === 'create' ? "block" : "hidden"} relative overflow-hidden`}>
              {reportCreate == "error" && <StatusModal type="error" message={errorCreate.response.data.message} 
                onClose={hideReportCreate}></StatusModal>}
              {reportCreate == "pending" && <LoadingOverlay onClose={hideReportCreate}></LoadingOverlay>}
              {reportCreate == "success" && <StatusModal type="success" message={"Đăng kí nhân viên thành công"} 
                onClose={hideReportCreate}></StatusModal>}
              
              <StaffCreate 
                newStaff={newStaff} 
                setNewStaff={setNewStaff}
                setRightPanelMode={setRightPanelMode}
                rightPanelMode = {rightPanelMode}
                handleCreateStaff = {handleCreateStaff}
                
              />
            </div> */}

            {/* Placeholder (Tùy chọn): Hiển thị khi không có mode nào để vùng 400px không bị trống trải */}
            {/* {rightPanelMode === 'none' && (
              <div className="h-[490px] border-2 border-dashed border-slate-200 rounded-2xl flex items-center justify-center text-slate-400">
                ... 
              </div>
            )} */}
        </div>
    </div>
  );
}
export default LocalRoutes;
