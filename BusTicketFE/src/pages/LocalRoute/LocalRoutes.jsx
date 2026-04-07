import { useQuery, keepPreviousData } from "@tanstack/react-query";
import { useState } from "react";
import { useSearchParams } from 'react-router-dom';
import RouteService from "../../Services/routeService";
import Pagination from "../StaffManagement/Pagination";
import { Search } from "lucide-react";
import RouteStops from "./RouteStops";
import RouteHeader from "./RouteHeader";
// import CreateRoute from "./CreateRoute";
const LocalRoutes = () => {
  // Use URL search params instead of local state for filter params
  const [searchParams, setSearchParams] = useSearchParams();

  // Helper to read params with defaults
  const page = Number(searchParams.get('page') || 1);
  // const arrivalId = searchParams.get('arrivalId') || '';
  const arrivalName = searchParams.get('arrivalName') || '';
  // const destinationId = searchParams.get('destinationId') || '';
  const destinationName = searchParams.get('destinationName') || '';
  const keyword = searchParams.get('keyword') || '';

  const buildFilterParams = () => ({
    page,
    arrival: arrivalName,
    destination: destinationName ,
    keyword,
  });

  const onChangeFilter = (field, value) => {
    // Update URL params depending on field type
    console.log(`Changing filter ${field} to value: `, value);
    const params = new URLSearchParams(searchParams.toString());

    if (field === 'arrival' && value && typeof value === 'object') {
      // params.set('arrivalId', value.id || '');
      params.set('arrivalName', value.name || '');
      // reset page to 1 when changing filter
      params.set('page', '1');
    } else if (field === 'destination' && value && typeof value === 'object') {
      // params.set('destinationId', value.id || '');
      params.set('destinationName', value.name || '');
      params.set('page', '1');
    } else if (field === 'page') {
      params.set('page', String(value || 1));
    } else {
      // generic fields like 'keyword'
      if (!value) params.delete(field);
      else params.set(field, String(value));
      params.set('page', '1');
    }

    setSearchParams(params);
  };

  const { data: result, isLoading, isError } = useQuery({
    queryKey: ['routes', searchParams.toString()], // include search params in query key for caching
    queryFn: async () => {
      // console.log("Fetching routes with params: ", buildFilterParams());
        const response = await RouteService.getRoutes({filterParams: buildFilterParams()});
        return response.data.result;
    },
    placeholderData: keepPreviousData,
    staleTime: 0,
  });


  const routePage = result?.content || []; 
  const totalPages = result?.page?.totalPages || 1;


  const onPageChange = (newPage) => {
    onChangeFilter('page', newPage);
  };
  const [isOpenCreate, setOpenCreate] = useState(false);
  const [crRoute, setCrRoute] = useState({name:"", arrival: {id:"", name:""}, destination: {id:"", name:""}, upStopList: [], downStopList: []})
  const onChangeCrRoute = (field, value) => {
    setCrRoute((prev) => ({
      ...prev, 
      [field]:value
    }));
  }
  if (isLoading) return <div>Đang tải...</div>;
  if (isError) return <div>Đã xảy ra lỗi khi lấy dữ liệu!</div>;
  

  return(
    
    <div className="w-full max-h-screen overflow-visible bg-slate-50 p-1 lg:p-4">
      
      <div className="flex flex-col xl:flex-row"> 

        <div className="flex-1 flex flex-col min-h-[580px] max-w-[580px] bg-white rounded-2xl shadow-sm border border-slate-200">
          <RouteHeader onChangeFilter={onChangeFilter} filterParams={buildFilterParams()} setOpenCreate={setOpenCreate}></RouteHeader>
          
          <div className="flex-1 overflow-visible">
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
                        </div>
                      </td>
                    </tr>
                ))}
              </tbody>
            </table>
          </div>
            
          <Pagination page={page} totalPages={totalPages} onPageChange={onPageChange}/>
        </div>

            {/* Component Tạo mới: Luôn trong DOM, ẩn bằng CSS */}
            {/* <div className={`flex-1 ${isOpenCreate ? "" : "hidden"} relative w-full max-w-2xl pr-4 ml-4 h-fit animate-in fade-in slide-in-from-right-4 duration-300`}>
              {isOpenCreate && (
                <CreateRoute onChangeCrRoute={onChangeCrRoute} crRoute={crRoute} setOpen={setOpenCreate}></CreateRoute>
              )}
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
