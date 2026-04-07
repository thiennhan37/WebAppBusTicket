// import React, { useState, useEffect } from 'react';
// import { Plus, Trash2, Search, Navigation, CheckCircle2, Circle, X } from 'lucide-react';
// import SearchProvinces from './SearchProvinces';
// import RouteService from '../../Services/routeService';
// import InputGroup from '../../components/other/InputGroup';

// const CreateRoute = ({crRoute, onChangeCrRoute, setOpen}) => {
//   // 
//   const [routeName, setRouteName] = useState('');


//   const [upKeyword, setUpKeyword] = useState("");
//   const [upList, setUpList] = useState([]);
//   const [downKeyword, setDownKeyword] = useState("");
//   const [downList, setDownList] = useState([]);
//   useEffect(() => {
//     const loadUpStops = async() => {
//         try{
//             if(crRoute?.arrival){
//                 const params = {province: crRoute.arrival.name, keyword: upKeyword};
//                 console.log("load up stops with params: ", params);
//                 const result = (await RouteService.getStops({filterParams: params}))?.data?.result || [];
//                 setUpList(result);
//             }
//         }catch(error){
//           console.log("Error loading up stops: ");
//             console.log(error);
//         }
//     }
//     loadUpStops(); 
//   }, [crRoute?.arrival, upKeyword]);
//   useEffect(() => {
//     const loadDownStops = async() => {
//         try{
//             if(crRoute?.destination){
//                 const params = {province: crRoute.destination.name,  keyword: downKeyword};
//                 const result = (await RouteService.getStops({filterParams: params}))?.data?.result || [];
//                 setDownList(result);
//             }
//         }catch(error){
//             console.log(error);
//         }
//     }
//     loadDownStops();
//   }, [crRoute?.destination, downKeyword]);
//     const togglePoint = (point, list, field) => {
//         if (list.includes(point)) {
//             onChangeCrRoute(field, list.filter(p => p !== point));
//         } else {
//             onChangeCrRoute(field, [...list, point]);
//         }   
//     };
//   return (
//     <div className="bg-white p-4 rounded-xl shadow-2xl border border-gray-100 w-full max-w-2xl ml-4 h-fit animate-in fade-in slide-in-from-right-4 duration-300">
//       <div className="flex items-center justify-between gap-2 mb-6 border-b pb-4">
//         <div className="flex items-center gap-2">
//           <div className="p-2 bg-emerald-100 text-emerald-600 rounded-lg">
//             <Navigation size={20} />
//           </div>
//           <h2 className="text-xl font-bold text-gray-800">Cấu hình tuyến đường</h2>
//         </div>
//         <button className="p-2 bg-emerald-100 text-emerald-600 rounded-lg" onClick={() => setOpen(false)}>
//           <X size={20} />
//         </button>
//       </div>

//       <div className="flex gap-x-2"> 
//         {/* PHẦN 1: TỈNH BẮT ĐẦU & ĐIỂM ĐÓN */}
//         <section className="flex-1 space-y-3">
//           <div>
//             {/* {console.log("render search province with arrival: ", crRoute?.arrival)} */}
//             <SearchProvinces onChange={onChangeCrRoute} field={"arrival"} label={"Điểm xuất phát"} placeholder={"Tỉnh/Thành phố"}/>
//           </div>

//           {/* Chỉ hiển thị khi đã chọn tỉnh bắt đầu */}
//             <div className="pl-4 border-l-2 border-emerald-200 py-2 space-y-2 animate-in zoom-in-95 duration-200">
//               <p className="text-xs font-semibold text-emerald-600 uppercase tracking-wider">Danh sách điểm đón tại {crRoute?.arrival?.name}:</p>
//               <div className="grid grid-cols-1 gap-2">
//                 {upList?.map(point => (
//                   <button
//                     key={point.id} 
//                     onClick={() => togglePoint(point, crRoute.upStopList, "upStopList")}
//                     className={`flex items-center justify-between px-3 py-2 rounded-md text-sm transition-all ${
//                       crRoute.upStopList.includes(point) 
//                       ? 'bg-emerald-50 border-emerald-200 text-emerald-700 font-medium border' 
//                       : 'bg-white border-gray-200 text-gray-600 border hover:border-emerald-300'
//                     }`}
//                   >
//                     {point.name}
//                     {crRoute.upStopList.includes(point) ? <CheckCircle2 size={16} /> : <Circle size={16} className="text-gray-300" />}
//                   </button>
//                 ))}
//               </div>
//             </div>
//         </section>

//         {/* PHẦN 2: TỈNH ĐẾN & ĐIỂM TRẢ */}
//         <section className="flex-1 space-y-3">
//           <div>
//             <SearchProvinces onChange={onChangeCrRoute} field={"destination"} label={"Điểm đến"} placeholder={"Tỉnh/Thành phố"}/>
//           </div>
//           {/* Chỉ hiển thị khi đã chọn tỉnh bắt đầu */}
//           <div className="pl-4 border-l-2 border-emerald-200 py-2 space-y-2 animate-in zoom-in-95 duration-200">
//             <p className="text-xs font-semibold text-emerald-600 uppercase tracking-wider">Danh sách điểm trả tại {crRoute?.destination?.name}:</p>
//             <div className="grid grid-cols-1 gap-2">
              
//               {downList?.map(point => (
//                 <button
//                   key={point.id}
//                   onClick={() => togglePoint(point, crRoute.downStopList, "downStopList")} 
//                   className={`flex items-center justify-between px-3 py-2 rounded-md text-sm transition-all ${
//                     crRoute.downStopList.includes(point) 
//                     ? 'bg-emerald-100 border-emerald-200 text-emerald-700 font-medium border' 
//                     : 'bg-white border-gray-200 text-gray-600 border hover:border-emerald-300'
//                   }`}
//                 >
//                   {point.name}
//                   {crRoute.downStopList.includes(point) ? <CheckCircle2 size={16} /> : <Circle size={16} className="text-gray-300" />}
//                 </button>
//               ))}
//             </div>
//           </div>
//         </section>


//         </div>
//       <div className="pt-4 flex flex-col gap-3">
//         <button 
//           disabled={!crRoute?.arrival || !crRoute?.destination || crRoute?.upStopList.length === 0 || crRoute?.downStopList.length === 0 || !routeName.trim()}
//           className="w-full py-3 bg-emerald-600 text-white rounded-xl font-bold hover:bg-emerald-700 disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed transition-all shadow-lg shadow-emerald-100"
//         >
//           Xác nhận tạo tuyến đường
//         </button>
//         <p className="text-[10px] text-center text-gray-400 italic">
//           * Vui lòng chọn ít nhất 1 điểm đón và 1 điểm trả để hoàn tất
//         </p>
//       </div>
//     </div>
//   );
// };

// export default CreateRoute;