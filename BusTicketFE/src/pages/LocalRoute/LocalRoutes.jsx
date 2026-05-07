import { useQuery, keepPreviousData, useMutation, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { useSearchParams } from 'react-router-dom';
import RouteService from "../../Services/routeService";
import Pagination from "../../components/other/Pagination";
import { Search, Settings } from "lucide-react";
import RouteStops from "./RouteStops";
import RouteHeader from "./RouteHeader";
import CreateRoute from "./CreateRoute";
import StatusModal from "../../components/other/StatusModal";
import LoadingOverlay from "../../components/other/LoadingOverlay";
import UpdateRoute from "./UpdateRoute";

const LocalRoutes = () => {
  console.log("reload localRoutes")
  const [searchParams, setSearchParams] = useSearchParams();
  const [isOpenUpdate, setOpenUpdate] = useState(false);
  // Helper to read params with defaults
  const page = Number(searchParams.get('page') || 1);
  const arrivalName = searchParams.get('arrivalName') || '';
  const destinationName = searchParams.get('destinationName') || '';
  const keyword = searchParams.get('keyword') || '';
  const queryClient = useQueryClient();

  const buildFilterParams = () => ({
    page,
    arrival: arrivalName,
    destination: destinationName ,
    keyword,
  });

  const onChangeFilter = (field, value) => {

    const params = new URLSearchParams(searchParams.toString());
    if (field === 'arrival' && value && typeof value === 'object') {
      params.set('arrivalName', value.name || '');
      params.set('page', '1');
    } else if (field === 'destination' && value && typeof value === 'object') {
      params.set('destinationName', value.name || '');
      params.set('page', '1');
    } else if (field === 'page') {
      params.set('page', String(value || 1));
    } else {
      if (!value) params.delete(field);
      else params.set(field, String(value));
      params.set('page', '1');
    }

    setSearchParams(params);
  };

  const { data: result, isLoading, isError } = useQuery({
    queryKey: ['routes', searchParams.toString()], 
    queryFn: async () => {
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
  const handleOpenCreate = (isOpen) => {
    setCrRoute({name:"", arrival: {id:"", name:""}, destination: {id:"", name:""}, upStopList: [], downStopList: []});
    if (isOpen) setOpenUpdate(false);
    setOpenCreate(isOpen);
  }
  const onChangeCrRoute = (field, value) => {
    setCrRoute((prev) => {
      let updated = { ...prev };
      updated[field] = value;
      if (field === 'arrival' && value.name != prev.arrival.name) updated.upStopList = [];
      if (field === 'destination' && value.name != prev.destination.name) updated.downStopList = [];
      return updated;
  })}; 

  const [report, setReport] = useState("") 
  const hideReport = () => {
    setReport("");
  }
  const { mutate:mutateCreate, error : errorCreate} = useMutation({
    mutationFn: ({newRoute}) => RouteService.createRoute({newRoute}),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['routes', searchParams.toString()] });
      setReport("success:" +  "Tạo tuyến đường thành công");
    }, 
    onMutate: () => {
      setReport("pending");
    }, 
    onError: (error) => {
      console.log("Error creating route: ", error);
      setReport("error:" + error.response.data.message || "Có lỗi xảy ra");
    }
  });
  const handleCreateRoute = () => mutateCreate({newRoute: crRoute});

  
  const [selectedRoute, setSelectedRoute] = useState(null);
  const [upStopList, setUpStopList] = useState([]);
  const [downStopList, setDownStopList] = useState([]);
  const handleViewUpdate = (route, isOpen) => {
    setUpStopList([]);
    setDownStopList([]);
    setSelectedRoute(route);
    if (isOpen) setOpenCreate(false);
    setOpenUpdate(isOpen);
  }
  const { mutate: mutateUpdate, error } = useMutation({
    mutationFn: async (updatedRoute) => {
      console.log("MutationFn nhận được:", updatedRoute); 
      
      if (!updatedRoute || !updatedRoute.id) {
        throw new Error("Dữ liệu cập nhật không hợp lệ (thiếu ID)");
      }
      if(!updatedRoute.durationMinutes || updatedRoute.durationMinutes < 1){
        throw new Error("Thời gian di chuyển không hợp lệ");
      }
      
      return RouteService.updateRoute(updatedRoute, upStopList, downStopList);
    },
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: ['routeStops'] });
      queryClient.invalidateQueries({ queryKey: ['routes', searchParams.toString()] });
      setReport("success:" + "Cập nhật tuyến đường thành công");
    },
    onMutate: () => {
      setReport("pending");
    },
    onError: (error) => {
      
      setReport("error:" + error.response?.data.message || "Có lỗi xảy ra");
    }
  })
  const handleUpdateRoute = () => mutateUpdate(selectedRoute);


  if (isLoading) return <div>Đang tải...</div>;
  if (isError) return <div>Đã xảy ra lỗi khi lấy dữ liệu!</div>;
   

  return(
    
    <div className="w-full max-h-screen overflow-visible bg-slate-50 p-1 lg:p-4">
      
      <div className="flex flex-col xl:flex-row"> 

        <div className="flex-1 flex flex-col bg-white max-w-[850px] h-[580px]
          rounded-2xl shadow-sm border border-slate-200">
          <RouteHeader onChangeFilter={onChangeFilter} filterParams={buildFilterParams()} setOpenCreate={handleOpenCreate}></RouteHeader>
          
          <div className="flex-1 overflow-visible">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50/80 text-slate-500 text-[11px] uppercase tracking-widest font-bold">
                  <th className="px-4 py-3">Tuyến Đường</th>
                  <th className="px-2 py-3">Điểm bắt đầu</th>
                  <th className="px-2 py-3">Điểm kết thúc</th>
                  <th className="px-2 py-3">Thời gian di chuyển</th>
                  <th className="pl-2 pr-12 py-3 text-right">Thao tác</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {routePage.map((route) => (
                    <tr key={route.id} className="hover:bg-slate-50/50 transition-colors" >
                      <td className="px-4 py-3 font-bold text-slate-700">{route.name}</td>
                      <td className="px-2 py-3 font-medium text-slate-800">{route.arrivalProvince.name}</td>
                      <td className="px-2 py-3 font-medium text-slate-800">{route.destinationProvince.name}</td>
                      <td className="px-2 py-3 font-medium text-slate-800 text-center">
                        {Math.floor(route.durationMinutes / 60)} giờ {route.durationMinutes % 60} phút</td>
                      <td className="pl-2 pr-12 py-3 flex gap-1 justify-end">
                        <div className="flex justify-center hover:bg-green-100 hover:rounded-xl p-2">
                          <button 
                            onClick={() => {
                              handleViewUpdate(route, true)
                            }}
                            title="Cài đặt tuyến đường"
                          >
                            <Settings className="w-5 h-5 text-green-600" />
                          </button> 
                        </div>
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

            {/* Modal Container */}
            <div className={`flex-1 ${isOpenCreate || isOpenUpdate ? "" : "hidden"} relative w-full max-w-2xl pr-4 ml-4 h-fit animate-in fade-in slide-in-from-right-4 duration-300`}>
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 animate-in fade-in duration-300">
                  <div className="relative w-full max-w-2xl max-h-[95vh] overflow-y-auto scrollbar-hide">
                    {/* Các thông báo trạng thái */}
                    {report.startsWith("error") && (
                      <StatusModal type="error" message={report.split(":")[1]} 
                        onClose={hideReport} 
                      />
                    )}
                    {report === "pending" && <LoadingOverlay />}
                    {report.startsWith("success") && (
                      <StatusModal type="success" message={report.split(":")[1]} 
                        onClose={() => {
                          hideReport();
                          handleOpenCreate(false);
                          handleViewUpdate(null, false);
                        }} 
                      />
                    )}
                    {/* Component chính */}
                    {isOpenCreate ? <CreateRoute onChangeCrRoute={onChangeCrRoute} crRoute={crRoute} setOpen={handleOpenCreate}
                      handleCreateRoute={handleCreateRoute}/> : null}
                    {isOpenUpdate ? <UpdateRoute selectedRoute={selectedRoute} setSelectedRoute={setSelectedRoute}
                      handleViewUpdate={handleViewUpdate} handleUpdateRoute={handleUpdateRoute}
                      upStopList={upStopList} setUpStopList={setUpStopList}
                      downStopList={downStopList} setDownStopList={setDownStopList}/> : null}
                  </div>
                </div>
              
            </div>

        </div>
    </div>
  );
}
export default LocalRoutes;
