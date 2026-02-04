import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StepGoalApp());
}

class StepGoalApp extends StatefulWidget {
  const StepGoalApp({super.key});

  @override
  State<StepGoalApp> createState() => _StepGoalAppState();
}

class _StepGoalAppState extends State<StepGoalApp> {
  Locale _locale = const Locale('he', 'IL');

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language_code');
    langCode ??= 'he';
    _setLocale(langCode);
  }

  void _setLocale(String langCode) {
    setState(() {
      _locale = langCode == 'he' ? const Locale('he', 'IL') : const Locale('en', 'US');
      AppStrings.setLanguage(langCode);
    });
  }

  void _toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String newLang = _locale.languageCode == 'he' ? 'en' : 'he';
    await prefs.setString('language_code', newLang);
    _setLocale(newLang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      locale: _locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('he', 'IL'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Uses default Material fonts which support Hebrew
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: StepTrackerScreen(onToggleLanguage: _toggleLanguage),
    );
  }
}

class StepTrackerScreen extends StatefulWidget {
  final VoidCallback onToggleLanguage;
  const StepTrackerScreen({super.key, required this.onToggleLanguage});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  late Stream<StepCount> _stepCountStream;
  int currentSteps = 0;
  int stepGoal = 10000;
  bool isDebugMode = false;
  double debugSteps = 0;
  String? _customImagePath;
  final ImagePicker _picker = ImagePicker();
  
  static const String pKeyGoal = 'step_goal';
  static const String pKeyImage = 'custom_image_path';

  StreamSubscription<StepCount>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initPedometer();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      stepGoal = prefs.getInt(pKeyGoal) ?? 10000;
      _customImagePath = prefs.getString(pKeyImage);
    });
  }

  Future<void> _initPedometer() async {
    PermissionStatus status = await Permission.activityRecognition.request();
    
    if (status.isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _subscription = _stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    } else {
      debugPrint(AppStrings.permissionDenied);
    }
  }

  void _onStepCount(StepCount event) {
    if (!isDebugMode) {
      setState(() {
        currentSteps = event.steps;
      });
    }
  }

  void _onStepCountError(dynamic error) {
    debugPrint(AppStrings.pedometerError(error));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _pickRewardImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(pKeyImage, image.path);
      setState(() {
        _customImagePath = image.path;
      });
    }
  }

  void _showSetGoalDialog() {
    final TextEditingController controller = TextEditingController(text: stepGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.setGoalTitle),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: AppStrings.goalInputLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancelBtn),
          ),
          ElevatedButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setInt(pKeyGoal, newGoal);
                });
                setState(() {
                  stepGoal = newGoal;
                  // If we are in debug mode, reset debug slider if it's over the new goal
                  if (debugSteps > stepGoal) {
                    debugSteps = stepGoal.toDouble();
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(AppStrings.saveBtn),
          ),
        ],
      ),
    );
  }

  double _getBlurValue() {
    int effectiveSteps = isDebugMode ? debugSteps.toInt() : currentSteps;
    double progress = (effectiveSteps / stepGoal).clamp(0.0, 1.0);
    double blur = 20 * (1 - progress);
    return blur.clamp(0.0, 20.0);
  }

  @override
  Widget build(BuildContext context) {
    int displaySteps = isDebugMode ? debugSteps.toInt() : currentSteps;
    double blur = _getBlurValue();
    double progress = (displaySteps / stepGoal).clamp(0.0, 1.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.dailyGoalLabel}$stepGoal',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        Text(
                          AppStrings.unlockRewardTitle,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Text(
                              Localizations.localeOf(context).languageCode == 'he' ? 'En' : 'He',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          onPressed: widget.onToggleLanguage,
                        ),
                        _buildSettingsMenu(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displaySteps.toString(),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          Text(
                            AppStrings.stepsLabel,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  AppStrings.progressTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                            child: _buildRewardImage(),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: Text(
                                progress >= 1.0 
                                  ? AppStrings.goalAchievedMessage
                                  : AppStrings.stepsRemainingMessage(stepGoal - displaySteps),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDebugControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardImage() {
    if (_customImagePath != null) {
      return Image.file(
        File(_customImagePath!),
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        AppStrings.defaultRewardImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image, size: 50),
          );
        },
      );
    }
  }

  Widget _buildSettingsMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      onSelected: (value) {
        if (value == 'goal') {
          _showSetGoalDialog();
        } else if (value == 'image') {
          _pickRewardImage();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'goal',
          child: ListTile(
            leading: Icon(Icons.flag),
            title: Text(AppStrings.changeGoalMenu),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'image',
          child: ListTile(
            leading: Icon(Icons.image),
            title: Text(AppStrings.customRewardMenu),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildDebugControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.debugModeLabel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: isDebugMode,
                onChanged: (value) {
                  setState(() {
                    isDebugMode = value;
                  });
                },
              ),
            ],
          ),
          if (isDebugMode) ...[
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: debugSteps,
                    min: 0,
                    max: stepGoal.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        debugSteps = value;
                      });
                    },
                  ),
                ),
                Text(
                  '${debugSteps.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
