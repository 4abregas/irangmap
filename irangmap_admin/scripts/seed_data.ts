import * as admin from 'firebase-admin';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as https from 'https';

import * as fs from 'fs';

// 환경 변수 연동
dotenv.config({ path: path.resolve(__dirname, '../.env.local') });

// 서비스 계정 키 불러오기 (이미지에서 확인한 파일명)
const serviceAccountPath = path.resolve(__dirname, '../perfect-drop-fe436-firebase-adminsdk-fbsvc-0548f57256.json');

try {
  if (!admin.apps.length) {
    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log("🔥 Firebase Admin Initialized Successfully");
  }
} catch (error) {
  console.error("Firebase Admin Initialization Error. Check service account key file.", error);
  process.exit(1);
}

const db = admin.firestore();

// 공공데이터 API 키 및 엔드포인트 세팅 (https 인증 오류 무시용 에이전트 포함)
const API_KEY = "4b71b526c2e5c0a5c2d9604aec148136eadeb441b573e722d59ca03a57275592";
const BASE_URL_PFC = "https://apis.data.go.kr/1741000/pfc3";  // 어린이놀이시설
const BASE_URL_EXFC = "https://apis.data.go.kr/1741000/exfc5";

const httpsAgent = new https.Agent({ rejectUnauthorized: false });

// Mock Data (API 실패 시 대비용)
const mockPlaces = [
  {
    name: '(Mock) 아이랑 실내놀이터 대전점',
    type: 'kidscafe',
    location: new admin.firestore.GeoPoint(36.3510, 127.3850),
    address: { region: '대전', city: '서구', detail: '둔산동 123-45' },
    facilities: ['parking', 'nursing_room', 'stroller_rental'],
    priceType: 'paid',
    ageTags: ['toddler', 'preschooler'],
    isOpen: true,
    score: 4.5,
    images: [],
    metadata: { source: 'system_mock', updatedAt: admin.firestore.FieldValue.serverTimestamp() },
    status: 'active'
  },
  {
    name: '(Mock) 세종 중앙공원 놀이터',
    type: 'park',
    location: new admin.firestore.GeoPoint(36.4805, 127.2895),
    address: { region: '세종', city: '', detail: '세종중앙공원 일원' },
    facilities: ['parking', 'restroom'],
    priceType: 'free',
    ageTags: ['toddler', 'preschooler', 'school_age'],
    isOpen: true,
    score: 4.8,
    images: [],
    metadata: { source: 'system_mock', updatedAt: admin.firestore.FieldValue.serverTimestamp() },
    status: 'active'
  }
];

// 공공데이터 Fetch Helper func
function fetchPublicData(url: string): Promise<any> {
  return new Promise((resolve, reject) => {
    https.get(url, { agent: httpsAgent }, (res) => {
      let result = '';
      res.on('data', chunk => result += chunk);
      res.on('end', () => resolve(result));
    }).on('error', reject);
  });
}

// 통합 Seeding 로직
async function seedPlaces() {
  console.log('🌱 Starting Data Seeding to Firestore...');
  const placesCol = db.collection('places');
  let addedCount = 0;

  try {
    // Note: 데이터포털 API는 보통 '/상세엔드포인트명'이 붙습니다. 
    // 예: .../pfc3/getOprnPfcData?serviceKey=... (임시로 기본 호출 시도)
    const testUrl = `${BASE_URL_PFC}?serviceKey=${API_KEY}&numOfRows=10&pageNo=1&type=json`;
    console.log(`📡 Fetching API: ${BASE_URL_PFC}`);
    
    const apiResult = await fetchPublicData(testUrl);
    
    // API 응답이 "Unexpected errors" 등 비정상 XML을 내릴 경우 대비
    if (apiResult.includes("Unexpected errors") || !apiResult.includes("{")) {
      console.log('⚠️ API 응답에 명확한 오퍼레이션 엔드포인트가 누락되었거나 오류가 발생했습니다. (Mock 데이터로 Fallback)');
      throw new Error("Invalid API Response Format");
    }

    // JSON 파싱 후 Firestore 매핑 로직 (정상 작동 시 가정)
    const parsed = JSON.parse(apiResult);
    const items = parsed.response?.body?.items || [];
    
    if (items.length > 0) {
      console.log(`✅ Fetched ${items.length} items from API`);
      // TODO: items를 Firestore 모델로 매핑 (map function 작성)
      // 현재는 API 리턴 형태를 바로 알 수 없어 Fallback으로 넘김
    }

  } catch (error) {
    console.log('🔄 Fallback: Inserting Mock Data directly...');
    
    // 1. 기존 Mock 데이터 모두 넣기
    for (const place of mockPlaces) {
      try {
        await placesCol.add(place);
        console.log(`✅ Inserted: ${place.name}`);
        addedCount++;
      } catch (err) {
        console.error(`❌ Failed to insert ${place.name}:`, err);
      }
    }
  }

  console.log(`\n🎉 Done! Added ${addedCount} places. (Check Firestore Console)`);
}

// Execute
if (require.main === module) {
  seedPlaces().then(() => process.exit(0));
}

export { db, seedPlaces };
