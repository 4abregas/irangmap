import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../data/models/place_model.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            return;
          }
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    );
    _bannerAd?.load();
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
        return '요금 정보 확인 필요';
    }
  }

  String _ageTagLabel(String ageTag) {
    switch (ageTag) {
      case 'infant':
        return '영아';
      case 'toddler':
        return '유아';
      case 'preschooler':
        return '미취학';
      case 'school_age':
        return '초등';
      default:
        return ageTag;
    }
  }

  String _facilityLabel(String facility) {
    switch (facility) {
      case 'parking':
        return '주차 가능';
      case 'nursing_room':
        return '수유실';
      case 'stroller_rental':
        return '유모차 대여';
      case 'restroom':
        return '화장실';
      case 'cafe':
        return '카페';
      default:
        return facility;
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _buildChips(List<String> values, String Function(String) labelBuilder) {
    if (values.isEmpty) {
      return const Text('등록된 정보가 없습니다.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => Chip(
              label: Text(labelBuilder(value)),
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }

  Widget _buildDetailBody(BuildContext context, PlaceModel place) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 220,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withAlpha(214),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _typeLabel(place.type),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  place.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  place.address.isEmpty ? '주소 정보가 아직 등록되지 않았어요.' : place.address,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cards = [
                      _InfoCard(
                        label: '운영 상태',
                        value: place.isOpen ? '운영 중' : '휴무/종료',
                      ),
                      _InfoCard(
                        label: '요금',
                        value: _priceLabel(place.priceType),
                      ),
                      _InfoCard(
                        label: '추천 점수',
                        value: place.score.toStringAsFixed(1),
                      ),
                    ];

                    if (constraints.maxWidth < 520) {
                      return Column(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            cards[i],
                          ],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: cards[i]),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, '아이랑 가기 좋은 이유'),
                Text(
                  place.facilities.isEmpty
                      ? '아직 운영 정보가 충분하지 않아요. 관리자가 세부 포인트를 보강할 예정입니다.'
                      : '${place.name}은(는) 가족 단위 방문을 고려해 편의시설 정보가 정리된 장소예요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, '추천 연령'),
                _buildChips(place.ageTags, _ageTagLabel),
                const SizedBox(height: 24),
                _buildSectionTitle(context, '편의시설'),
                _buildChips(place.facilities, _facilityLabel),
                const SizedBox(height: 24),
                _buildSectionTitle(context, '이용 안내'),
                Text(
                  '${place.isOpen ? '현재 운영 중으로 표시되어 있어요.' : '방문 전 운영 여부를 다시 확인해 주세요.'}\n'
                  '요금 구분: ${_priceLabel(place.priceType)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (_isBannerAdLoaded && _bannerAd != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bootstrapAsync = ref.watch(appBootstrapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('장소 정보')),
      body: bootstrapAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('앱 초기화 중 오류가 발생했습니다.\n$error'),
          ),
        ),
        data: (bootstrapState) {
          if (!bootstrapState.firebaseReady) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  bootstrapState.firebaseMessage ??
                      'Firebase가 준비되지 않아 상세 정보를 불러올 수 없습니다.',
                ),
              ),
            );
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('places')
                .doc(widget.placeId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('장소 정보를 불러오는 중 오류가 발생했습니다.\n${snapshot.error}'),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final document = snapshot.data;
              if (document == null || !document.exists) {
                return const Center(child: Text('선택한 장소 정보를 찾을 수 없습니다.'));
              }

              final place = PlaceModel.fromFirestore(document);
              return _buildDetailBody(context, place);
            },
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
