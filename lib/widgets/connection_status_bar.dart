import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ConnectivityService için import
import '../services/connectivity_service.dart' hide ConnectivityProvider;

// ConnectivityProvider sınıfı için import ve as kullanımı
import '../main.dart' as main_lib; 

/// Bağlantı durumunu gösteren widget
///
/// Bu widget, internet bağlantısının durumunu ve çevrimiçi/çevrimdışı
/// mod seçeneğini gösteren bir durum çubuğu sağlar.
class ConnectionStatusBar extends StatelessWidget {
  // Constructor sınıfın en üstünde tanımlanmalı
  const ConnectionStatusBar({
    super.key,
    this.onlineColor,
    this.offlineColor,
    this.showOnlineSwitch = true,
  });
  
  final Color? onlineColor;
  final Color? offlineColor;
  final bool showOnlineSwitch;

  @override
  Widget build(BuildContext context) {
    return Consumer<main_lib.ConnectivityProvider>(
      builder: (context, connectivity, child) {
        final colorScheme = Theme.of(context).colorScheme;
        
        final bgColor = connectivity.hasConnection
            ? onlineColor ?? Colors.green.shade600
            : offlineColor ?? Colors.red.shade600;
        
        const textColor = Colors.white;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      connectivity.hasConnection
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color: textColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connectivity.hasConnection
                          ? 'İnternet bağlantısı mevcut'
                          : 'İnternet bağlantısı yok',
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (showOnlineSwitch)
                  Row(
                    children: [
                      Text(
                        connectivity.isOnlineMode
                            ? 'Çevrimiçi'
                            : 'Çevrimdışı',
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: connectivity.isOnlineMode,
                        onChanged: (_) => connectivity.toggleOnlineMode(),
                        activeColor: colorScheme.primary,
                        inactiveThumbColor: colorScheme.secondary,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bağlantı durumunu ve çevrimiçi operasyonları göstermek için bir scaffold
///
/// Bu widget, ConnectionStatusBar'ı en üstte gösterir ve internet
/// bağlantısı durumuna göre farklı içerikler sunar.
class ConnectionAwareScaffold extends StatelessWidget {
  // Constructor sınıfın en üstünde tanımlanmalı
  const ConnectionAwareScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.resizeToAvoidBottomInset,
    this.showConnectionStatusBar = true,
  });
  
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final Widget? drawer;
  final bool? resizeToAvoidBottomInset;
  final bool showConnectionStatusBar;

  @override
  Widget build(BuildContext context) {
    return Consumer<main_lib.ConnectivityProvider>(
      builder: (context, connectivity, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: actions,
          ),
          body: Column(
            children: [
              // Bağlantı durumu çubuğu
              if (showConnectionStatusBar)
                const ConnectionStatusBar(),
              
              // Ana içerik
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          drawer: drawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        );
      },
    );
  }
}

/// Internet bağlantısı gerektiren işlemler için bir wrapper widget
///
/// Bu widget, internet bağlantısı olmadığında veya çevrimdışı modda
/// kullanıcıya uygun bir mesaj gösterir.
class OnlineOperationWrapper extends StatelessWidget {
  // Constructor sınıfın en üstünde tanımlanmalı
  const OnlineOperationWrapper({
    super.key,
    required this.child,
    this.offlineWidget,
    this.offlineMessage = 'Bu özellik internet bağlantısı gerektirir',
  });
  
  final Widget child;
  final Widget? offlineWidget;
  final String offlineMessage;

  @override
  Widget build(BuildContext context) {
    return Consumer<main_lib.ConnectivityProvider>(
      builder: (context, connectivity, _) {
        if (connectivity.canPerformOnlineOperations) {
          return child;
        }
        
        // Özel offline widget varsa onu göster
        if (offlineWidget != null) {
          return offlineWidget!;
        }
        
        // Varsayılan offline mesajı
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  connectivity.hasConnection
                      ? Icons.cloud_off
                      : Icons.wifi_off,
                  size: 64,
                  // withOpacity yerine withValues kullanımı
                  color: Theme.of(context).colorScheme.primary.withAlpha(153), // 0.6 opaklık
                ),
                const SizedBox(height: 16),
                Text(
                  connectivity.hasConnection
                      ? 'Çevrimdışı Mod Aktif'
                      : 'İnternet Bağlantısı Yok',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  offlineMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!connectivity.hasConnection)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ConnectivityService().checkConnection();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Bağlantıyı Kontrol Et'),
                  )
                else if (!connectivity.isOnlineMode)
                  ElevatedButton.icon(
                    onPressed: () => connectivity.toggleOnlineMode(),
                    icon: const Icon(Icons.cloud),
                    label: const Text('Çevrimiçi Moda Geç'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}