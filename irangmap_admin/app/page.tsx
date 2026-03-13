import Link from "next/link";

export default function Home() {
  const mockPlaces = [
    { id: "1", name: "대전 국립중앙과학관", status: "active", reporter: "admin" },
    { id: "2", name: "세종 호수공원", status: "pending", reporter: "user_a123" },
    { id: "3", name: "천안 독립기념관", status: "pending", reporter: "user_b456" },
  ];

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <header className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">IrangMap Admin Dashboard</h1>
        <p className="text-gray-500">장소 제보 심사 및 컨텐츠 관리 패널</p>
      </header>

      <main>
        <div className="bg-white rounded-lg shadow overlow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">장소명</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">제보자</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">상태</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">액션</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {mockPlaces.map((place) => (
                <tr key={place.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{place.name}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{place.reporter}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      place.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                    }`}>
                      {place.status === 'active' ? '승인됨 (Active)' : '심사중 (Pending)'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button className="text-indigo-600 hover:text-indigo-900 mr-4">편집</button>
                    {place.status === 'pending' && (
                      <button className="text-green-600 hover:text-green-900">승인</button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </main>
    </div>
  );
}
