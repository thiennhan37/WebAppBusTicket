import React, { useState } from 'react';
import { FileInput, Clock, Bus, Tag, CircleX, User, CircleCheckBig } from 'lucide-react';
import TripHeader from './TripHeader';
import TripCreate from './TripCreate';
import Pagination from '../../components/other/Pagination';
import { keepPreviousData, useQuery, useQueryClient, useMutation } from '@tanstack/react-query';
import { useSearchParams } from 'react-router-dom';
import TripService from '../../Services/TripService';
import { toVN } from '../../utils/translate';
import TripUpdate from './TripUpdate';
import ConfirmModal from '../../components/other/ConfirmModal';
import StatusModal from '../../components/other/StatusModal';
const Trips = () =>{
  const queryClient = useQueryClient();
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [searchParams, setSearchParams] = useSearchParams();
  // code useSearchParams with page, date, status, keyword, sinh ra code
  const page = Number(searchParams.get('page')) || 1;
  const status = searchParams.get('status') || 'Tất Cả';
  // const date = searchParams.get('date') || null;
  const keyword = searchParams.get('keyword') || '';
  const busType = searchParams.get('busType') || 'Tất Cả';

  const [date, setDate] = useState(searchParams.get("date") || "");

    
  const params = {page, keyword, date, status, busType};
  const updateFilter = ({field, value}) => {
    const currentParams = new URLSearchParams(searchParams);
    if(value) currentParams.set(field, value);
    else currentParams.delete(field);
    
    if(field != 'page') currentParams.set('page', 1);
    setSearchParams(currentParams);
  };
  
  const {data} = useQuery({
    queryKey: ['tripList', page, status, date, keyword, busType],
    queryFn: async () => {
      const response = await TripService.getTripList({filterParams: params});
      return response.data.result;
    },
    placeholderData:keepPreviousData, 
    staleTime: 5000
  });

  const totalPage = data?.page?.totalPages || 1;
  const onPageChange = (newPage) => {
    updateFilter({field: "page", value: newPage});
  };
  const tripPage = data?.content || [];
  
  const [selectedTrip, setSelectedTrip] = useState({id: "", licensePlate: "", driver: "", status: "", 
    departureTime: "", price: null, route: null, busType: null
  })
  const [isUpdateOpen, setIsUpdateOpen] = useState(false);
  const handleUpdateTrip = (trip) => {
    // const {busType: busTypeName, ...rest} = trip;
    // setSelectedTrip({...rest, busType: {id:"", name:busTypeName, diagram:""}});
    setSelectedTrip({...trip});
    setIsUpdateOpen(true);
  }

  const [reportUpdate, setReportUpdate] = useState("") 
  const [showConfirmOpen, setShowConfirmOpen] = useState(false);
  const hideReportUpdate = () => {
    setReportUpdate("");
  }
 
  const { mutate:mutateOpen } = useMutation({
    mutationFn: (tripId) =>{
        return TripService.openTrip(tripId);
    }, 
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tripList'] });
        setReportUpdate('success')
      },
    onError: (error) => {
      // console.log(error.response);
      setReportUpdate("error:" + error.response.data.message);
    }
  });
  const handleOpenTrip = (trip) => {
    const {busType: busTypeName, ...rest} = trip;
    setSelectedTrip({...rest, busType: {id:"", name:busTypeName, diagram:""}});
    setShowConfirmOpen(true);
  }



  const formatter = new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  });
  const getStatusBadge = (status) => {
    switch (status) {
      case 'OPEN': return 'bg-green-100 text-green-700 border-green-200';
      case 'SCHEDULED': return 'bg-blue-100 text-blue-700 border-blue-200';
      case 'CLOSED': return 'bg-gray-100 text-gray-600 border-gray-200';
      default: return 'bg-amber-100 text-amber-600 border-amber-200';
    }
  };
  return (
    <div className="min-h-screen bg-slate-50 px-6 pb-6 pt-2 font-sans text-slate-800">
      <ConfirmModal 
          view={"absolute"}
          isOpen={showConfirmOpen}
          onClose={() => setShowConfirmOpen(false)}
          onConfirm={() => mutateOpen(selectedTrip.id)}
          title={`Mở chuyến đi ${selectedTrip.id}`}
          message={`Bạn có chắc chắn muốn mở chuyến đi này?`}
        />
      {reportUpdate.startsWith("error") && <StatusModal type="error"  message={reportUpdate.split(":")[1]}
          onClose={hideReportUpdate}></StatusModal>}
      {reportUpdate === "success" && <StatusModal type="success" message={"Lưu chuyến đi thành công"} 
        onClose={hideReportUpdate}></StatusModal>}

      <TripHeader
        setIsAddModalOpen={setIsAddModalOpen}
        searchParams={searchParams} 
        updateFilter={updateFilter}
        dateValue={date}
        setDateValue={setDate}
      />
      {/* content */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden flex flex-col min-h-[467px]">
        <div className="flex-grow">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-100 text-xs uppercase tracking-wider text-slate-500">
                <th className="px-6 py-3 font-semibold">Chuyến đi</th>
                <th className="px-6 py-3 font-semibold">Phương tiện & Giá</th>
                <th className="px-6 py-3 font-semibold">Thời gian</th>
                <th className="px-6 py-3 font-semibold">Tài xế</th>
                <th className="px-6 py-3 font-semibold">Trạng thái</th>
                <th className="pr-2 py-3 font-semibold text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {tripPage.map((trip) => (
                <tr key={trip.id} className="hover:bg-slate-50/50 transition-colors group">
                  <td className="px-6 py-2">
                    <div className="flex items-start gap-3">
                      <div className="mt-1 bg-emerald-100 p-2 rounded-lg text-emerald-600">
                        <Bus size={18} />
                      </div>
                      <div>
                        <div className="font-semibold text-slate-900">{trip.id}</div>
                        <div className="text-sm text-slate-500 mt-0.5">
                          {`Tuyến đường: ${trip.route.name}`}</div>
                        <div className="text-sm text-slate-500 mt-0.5">
                        {`${trip.route.arrivalProvince.name} - ${trip.route.destinationProvince.name}`}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-2">
                    <div className="flex items-center gap-2 text-slate-700">
                      <Bus size={16} className="text-slate-400" />
                      <span className="text-sm">{trip.busType.name}</span>
                    </div>
                    <div className="flex items-center gap-2 text-emerald-600 font-semibold mt-1">
                      <Tag size={16} />
                      <span>{trip?.price ? formatter.format(trip.price): "Chưa có"}</span>
                    </div>
                  </td>
                  <td className="px-6 py-2">
                    <div className="flex items-center gap-2 text-slate-700">
                      <Clock size={16} className="text-slate-400" />
                      <span className="text-sm font-medium">{trip.departureTime.split('T')[0]}</span>
                    </div>
                    <div className="text-sm text-slate-500 mt-1 pl-6">{trip.departureTime.split('T')[1]}</div>
                  </td>
                  <td className="px-6 py-2">
                    {/* Thông tin Biển số xe */}
                    <div className="flex items-center gap-2 text-slate-700">
                      <div className="bg-slate-100 p-1 rounded text-slate-500">
                        <Bus size={14} /> 
                      </div>
                      <span className="text-[13px] font-bold text-slate-800">
                        {trip?.licensePlate || "Chưa phân công"}
                      </span>
                    </div>

                    {/* Thông tin Tài xế */}
                    <div className="flex items-center gap-2 mt-2 text-slate-600">
                      <div className="h-4 w-6 rounded-full bg-indigo-50 flex items-center justify-center text-indigo-600">
                        <User size={14} />
                      </div>
                        <span className="text-[13px] font-medium">{trip?.driver || "Chưa phân công"}</span>
                    </div>
                  </td>
                  <td className="px-6 py-3">
                    <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium border ${getStatusBadge(trip.status)}`}>
                      {toVN(trip.status)}
                    </span>
                  </td>
                  <td className="py-3 text-right">
                    {trip.status === "SCHEDULED" ? 
                        <div className='flex gap-1'>
                          <button className="text-slate-400 hover:text-slate-600 hover:bg-slate-100 
                            rounded-lg transition-colors"
                            title="Cập nhật chuyến đi"
                          >
                            <FileInput size={22} onClick={() => handleUpdateTrip(trip)}/>
                          </button>
                          <button className="text-green-400 hover:text-green-600 hover:bg-green-200 rounded-lg transition-colors"
                            title="Mở bán chuyến đi"
                          >
                            <CircleCheckBig size={22} onClick={() => handleOpenTrip(trip)}/>
                          </button>
                        </div>
                        : <></>
                      }
                    {trip.status === "OPEN" ? 
                        <div className='flex gap-1'>
                          <button className="text-slate-400 hover:text-slate-600 hover:bg-slate-100 
                            rounded-lg transition-colors"
                            title="Cập nhật chuyến đi"
                          >
                            <FileInput size={22} onClick={() => handleUpdateTrip(trip)}/>
                          </button>
                          <button className="text-red-400 hover:text-red-600 hover:bg-red-200 
                            rounded-lg transition-colors"
                            title="Hủy chuyến đi"
                          >
                            <CircleX size={22} />
                          </button>
                        </div>
                        : <></>
                      }
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="border-t border-slate-100 px-4 pb-4">
          <Pagination page={page} onPageChange={onPageChange} totalPages={totalPage} />
        </div>
      </div>

      {/* Add Trip Modal (Slide-up or Center Pop) */}
      {isAddModalOpen && (
        <TripCreate setIsAddModalOpen={setIsAddModalOpen}/>
      )}
      {isUpdateOpen && (
        <TripUpdate selectedTrip={selectedTrip} setSelectedTrip={setSelectedTrip} setIsUpdateOpen={setIsUpdateOpen} />
      )}
    </div>
  );
}

export default Trips;