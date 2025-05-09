import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'counter_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override

  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<CounterProvider>(context, listen: false);
      provider.initAnimationController(this);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: provider.locale == 'es' ? 'Aplicación de contador de pasantes' : 'Inter Counter App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(provider.locale),
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CounterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.locale == 'es' ? 'Aplicación de contador ' : 'Counter App'),
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.wb_sunny : Icons.nightlight),
            onPressed: provider.toggleTheme,
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: provider.locale,
            dropdownColor: Theme.of(context).canvasColor,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                provider.changeLocale(value);
              }
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text("🇬🇧 EN")),
              DropdownMenuItem(value: 'es', child: Text("🇪🇸 ES")),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: provider.isAnimationInitialized
            ? ScaleTransition(
          scale: provider.scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.locale == 'es' ? 'Contador:' : 'Counter:',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '${provider.counter}',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: provider.counterColor),
              ),
              Text(
                provider.getCounterSize(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: provider.isAnimationInitialized
          ? Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () => provider.reset(context),
            icon: const Icon(Icons.refresh),
            label: Text(provider.locale == 'es' ? 'Reiniciar' : 'Reset'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: () => provider.decrement(context),
            tooltip: provider.locale == 'es' ? 'Disminuir' : 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: () => provider.increment(context),
            tooltip: provider.locale == 'es' ? 'Incrementar' : 'Increment',
            child: const Icon(Icons.add),
          ),

        ],
      )
          : null,

    );
  }
}
