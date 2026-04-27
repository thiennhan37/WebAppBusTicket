import React from 'react';

const HistorySidebar = ({ logs }) => {
  return (
    <>
      <div className="flex justify-between items-center mb-4 border-b border-gray-100 pb-3">
        <h2 className="text-lg font-semibold text-gray-800">Lịch sử đặt vé</h2>
        <span className="bg-blue-100 text-blue-700 py-1 px-2 rounded-md text-xs font-bold">{logs.length}</span>
      </div>
      
      <div className="flex-1 overflow-y-auto pr-2 space-y-4">
        {logs.map((log) => (
          <div key={log.id} className="flex gap-3 text-sm">
            <div className="flex flex-col items-center">
              <div className={`w-2 h-2 rounded-full mt-1.5 ${log.type === 'book' ? 'bg-teal-500' : 'bg-red-500'}`}></div>
              <div className="w-px h-full bg-gray-200 mt-1"></div>
            </div>
            <div className="pb-4">
              <p className="text-gray-700">
                <span className="font-semibold text-gray-900">{log.user}</span> đã <span className="font-medium">{log.action}</span> ghế <span className="font-semibold text-blue-600">{log.seat}</span> cho <span className="font-semibold text-gray-900">{log.customer}</span>
              </p>
              <p className="text-xs text-gray-400 mt-1">{log.time}</p>
            </div>
          </div>
        ))}
      </div>
    </>
  );
}

export default HistorySidebar;