const reviewQueue = [
  {
    id: "P-101",
    name: "세종 중앙공원 놀이터",
    status: "심사 대기",
    source: "공공데이터+보강",
    owner: "운영팀",
  },
  {
    id: "P-102",
    name: "대전 국립중앙과학관",
    status: "메타데이터 보강",
    source: "관리자 시드",
    owner: "콘텐츠",
  },
  {
    id: "P-103",
    name: "천안 독립기념관 어린이체험존",
    status: "사진 확인 필요",
    source: "사용자 제보",
    owner: "검수팀",
  },
];

const tracks = [
  {
    title: "앱 경험",
    detail:
      "지도로 탐색하고, 리스트에서 상세 정보로 자연스럽게 이어지는 기본 사용자 흐름을 정리합니다.",
    badge: "Flutter",
  },
  {
    title: "데이터 품질",
    detail:
      "Firestore `places` 컬렉션을 중심으로 상태값, 위치, 편의시설 정보를 일관되게 유지합니다.",
    badge: "Firebase",
  },
  {
    title: "운영 도구",
    detail:
      "관리자가 제보를 검수하고 시드 데이터를 반복 주입할 수 있는 콘솔을 단계적으로 만듭니다.",
    badge: "Next.js",
  },
];

const checklist = [
  "`.env.local`에 Firebase 웹 앱 환경 변수 연결",
  "`perfect-drop-...json` 서비스 계정 키를 관리자 앱 루트에 배치",
  "`scripts/seed_data.ts`로 `places` 초기 데이터 주입",
  "앱과 관리자 둘 다 `places.status`를 공통 기준으로 사용",
];

