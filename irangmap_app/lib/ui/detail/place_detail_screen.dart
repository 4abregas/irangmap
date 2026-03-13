import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Unit ID
      size: AdSize.banner,
      request: const AdRequest(
        // Ensure child-directed tags are set correctly (inherited from initialization)
      ),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('장소 정보')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 50),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('아이랑 가기 좋은 포인트', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('• 주차가 편리하고 유모차 대여를 제공해요.\n• 3~5세 아이들이 놀기 좋은 체험관이 있어요.'),
                  const Divider(height: 32),
                  const Text('이용 안내', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('• 운영시간: 09:30 ~ 17:30\n• 요금: 무료 (일부 체험 유료)'),
                ],
              ),
            ),
            // Safe Banner Ad Placement with Margin to prevent accidental clicks
            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 24.0),
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
