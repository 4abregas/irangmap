import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/config/app_environment.dart';
import '../../core/map/google_map_service_impl.dart';
import '../../core/map/map_service.dart';
import '../../data/models/place_model.dart';

final placesStreamProvider = StreamProvider<List<PlaceModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('places')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => PlaceModel.fromFirestore(doc)).toList());
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final MapService _mapService;
  final TextEditingController _searchController = TextEditingController();

  String _selectedType = 'all';
  String _selectedPrice = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _mapService = GoogleMapServiceImpl();
    _mapService.initialize();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlaceModel> _applyFilters(List<PlaceModel> places) {
    final filtered = places.where((place) {
      final matchesType = _selectedType == 'all' || place.type == _selectedType;
      final matchesPrice = _selectedPrice == 'all' || place.priceType == _selectedPrice;
      final searchTarget = '${place.name} ${place.address}'.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || searchTarget.contains(_searchQuery);
      return matchesType && matchesPrice && matchesSearch;
    }).toList();

    filtered.sort((a, b) => b.score.compareTo(a.score));
    return filtered;
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'kidscafe':
        return '키즈카페';
      case 'park':
        return '공원';
      case 'museum':
        return '박물관';
      case 'experience':
        return '체험공간';
      default:
        return type.isEmpty ? '미분류' : type;
    }
  }

  String _priceLabel(String priceType) {
    switch (priceType) {
      case 'free':
        return '무료';
      case 'paid':
        return '유료';
      case 'mixed':
        return '일부 유료';
      default:
        return '요금 확인';
    }
  }

  String _facilityLabel(String facility) {
    switch (facility) {
      case 'parking':
        return '주차';
      case 'nursing_room':
        return '수유실';
      case 'stroller_rental':
        return '유모차';
      case 'restroom':
        return '화장실';
      case 'cafe':
        return '카페';
      default:
        return facility;
    }
  }

  Widget _buildShell(BuildContext context, Widget child) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFF8EF),
            Color(0xFFF7F0E6),
            Color(0xFFF8F3EC),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }

  Widget _buildHeader(BuildContext context, AppBootstrapState bootstrapState, int placeCount) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF16212E),
            Color(0xFF29384A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 32,
            offset: Offset(0, 18),
            color: Color(0x2216212E),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard_customize_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Family Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!bootstrapState.adsReady)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1D8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '광고 안전 모드',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            '오늘은 아이랑\n어디 가볼까요?',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '지금 열려 있는 장소를 빠르게 비교하고, 가족 친화 시설 중심으로 바로 이동해 보세요. 현재 $placeCount개 장소를 준비해 두었습니다.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha(220),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '장소명이나 동네를 검색해 보세요',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    List<PlaceModel> places,
    List<PlaceModel> filteredPlaces,
    AppBootstrapState bootstrapState,
  ) {
    final freeCount = places.where((place) => place.priceType == 'free').length;
    final familyFacilityCount = places.where((place) => place.facilities.isNotEmpty).length;
    final featuredPlaces = filteredPlaces.take(3).toList();
    final mapMarkers = filteredPlaces
        .map(
          (place) => PlacePointer(
            id: place.id,
            latitude: place.latitude,
            longitude: place.longitude,
            title: place.name,
          ),
        )
        .toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _buildHeader(context, bootstrapState, places.length),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    title: '운영 중 장소',
                    value: '${places.where((place) => place.isOpen).length}',
                    accent: const Color(0xFFFFE0C7),
                    icon: Icons.place_rounded,
                  ),
                  _MetricCard(
                    title: '무료 방문',
                    value: '$freeCount곳',
                    accent: const Color(0xFFDDF4E9),
                    icon: Icons.savings_rounded,
                  ),
                  _MetricCard(
                    title: '편의시설 보유',
                    value: '$familyFacilityCount곳',
                    accent: const Color(0xFFDDEBFF),
                    icon: Icons.family_restroom_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: '빠른 필터',
                subtitle: '바로 사용할 수 있게 핵심 조건만 남겼어요.',
                trailing: Text(
                  '${filteredPlaces.length}개 결과',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: '전체',
                      selected: _selectedType == 'all',
                      onTap: () => setState(() => _selectedType = 'all'),
                    ),
                    _FilterChip(
                      label: '키즈카페',
                      selected: _selectedType == 'kidscafe',
                      onTap: () => setState(() => _selectedType = 'kidscafe'),
                    ),
                    _FilterChip(
                      label: '공원',
                      selected: _selectedType == 'park',
                      onTap: () => setState(() => _selectedType = 'park'),
                    ),
                    _FilterChip(
                      label: '무료',
                      selected: _selectedPrice == 'free',
                      onTap: () => setState(() => _selectedPrice = _selectedPrice == 'free' ? 'all' : 'free'),
                    ),
                    _FilterChip(
                      label: '유료',
                      selected: _selectedPrice == 'paid',
                      onTap: () => setState(() => _selectedPrice = _selectedPrice == 'paid' ? 'all' : 'paid'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(
                title: '대시보드 맵',
                subtitle: AppEnvironment.mapsPreviewEnabled
                    ? '선택한 장소를 지도와 카드에서 함께 비교할 수 있어요.'
                    : '안정성을 위해 지도는 설정 완료 후에만 표시됩니다.',
              ),
              const SizedBox(height: 12),
              if (AppEnvironment.mapsPreviewEnabled && mapMarkers.isNotEmpty)
                Container(
                  height: 260,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 28,
                        offset: Offset(0, 18),
                        color: Color(0x1616212E),
                      ),
                    ],
                  ),
                  child: _mapService.buildMap(
                    centerLat: mapMarkers.first.latitude,
                    centerLng: mapMarkers.first.longitude,
                    markers: mapMarkers,
                    onMarkerTapped: (placeId) => context.push('/places/$placeId'),
                  ),
                )
              else
                const _SetupCalloutCard(
                  title: '지도 미리보기는 준비되면 바로 켤 수 있게 해두었습니다.',
                  body: AppEnvironment.setupGuide,
                  tone: Color(0xFFEAF2FF),
                  icon: Icons.map_rounded,
                ),
              const SizedBox(height: 24),
              if (featuredPlaces.isNotEmpty) ...[
                const _SectionHeader(
                  title: '오늘의 추천',
                  subtitle: '점수와 편의시설 기준으로 먼저 보이는 장소예요.',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 208,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredPlaces.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final place = featuredPlaces[index];
                      return _FeaturedPlaceCard(
                        place: place,
                        typeLabel: _typeLabel(place.type),
                        priceLabel: _priceLabel(place.priceType),
                        onTap: () => context.push('/places/${place.id}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const _SectionHeader(
                title: '바로 이용할 장소',
                subtitle: '주소, 요금, 편의시설을 한 장에서 확인할 수 있어요.',
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        if (filteredPlaces.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 32),
              child: _SetupCalloutCard(
                title: '조건에 맞는 장소를 찾지 못했어요.',
                body: '검색어를 비우거나 필터를 전체로 바꾸면 더 많은 결과를 볼 수 있습니다.',
                tone: Color(0xFFFFF1D8),
                icon: Icons.search_off_rounded,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final place = filteredPlaces[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == filteredPlaces.length - 1 ? 0 : 14),
                    child: _PlaceListCard(
                      place: place,
                      typeLabel: _typeLabel(place.type),
                      priceLabel: _priceLabel(place.priceType),
                      facilityLabels: place.facilities.take(3).map(_facilityLabel).toList(),
                      onTap: () => context.push('/places/${place.id}'),
                    ),
                  );
                },
                childCount: filteredPlaces.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: const [
        _LoadingHero(),
        SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _LoadingCard(height: 96)),
            SizedBox(width: 12),
            Expanded(child: _LoadingCard(height: 96)),
            SizedBox(width: 12),
            Expanded(child: _LoadingCard(height: 96)),
          ],
        ),
        SizedBox(height: 18),
        _LoadingCard(height: 150),
        SizedBox(height: 18),
        _LoadingCard(height: 220),
        SizedBox(height: 18),
        _LoadingCard(height: 140),
        SizedBox(height: 14),
        _LoadingCard(height: 140),
      ],
    );
  }

  Widget _buildSetupState(BuildContext context, AppBootstrapState? bootstrapState, {String? fallbackMessage}) {
    final setupItems = [
      'Android: `android/app/google-services.json`, Maps key, AdMob App ID 확인',
      'iOS: `ios/Runner/GoogleService-Info.plist` 추가 후 `pod install` 실행',
      '지도를 켜려면 native API key 설정 뒤 `IRANGMAP_ENABLE_MAPS=true`로 빌드',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        _buildHeader(context, bootstrapState ?? const AppBootstrapState(firebaseReady: false, adsReady: false), 0),
        const SizedBox(height: 18),
        _SetupCalloutCard(
          title: '앱은 열렸지만, 운영 환경 연결이 아직 완성되지 않았습니다.',
          body: fallbackMessage ?? bootstrapState?.firebaseMessage ?? AppEnvironment.setupGuide,
          tone: const Color(0xFFFFF1D8),
          icon: Icons.construction_rounded,
        ),
        if (bootstrapState?.adsMessage != null) ...[
          const SizedBox(height: 12),
          _SetupCalloutCard(
            title: '광고 SDK는 안전 모드로 전환되었습니다.',
            body: bootstrapState!.adsMessage!,
            tone: const Color(0xFFE8F2FF),
            icon: Icons.privacy_tip_rounded,
          ),
        ],
        const SizedBox(height: 18),
        const _SectionHeader(
          title: '안정화 체크리스트',
          subtitle: '안드로이드와 iOS 모두 같은 기준으로 준비할 수 있게 정리했습니다.',
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < setupItems.length; i++) ...[
          _ChecklistCard(index: i + 1, text: setupItems[i]),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bootstrapAsync = ref.watch(appBootstrapProvider);

    return Scaffold(
      body: SafeArea(
        child: bootstrapAsync.when(
          loading: () => _buildShell(context, _buildLoadingState(context)),
          error: (error, stackTrace) => _buildShell(
            context,
            _buildSetupState(
              context,
              null,
              fallbackMessage: '앱 초기화 중 예상치 못한 오류가 발생했습니다.\n$error',
            ),
          ),
          data: (bootstrapState) {
            if (!bootstrapState.canLoadRemoteData) {
              return _buildShell(context, _buildSetupState(context, bootstrapState));
            }

            final placesAsync = ref.watch(placesStreamProvider);
            return _buildShell(
              context,
              placesAsync.when(
                loading: () => _buildLoadingState(context),
                error: (error, stackTrace) => _buildSetupState(
                  context,
                  bootstrapState,
                  fallbackMessage: '장소 데이터를 가져오지 못했습니다.\n$error',
                ),
                data: (places) => _buildDashboard(
                  context,
                  places,
                  _applyFilters(places),
                  bootstrapState,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFF16212E)),
              ),
              const SizedBox(height: 18),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF16212E),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _FeaturedPlaceCard extends StatelessWidget {
  final PlaceModel place;
  final String typeLabel;
  final String priceLabel;
  final VoidCallback onTap;

  const _FeaturedPlaceCard({
    required this.place,
    required this.typeLabel,
    required this.priceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 248,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF1E0),
                Color(0xFFFFFFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(typeLabel, style: Theme.of(context).textTheme.labelLarge),
                    ),
                    const Spacer(),
                    Text(
                      place.score.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF16212E),
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(place.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  place.address.isEmpty ? '주소 정보 준비 중' : place.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.sell_rounded, size: 16, color: Color(0xFF6A7280)),
                    const SizedBox(width: 6),
                    Text(priceLabel),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceListCard extends StatelessWidget {
  final PlaceModel place;
  final String typeLabel;
  final String priceLabel;
  final List<String> facilityLabels;
  final VoidCallback onTap;

  const _PlaceListCard({
    required this.place,
    required this.typeLabel,
    required this.priceLabel,
    required this.facilityLabels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24,
              offset: Offset(0, 12),
              color: Color(0x1216212E),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(typeLabel, style: Theme.of(context).textTheme.labelLarge),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF08A38)),
                      const SizedBox(width: 4),
                      Text(place.score.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(place.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              place.address.isEmpty ? '주소 정보 준비 중' : place.address,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TinyInfoPill(icon: Icons.sell_rounded, label: priceLabel),
                _TinyInfoPill(
                  icon: place.isOpen ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                  label: place.isOpen ? '운영 중' : '방문 전 확인',
                ),
                for (final facility in facilityLabels)
                  _TinyInfoPill(icon: Icons.family_restroom_rounded, label: facility),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TinyInfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF6A7280)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF49525D),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SetupCalloutCard extends StatelessWidget {
  final String title;
  final String body;
  final Color tone;
  final IconData icon;

  const _SetupCalloutCard({
    required this.title,
    required this.body,
    required this.tone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF16212E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final int index;
  final String text;

  const _ChecklistCard({
    required this.index,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFF16212E),
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _LoadingHero extends StatelessWidget {
  const _LoadingHero();

  @override
  Widget build(BuildContext context) {
    return const _LoadingCard(height: 258, radius: 32);
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  final double radius;

  const _LoadingCard({
    required this.height,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF0E7DA),
            Color(0xFFF7F1E8),
          ],
        ),
      ),
    );
  }
}