export default function Home() {
  return (
    <main className="relative overflow-hidden">
      <div className="pointer-events-none absolute inset-x-0 top-0 h-72 bg-[radial-gradient(circle_at_top,rgba(255,138,61,0.18),transparent_60%)]" />
      <div className="mx-auto flex min-h-screen w-full max-w-7xl flex-col px-5 py-6 sm:px-8 lg:px-10">
        <header className="glass-panel relative overflow-hidden rounded-[32px] px-6 py-8 sm:px-8 lg:px-10">
          <div className="absolute right-6 top-6 rounded-full border border-black/10 bg-white/70 px-3 py-1 text-xs font-semibold uppercase tracking-[0.24em] text-slate-600">
            IrangMap Ops
          </div>
          <div className="grid gap-8 lg:grid-cols-[1.4fr_0.9fr]">
            <div className="max-w-3xl">
              <p className="mb-4 inline-flex rounded-full border border-black/10 bg-white/65 px-4 py-2 text-sm font-medium text-slate-700">
                가족 이동 경험을 위한 장소 데이터 운영 콘솔
              </p>
              <h1 className="max-w-3xl text-4xl font-semibold leading-[1.1] tracking-[-0.04em] text-slate-950 sm:text-5xl">
                아이랑맵의 다음 단계는
                <br />
                지도, 데이터, 검수를 한 흐름으로 잇는 거예요.
              </h1>
              <p className="mt-5 max-w-2xl text-base leading-7 text-slate-700 sm:text-lg">
                지금 저장소는 Flutter 사용자 앱과 Next.js 관리자 패널로 나뉘어 있습니다. 이 화면은
                운영 기준, 현재 트랙, 시드 데이터 흐름을 한눈에 보도록 만든 출발점입니다.
              </p>
              <div className="mt-8 flex flex-wrap gap-3">
                <div className="rounded-full bg-slate-950 px-5 py-3 text-sm font-semibold text-white">
                  `places` 컬렉션 중심 설계
                </div>
                <div className="rounded-full border border-black/10 bg-white/70 px-5 py-3 text-sm font-semibold text-slate-700">
                  아동 친화 정보 우선
                </div>
                <div className="rounded-full border border-black/10 bg-white/70 px-5 py-3 text-sm font-semibold text-slate-700">
                  검수와 배포 흐름 분리
                </div>
              </div>
            </div>
            <div className="soft-card rounded-[28px] p-5 sm:p-6">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">
                    Current Focus
                  </p>
                  <h2 className="mt-2 text-2xl font-semibold tracking-[-0.03em] text-slate-950">
                    MVP 정비
                  </h2>
                </div>
                <div className="rounded-2xl bg-[var(--mint)] px-3 py-2 text-xs font-semibold text-slate-800">
                  Week 1
                </div>
              </div>
              <div className="mt-6 space-y-4">
                <div className="rounded-2xl bg-white px-4 py-4 shadow-[0_10px_30px_rgba(22,32,42,0.05)]">
                  <p className="text-sm text-slate-500">앱 연결 상태</p>
                  <p className="mt-1 text-lg font-semibold text-slate-950">
                    탐색 → 상세 진입 흐름 정리 중
                  </p>
                </div>
                <div className="rounded-2xl bg-white px-4 py-4 shadow-[0_10px_30px_rgba(22,32,42,0.05)]">
                  <p className="text-sm text-slate-500">운영 준비도</p>
                  <p className="mt-1 text-lg font-semibold text-slate-950">
                    Firebase 키와 시드 스크립트 점검 필요
                  </p>
                </div>
                <div className="rounded-2xl bg-white px-4 py-4 shadow-[0_10px_30px_rgba(22,32,42,0.05)]">
                  <p className="text-sm text-slate-500">다음 확장 포인트</p>
                  <p className="mt-1 text-lg font-semibold text-slate-950">
                    검수 테이블과 승인 액션 연결
                  </p>
                </div>
              </div>
            </div>
          </div>
        </header>

        <section className="mt-6 grid gap-4 lg:grid-cols-3">
          {tracks.map((track) => (
            <article key={track.title} className="soft-card rounded-[28px] p-6">
              <div className="flex items-center justify-between gap-3">
                <h2 className="text-xl font-semibold tracking-[-0.03em] text-slate-950">
                  {track.title}
                </h2>
                <span className="rounded-full bg-[var(--sky)] px-3 py-1 text-xs font-semibold text-slate-700">
                  {track.badge}
                </span>
              </div>
              <p className="mt-4 text-sm leading-7 text-slate-700">{track.detail}</p>
            </article>
          ))}
        </section>

        <section className="mt-6 grid gap-6 lg:grid-cols-[1.15fr_0.85fr]">
          <article className="glass-panel rounded-[30px] p-6 sm:p-7">
            <div className="flex flex-wrap items-end justify-between gap-3">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">
                  Review Queue
                </p>
                <h2 className="mt-2 text-2xl font-semibold tracking-[-0.03em] text-slate-950">
                  지금 확인하면 좋은 장소들
                </h2>
              </div>
              <div className="rounded-full border border-black/10 bg-white/70 px-4 py-2 text-sm font-medium text-slate-700">
                샘플 데이터
              </div>
            </div>
            <div className="mt-6 overflow-hidden rounded-[24px] border border-black/10 bg-white">
              <div className="hidden grid-cols-[1.2fr_0.7fr_0.9fr_0.6fr] gap-3 border-b border-black/10 px-5 py-4 text-xs font-semibold uppercase tracking-[0.18em] text-slate-500 md:grid">
                <span>장소</span>
                <span>출처</span>
                <span>상태</span>
                <span>담당</span>
              </div>
              <div>
                {reviewQueue.map((place, index) => (
                  <div
                    key={place.id}
                    className={`px-5 py-4 text-sm text-slate-700 ${
                      index < reviewQueue.length - 1 ? "border-b border-black/6" : ""
                    }`}
                  >
                    <div className="md:hidden">
                      <p className="font-semibold text-slate-950">{place.name}</p>
                      <p className="mt-1 text-xs uppercase tracking-[0.16em] text-slate-400">
                        {place.id}
                      </p>
                      <div className="mt-3 flex flex-wrap gap-2 text-xs text-slate-600">
                        <span className="rounded-full bg-slate-100 px-3 py-1">{place.source}</span>
                        <span className="rounded-full bg-amber-100 px-3 py-1 font-semibold text-amber-900">
                          {place.status}
                        </span>
                        <span className="rounded-full bg-slate-100 px-3 py-1">{place.owner}</span>
                      </div>
                    </div>
                    <div className="hidden md:grid md:grid-cols-[1.2fr_0.7fr_0.9fr_0.6fr] md:gap-3">
                      <div>
                        <p className="font-semibold text-slate-950">{place.name}</p>
                        <p className="mt-1 text-xs uppercase tracking-[0.16em] text-slate-400">
                          {place.id}
                        </p>
                      </div>
                      <span>{place.source}</span>
                      <span>
                        <span className="rounded-full bg-amber-100 px-3 py-1 text-xs font-semibold text-amber-900">
                          {place.status}
                        </span>
                      </span>
                      <span>{place.owner}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </article>

          <article className="soft-card rounded-[30px] p-6 sm:p-7">
            <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">
              Setup Checklist
            </p>
            <h2 className="mt-2 text-2xl font-semibold tracking-[-0.03em] text-slate-950">
              실행 전에 맞춰둘 것들
            </h2>
            <div className="mt-6 space-y-3">
              {checklist.map((item) => (
                <div
                  key={item}
                  className="rounded-2xl border border-black/10 bg-white px-4 py-4 text-sm leading-7 text-slate-700"
                >
                  {item}
                </div>
              ))}
            </div>
            <div className="mt-6 rounded-[24px] bg-slate-950 p-5 text-white">
              <p className="text-xs uppercase tracking-[0.2em] text-white/60">Seed Flow</p>
              <p className="mt-3 text-lg font-semibold">
                공공데이터 API 실패 시 Mock 데이터로 자동 폴백
              </p>
              <p className="mt-3 text-sm leading-7 text-white/75">
                현재 `scripts/seed_data.ts`는 Firestore Admin SDK로 `places` 컬렉션을 채우고,
                API 파싱이 준비되지 않으면 기본 샘플 2건을 넣도록 설계되어 있습니다.
              </p>
            </div>
          </article>
        </section>
      </div>
    </main>
  );
}
