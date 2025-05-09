import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterProvider extends ChangeNotifier {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimationInitialized = false;

  int _counter = 0;
  bool _isDarkMode = false;
  String _locale = 'en';

  int get counter => _counter;
  bool get isDarkMode => _isDarkMode;
  String get locale => _locale;
  bool get isAnimationInitialized => _isAnimationInitialized;

  Animation<double> get scaleAnimation => _animation;

  CounterProvider() {
    _init();
  }

  Future<void> _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('counter') ?? 0;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _locale = prefs.getString('locale') ?? 'en';
    notifyListeners();
  }

  void initAnimationController(TickerProvider vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
    _isAnimationInitialized = true;
    notifyListeners();
  }

  void _triggerAnimation() {
    if (_isAnimationInitialized) {
      _controller.forward(from: 0.0);
    }
  }

  void increment(BuildContext context) {
    if (_counter < 10) {
      _counter++;
      _saveCounter();
      _triggerAnimation();
      notifyListeners();
    } else {
      _showSnackBar(context, 'Counter cannot go above 10');
    }
  }

  void decrement(BuildContext context) {
    if (_counter > 0) {
      _counter--;
      _saveCounter();
      _triggerAnimation();
      notifyListeners();
    } else {
      _showSnackBar(context, 'Counter cannot go below 0');
    }
  }
  void reset(BuildContext context) {
    _counter = 0;
    _controller.forward(from: 0);
    _saveCounter();
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(locale == 'es'
            ? 'Contador reiniciado a 0'
            : 'Counter reset to 0'),
      ),
    );
  }


  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  void changeLocale(String code) {
    _locale = code;
    _saveLocale();
    notifyListeners();
  }

  String getCounterSize() {
    if (_counter < 5) return "Small";
    if (_counter < 10) return "Medium";
    return "Large";
  }

  Color get counterColor => _counter % 2 == 0 ? Colors.blue : Colors.red;

  void _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
  }

  void _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _saveLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', _locale);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    if (_isAnimationInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }
}
