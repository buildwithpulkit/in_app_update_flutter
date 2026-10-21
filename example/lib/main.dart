import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Platform.isAndroid
          ? const AndroidUpdateExample()
          : const IosUpdateExample(),
    );
  }
}

// =============================================================================
// iOS Example
// =============================================================================

/// iOS: Shows the App Store product page overlay via StoreKit.
///
/// To check for an update first, call `checkUpdateIos()` and pass its
/// `appStoreId` to `showUpdateForIos`. This demo uses a fixed public App
/// Store ID, so it presents the App Store page directly.
class IosUpdateExample extends StatelessWidget {
  const IosUpdateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In-App Update (iOS)')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              // Public App Store ID used only for this demo (YouTube).
              // Replace with your own app's numeric App Store ID in a real
              // integration.
              await InAppUpdateFlutter()
                  .showUpdateForIos(appStoreId: '544007664');
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: const Text('Show App Store Update'),
        ),
      ),
    );
  }
}

// =============================================================================
// Android Example
// =============================================================================

/// Android: Demonstrates the full Play Core In-App Updates flow.
///
/// The recommended flow is:
///
/// 1. **Check** — Call [checkUpdateAndroid] to query Play Core for update info.
/// 2. **Decide** — Inspect [AppUpdateInfoAndroid] to determine if an update is
///    available, what types are allowed, and whether priority/staleness warrant
///    prompting the user.
/// 3. **Start** — Call [startImmediateUpdateAndroid] or [startFlexibleUpdateAndroid]
///    based on the update info.
/// 4. **Monitor** (flexible only) — Listen to [installStateStreamAndroid] for
///    download progress.
/// 5. **Complete** (flexible only) — Call [completeUpdateAndroid] once the
///    download reaches [InstallStatusAndroid.downloaded] to trigger an app restart.
class AndroidUpdateExample extends StatefulWidget {
  const AndroidUpdateExample({super.key});

  @override
  State<AndroidUpdateExample> createState() => _AndroidUpdateExampleState();
}

class _AndroidUpdateExampleState extends State<AndroidUpdateExample> {
  final _plugin = InAppUpdateFlutter();
  AppUpdateInfoAndroid? _updateInfo;
  String _status = 'Press "Check for Update" to start.';

  // ---------------------------------------------------------------------------
  // Step 1: Check for update
  // ---------------------------------------------------------------------------

  /// Always start here. This queries Play Core and returns metadata about the
  /// available update (if any). No UI is shown to the user at this point.
  Future<void> _checkForUpdate() async {
    setState(() => _status = 'Checking for update...');
    try {
      final info = await _plugin.checkUpdateAndroid();
      setState(() {
        _updateInfo = info;
        _status =
            info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable
                ? 'Update available! Choose an update type below.'
                : 'No update available (${info.updateAvailability.name}).';
      });
    } catch (e) {
      setState(() {
        _updateInfo = null;
        _status = 'Check failed: $e';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Step 2 & 3: Start the update (only after checking)
  // ---------------------------------------------------------------------------

  /// Immediate update: full-screen, blocking UI managed by Google Play.
  /// The user must accept or cancel. The app restarts automatically on success.
  Future<void> _startImmediateUpdate() async {
    setState(() => _status = 'Starting immediate update...');
    try {
      final result = await _plugin.startImmediateUpdateAndroid();
      setState(() => _status = 'Immediate update result: ${result.name}');
    } catch (e) {
      setState(() => _status = 'Immediate update error: $e');
    }
  }

  /// Flexible update: downloads in the background while the user keeps using
  /// the app. You must listen to [installStateStreamAndroid] and call
  /// [completeUpdateAndroid] when the download finishes.
  Future<void> _startFlexibleUpdate() async {
    setState(() => _status = 'Starting flexible update...');
    try {
      final result = await _plugin.startFlexibleUpdateAndroid();
      setState(() => _status = result == UpdateResultAndroid.success
          ? 'Flexible update started — monitor progress below.'
          : 'Flexible update result: ${result.name}');
    } catch (e) {
      setState(() => _status = 'Flexible update error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Step 4 & 5: Complete a flexible update after download
  // ---------------------------------------------------------------------------

  /// Call this only after [installStateStreamAndroid] reports
  /// [InstallStatusAndroid.downloaded]. This triggers an app restart to
  /// install the update.
  Future<void> _completeUpdate() async {
    setState(() => _status = 'Completing update — app will restart...');
    try {
      await _plugin.completeUpdateAndroid();
    } catch (e) {
      setState(() => _status = 'Complete update error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasChecked = _updateInfo != null;
    final isUpdateAvailable = _updateInfo?.updateAvailability ==
        UpdateAvailabilityAndroid.updateAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('In-App Update (Android)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status
          Text(_status, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),

          // Update info (shown after check)
          if (hasChecked) ...[
            _InfoCard(info: _updateInfo!),
            const SizedBox(height: 16),
          ],

          // Step 1: Check
          _StepButton(
            step: 1,
            label: 'Check for Update',
            onPressed: _checkForUpdate,
          ),

          // Step 2: Immediate (enabled only if update is available & allowed)
          _StepButton(
            step: 2,
            label: 'Start Immediate Update',
            onPressed: isUpdateAvailable &&
                    (_updateInfo?.isImmediateUpdateAllowed ?? false)
                ? _startImmediateUpdate
                : null,
          ),

          // Step 3: Flexible (enabled only if update is available & allowed)
          _StepButton(
            step: 3,
            label: 'Start Flexible Update',
            onPressed: isUpdateAvailable &&
                    (_updateInfo?.isFlexibleUpdateAllowed ?? false)
                ? _startFlexibleUpdate
                : null,
          ),

          // Step 4: Monitor flexible progress
          const SizedBox(height: 16),
          Text(
            'Step 4 — Flexible Update Progress',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _FlexibleProgressWidget(plugin: _plugin),

          // Step 5: Complete
          const SizedBox(height: 8),
          _StepButton(
            step: 5,
            label: 'Complete Update (restart app)',
            onPressed: _completeUpdate,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Helper widgets
// =============================================================================

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.step,
    required this.label,
    required this.onPressed,
  });

  final int step;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text('Step $step: $label'),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.info});

  final AppUpdateInfoAndroid info;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Info',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text('Availability: ${info.updateAvailability.name}'),
            Text('Version code: ${info.availableVersionCode ?? "N/A"}'),
            Text('Priority: ${info.updatePriority}'),
            Text('Staleness: ${info.clientVersionStalenessDays ?? "N/A"} days'),
            Text('Immediate allowed: ${info.isImmediateUpdateAllowed}'),
            Text('Flexible allowed: ${info.isFlexibleUpdateAllowed}'),
            Text('Install status: ${info.installStatus.name}'),
          ],
        ),
      ),
    );
  }
}

class _FlexibleProgressWidget extends StatelessWidget {
  const _FlexibleProgressWidget({required this.plugin});

  final InAppUpdateFlutter plugin;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InstallStateAndroid>(
      stream: plugin.installStateStreamAndroid,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('No active download.');
        }
        final state = snapshot.data!;
        final progress = state.totalBytesToDownload > 0
            ? state.bytesDownloaded / state.totalBytesToDownload
            : 0.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${state.status.name}'),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text(
              '${state.bytesDownloaded} / ${state.totalBytesToDownload} bytes',
            ),
            if (state.status == InstallStatusAndroid.downloaded)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Download complete — press "Complete Update" to install.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }
}
