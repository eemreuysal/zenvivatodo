import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/inspiration_service.dart';

/// Motivasyon ve aktivite önerileri gösteren kart widget'ı
///
/// Bu widget, kullanıcıya API'dan alınan rastgele motivasyon
/// alıntıları ve aktivite önerileri gösterir.
class InspirationCard extends StatefulWidget {
  // Constructor'ı sınıfın başına taşıdık - sort_constructors_first
  const InspirationCard({super.key, required this.type, this.onRefresh, this.visible = true});

  /// Kart tipi ('quote' veya 'activity')
  final String type;

  /// Kart yenileme fonksiyonu
  final VoidCallback? onRefresh;

  /// Görünürlük kontrolü için
  final bool visible;

  @override
  State<InspirationCard> createState() => _InspirationCardState();
}

class _InspirationCardState extends State<InspirationCard> {
  final InspirationService _inspirationService = InspirationService();

  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(InspirationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _loadData();
    }
  }

  // Veri yükle
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.type == 'quote') {
        final quote = await _inspirationService.getRandomQuote();
        setState(() {
          _data = quote;
          _isLoading = false;
        });
      } else if (widget.type == 'activity') {
        final activity = await _inspirationService.getRandomActivity();
        setState(() {
          _data = activity;
          _isLoading = false;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // İçeriği yenile
  void _refresh() {
    _loadData();
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      opacity: widget.visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color:
                widget.type == 'quote'
                    ? colorScheme.secondaryContainer
                    : colorScheme.tertiaryContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _refresh,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoading ? _buildLoadingState(context) : _buildContent(context),
              ),
            ),
          )
          .animate(onComplete: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms, delay: 1000.ms)
          .then()
          .scale(duration: 300.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.03, 1.03))
          .then(delay: 300.ms)
          .scale(duration: 300.ms, begin: const Offset(1.03, 1.03), end: const Offset(1.0, 1.0)),
    );
  }

  // Yükleme durumu
  Widget _buildLoadingState(BuildContext context) {
    return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
  }

  // İçerik
  Widget _buildContent(BuildContext context) {
    if (_data == null) {
      return const SizedBox(height: 100, child: Center(child: Text('Veri yüklenemedi')));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.type == 'quote') {
      final text = _data!['text'] as String;
      final author = _data!['author'] as String;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günün Sözü',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
                tooltip: 'Yenile',
                iconSize: 20,
                // withOpacity yerine withValues kullanıldı
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"$text"',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '- $author',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                // withOpacity yerine withValues kullanıldı
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      );
    } else if (widget.type == 'activity') {
      final activity = _data!['activity'] as String;
      final type = _data!['typeTr'] ?? _data!['type'] as String;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivite Önerisi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
                tooltip: 'Yenile',
                iconSize: 20,
                // withOpacity yerine withValues kullanıldı
                color: colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity,
            style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onTertiaryContainer),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Chip(
                label: Text(
                  type.toString().toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                // withOpacity yerine withValues kullanıldı
                backgroundColor: colorScheme.tertiary.withValues(alpha: 0.3),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// Motivasyon ve aktivite kartları arasında geçiş yapabilen widget
class InspirationCardSwitch extends StatefulWidget {
  const InspirationCardSwitch({super.key});

  @override
  State<InspirationCardSwitch> createState() => _InspirationCardSwitchState();
}

class _InspirationCardSwitchState extends State<InspirationCardSwitch> {
  String _currentType = 'quote';
  bool _isVisible = true;

  void _toggleType() {
    setState(() {
      _isVisible = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _currentType = _currentType == 'quote' ? 'activity' : 'quote';
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InspirationCard(type: _currentType, visible: _isVisible),
        TextButton.icon(
          onPressed: _toggleType,
          icon: Icon(_currentType == 'quote' ? Icons.schedule : Icons.format_quote, size: 16),
          label: Text(
            _currentType == 'quote' ? 'Aktivite Önerisi Göster' : 'Motivasyon Alıntısı Göster',
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
